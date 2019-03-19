//
//  VisionBaseVC.swift
//  Violet
//
//  Created by Tam Nguyen M. on 9/11/18.
//  Copyright © 2018 Tam Nguyen M. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class VisionBaseVC: UIViewController {

    // MARK: - Property
    /// Size of image/video
    var bufferSize: CGSize = .zero

    /// Layer of root view
    var rootLayer: CALayer {
        return view.layer
    }

    /// Layer that contains all the renderings of the observations
    var detectionLayer = CALayer()

    /// Capture session
    private let session = AVCaptureSession()

    /// Layer that shows live video
    private var previewLayer: AVCaptureVideoPreviewLayer?

    /// Video data output
    private let videoDataOutput = AVCaptureVideoDataOutput()

    /// Video data output queue
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput",
                                                     qos: .userInitiated,
                                                     attributes: [],
                                                     autoreleaseFrequency: .workItem)

    /// The latest orientation of exif
    private var lastestOrientation = CGImagePropertyOrientation.up

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configAVCapture()
        configRootLayer()
        configDetectionLayer()
        updateLayerGeometry()
        configRotationNotification()
        configPanGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notificationCenter.post(name: .UIDeviceOrientationDidChange, object: nil)
    }
}

extension VisionBaseVC {
    // MARK: - Config AVCapture and root layer

    /// Get exif orientation of image from device orientation
    var exifOrientation: CGImagePropertyOrientation {
        let deviceOrientation = UIDevice.current.orientation
        let imageOrientation: CGImagePropertyOrientation

        switch deviceOrientation {
        case .unknown, .faceUp, .faceDown:
            imageOrientation = lastestOrientation
        case .portrait, .portraitUpsideDown:
            imageOrientation = .left
        case .landscapeLeft, .landscapeRight:
            imageOrientation = .up
        }

        lastestOrientation = imageOrientation
        return imageOrientation
    }

    /// Config capture
    private func configAVCapture() {
        guard let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                 mediaType: .video,
                                                                 position: .back).devices.first,
            let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                alert(message: "Cannot get back camera or create video device input")
                return
        }

        session.beginConfiguration()
        session.sessionPreset = .high // Model image size is smaller.

        // Add a video input
        guard session.canAddInput(deviceInput) else {
            alert(message: "Cannot add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)

        // Add video output
        guard session.canAddOutput(videoDataOutput) else {
            alert(message: "Cannot add video data output to the session")
            session.commitConfiguration()
            return
        }
        session.addOutput(videoDataOutput)

        // Add a video data output
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)

        let captureConnection = videoDataOutput.connection(with: .video)

        // Always process the frames
        captureConnection?.isEnabled = true
        do {
            try videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
    }

    /// Config root layer which shows live video
    private func configRootLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer = previewLayer
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }

    /// Start capture
    func startCaptureSession() {
        session.startRunning()
    }

    /// Tear down capture
    func teardownAVCapture() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }

    // MARK: - Config detection layer
    /// Config detection layer
    private func configDetectionLayer() {
        detectionLayer.bounds = .zero
        detectionLayer.position = CGPoint(x: rootLayer.bounds.midX,
                                          y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionLayer)
    }

    /// Config rotation notification
    private func configRotationNotification() {
        notificationCenter.addObserver(self,
                                       selector: #selector(updateDetectionLayer),
                                       name: .UIDeviceOrientationDidChange,
                                       object: nil)
    }

    @objc private func updateDetectionLayer() {
        if exifOrientation == .up {
            detectionLayer.bounds = CGRect(x: 0.0,
                                           y: 0.0,
                                           width: bufferSize.width,
                                           height: bufferSize.height)
        } else {
            detectionLayer.bounds = CGRect(x: 0.0,
                                           y: 0.0,
                                           width: bufferSize.height,
                                           height: bufferSize.width)
        }
        detectionLayer.position = CGPoint(x: rootLayer.bounds.midX,
                                          y: rootLayer.bounds.midY)

        detectionLayer.sublayers = nil
    }

    /// Update layer geometry
    func updateLayerGeometry() {
        let bounds = rootLayer.bounds
        var scale: CGFloat

        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        if exifOrientation == .up {
            detectionLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0))
                .scaledBy(x: scale, y: -scale))
            detectionLayer.position = CGPoint(x: bounds.midX,
                                              y: bounds.midY)
        } else {
            detectionLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat.pi)
                .scaledBy(x: scale, y: -scale))
        }

        CATransaction.commit()
    }

    // MARK: - Config pan gesture
    /// Config pan gesture to back to previous screen
    private func configPanGesture() {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(backToPreviousScreen))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gesture)
    }

    /// Back to previous screen
    @objc func backToPreviousScreen() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension VisionBaseVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // To be Implemented in the subclass
    }

    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // To be implemented in the subclass
    }
}
