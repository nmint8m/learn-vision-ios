//
//  FaceDetectVC.swift
//  DemoVision
//
//  Created by Tam Nguyen M. on 9/11/18.
//  Copyright © 2018 Tam Nguyen M. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

final class FaceDetectVC: VisionBaseVC {

    // MARK: - Properties
    private var requests = [VNRequest]()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configFaceRequest()
        startCaptureSession()
    }

    // MARK: - Config request handler
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let requestHandler = VNSequenceRequestHandler()
        do {
            try requestHandler.perform(requests,
                                       on: pixelBuffer,
                                       orientation: exifOrientation)
        } catch {
            print(error)
        }
    }
}

// MARK: - Config
private extension FaceDetectVC {
    func configFaceRequest() {
        /*
         VNFaceObservation, Instance Property: landmarks
         This property's value is nil for face observations produced by a VNDetectFaceRectanglesRequest analysis. Use the VNDetectFaceLandmarksRequest class to find facial features.
         --> Change from VNDetectFaceRectanglesRequest to VNDetectFaceLandmarksRequest
         */
        let faceRequest = VNDetectFaceLandmarksRequest { [weak self] (request, error) in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if let results = request.results {
                    this.drawFaceDectectResults(results)
                }
            }
        }
        requests = [faceRequest]
    }
}

// MARK: - Handle draw rectangles
private extension FaceDetectVC {
    func drawFaceDectectResults(_ results: [Any]) {
        let observations = results.map({ $0 as? VNFaceObservation }).compactMap({ $0 })
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        detectionLayer.sublayers = nil

        for observation in observations {
            let box = observation.boundingBox
            highlightBox(box)
            drawLandMark(box: box, feature: observation.landmarks?.faceContour, color: .brown, isClosedPath: false)
            drawLandMark(box: box, feature: observation.landmarks?.innerLips, color: .red)
            drawLandMark(box: box, feature: observation.landmarks?.outerLips, color: .red)
            drawLandMark(box: box, feature: observation.landmarks?.leftEye, color: .cyan)
            drawLandMark(box: box, feature: observation.landmarks?.rightEye, color: .cyan)
            drawLandMark(box: box, feature: observation.landmarks?.leftEyebrow, color: .orange, isClosedPath: false)
            drawLandMark(box: box, feature: observation.landmarks?.rightEyebrow, color: .orange, isClosedPath: false)
            drawLandMark(box: box, feature: observation.landmarks?.nose, color: .green, isClosedPath: false)
            drawLandMark(box: box, feature: observation.landmarks?.noseCrest, color: .green, isClosedPath: false)
            drawLandMark(box: box, feature: observation.landmarks?.leftPupil, color: .blue)
            drawLandMark(box: box, feature: observation.landmarks?.rightPupil, color: .blue)
        }

        updateLayerGeometry()

        CATransaction.commit()
    }

    func highlightBox(_ rect: CGRect) {
        let objectBound: CGRect
        if exifOrientation == .up {
            objectBound = VNImageRectForNormalizedRect(rect,
                                                       Int(bufferSize.width),
                                                       Int(bufferSize.height))
        } else {
            objectBound = VNImageRectForNormalizedRect(rect,
                                                       Int(bufferSize.height),
                                                       Int(bufferSize.width))
        }
        let outline = createRoundedRectLayer(objectBound)
        detectionLayer.addSublayer(outline)
    }

    func createRoundedRectLayer(_ bounds: CGRect) -> CALayer {
        let layer = CALayer()
        layer.bounds = bounds
        layer.position = CGPoint(x: bounds.midX,
                                 y: bounds.midY)
        layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(),
                                        components: [1.0, 1.0, 0.2, 0.4])
        layer.cornerRadius = 5
        return layer
    }

    func drawLandMark(box: CGRect, feature: VNFaceLandmarkRegion2D?, color: UIColor, isClosedPath: Bool = true) {
        guard let feature = feature else { return }
        let line = CAShapeLayer()
        let linePath = UIBezierPath(rect: detectionLayer.bounds)
        var firstDestinatePoint: CGPoint?

        print("POINT OF FEATURE")
        for i in 0...feature.pointCount - 1 {
            print("POINT \(i): \(feature.normalizedPoints[i])")
        }
        print("----------------------------")
        print("EXIFORIENTATION: \(exifOrientation)")
        print("BOUNDING BOX: \(box)")
        print("----------------------------")

        for i in 0...feature.pointCount - 1 {
            let point = feature.normalizedPoints[i]
            let vector = vector_float2(x: Float(point.x),
                                       y: Float(point.y))
            let destinatePoint: CGPoint
            if exifOrientation == .up {
                destinatePoint = VNImagePointForFaceLandmarkPoint(vector,
                                                                  box,
                                                                  Int(bufferSize.width),
                                                                  Int(bufferSize.height))
            } else {
                destinatePoint = VNImagePointForFaceLandmarkPoint(vector,
                                                                  box,
                                                                  Int(bufferSize.height),
                                                                  Int(bufferSize.width))
            }

            if i == 0 {
                linePath.move(to: destinatePoint)
                firstDestinatePoint = destinatePoint
            } else {
                linePath.addLine(to: destinatePoint)
            }

            if let closePoint = firstDestinatePoint,
                i == feature.pointCount - 1, isClosedPath {
                linePath.addLine(to: closePoint)
            }

            line.path = linePath.cgPath
            line.fillColor = nil
            line.strokeColor = color.cgColor
            line.opacity = 1
            detectionLayer.addSublayer(line)
        }
    }
}
