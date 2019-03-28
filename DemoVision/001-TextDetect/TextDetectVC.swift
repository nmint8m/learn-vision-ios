//
//  RectangleDetectVC.swift
//  DemoVision
//
//  Created by Tam Nguyen M. on 9/11/18.
//  Copyright © 2018 Tam Nguyen M. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

final class TextDetectVC: VisionBaseVC {

    // MARK: - Properties
    private var requests = [VNRequest]()

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configTextRequest()
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

private extension TextDetectVC {

    /// Config text rectangles request
    func configTextRequest() {
        let textRequest = VNDetectTextRectanglesRequest { [weak self] (request, error) in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if let results = request.results {
                    this.drawTextDectectResults(results)
                }
            }
        }
        textRequest.reportCharacterBoxes = true
        requests = [textRequest]
    }
}

// MARK: - Handle draw rectangles
private extension TextDetectVC {
    func drawTextDectectResults(_ results: [Any]) {
        let observations = results.map({ $0 as? VNTextObservation }).compactMap({ $0 })
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        detectionLayer.sublayers = nil

        for observation in observations {
            if let characterBoxes = observation.characterBoxes {
                for characterBox in characterBoxes {
                    highlightLetters(box: characterBox)
                }
            }
        }

        updateLayerGeometry()

        CATransaction.commit()
    }

    func highlightLetters(box: VNRectangleObservation) {
        let objectBound: CGRect
        if exifOrientation == .up {
            objectBound = VNImageRectForNormalizedRect(box.boundingBox,
                                                       Int(bufferSize.width),
                                                       Int(bufferSize.height))
        } else {
            objectBound = VNImageRectForNormalizedRect(box.boundingBox,
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
