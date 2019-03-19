//
//  BreakfastVC.swift
//  Violet
//
//  Created by Tam Nguyen M. on 12/20/18.
//  Copyright © 2018 Tam Nguyen M. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

final class BreakfastDetectVC: VisionBaseVC {

    // MARK: - Properties
    private let label = UILabel()

    private var requests = [VNRequest]()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard #available(iOS 12.0, *) else {
            backToPreviousScreen()
            return
        }
        configLabel()
        configImagesRequest()
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

private extension BreakfastDetectVC {
    /// Config label
    private func configLabel() {
        label.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        label.layoutIfNeeded()
    }

    /// Config text rectangles request
    @available(iOS 12.0, *)
    func configImagesRequest() {
        guard let model = try? VNCoreMLModel(for: ObjectDetector().model) else { return }
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if let results = request.results {
                    this.drawDectectResults(results)
                }
            }
        }
        self.requests = [request]
    }
}

// MARK: - Handle draw rectangles
private extension BreakfastDetectVC {
    @available(iOS 12.0, *)
    func drawDectectResults(_ results: [Any]) {
        let observations = results.map({ $0 as? VNRecognizedObjectObservation }).compactMap({ $0 })
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        detectionLayer.sublayers = nil

        var detectedObjects = ""

        for observation in observations {
            if let topLabel = observation.labels.first {
                highlightBox(observation.boundingBox)
                detectedObjects += "\(topLabel.identifier), \(topLabel.confidence)\n"
//                addTag(observation.boundingBox,
//                       identify: topLabel.identifier,
//                       confidence: topLabel.confidence)
                print("\(topLabel.identifier)\(topLabel.confidence)")
            }
        }

        label.text = detectedObjects

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
}
