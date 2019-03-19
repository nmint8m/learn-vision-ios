//
//  FaceDetectVC.swift
//  Violet
//
//  Created by Tam Nguyen M. on 9/11/18.
//  Copyright © 2018 Tam Nguyen M. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

final class FaceDetectVC: VisionBaseVC {

    /*
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
        let faceRequest = VNDetectFaceRectanglesRequest { [weak self] (request, error) in
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
            highlightBox(observation.boundingBox)
            drawLandMark(feature: observation.landmarks?.faceContour, color: .brown)
            drawLandMark(feature: observation.landmarks., color: <#T##UIColor#>)
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

//    CAShapeLayer *line = [CAShapeLayer layer];
//    UIBezierPath *linePath=[UIBezierPath bezierPath];
//    [linePath moveToPoint: pointA];
//    [linePath addLineToPoint:pointB];
//    line.path=linePath.CGPath;
//    line.fillColor = nil;
//    line.opacity = 1.0;
//    line.strokeColor = [UIColor redColor].CGColor;
//    [layer addSublayer:line];
//}

    func drawLandMark(feature: VNFaceLandmarkRegion2D?, color: UIColor) {
        guard let feature = feature else { return }

        
        for i in 0...feature.pointCount - 1 {
            let point = feature.point(at: i)
            if i == 0 {
                context?.move(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
            } else {
                context?.addLine(to: CGPoint(x: x + CGFloat(point.x) * w, y: y + CGFloat(point.y) * h))
            }
        }
    }
 */
}
