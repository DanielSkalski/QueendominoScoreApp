//
//  VisionObjectRecognitionViewController.swift
//  QueendominoScoreApp
//
//  Created by Daniel Skalski on 24/03/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class VisionObjectRecognitionViewController: ViewController {
    
    private var detectionOverlay: CALayer! = nil
    private var objectRecognitionRequest = [VNRequest]()
    private var visionToBoardConverter = VisionToBoardConverter()
    private var scoreCalculator = ScoreCalculator()
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @discardableResult
    func setupVision() -> NSError? {
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "Queendomino",
                                             withExtension: "mlmodelc")
        else {
            return NSError(domain: "VisionObjectRecognitionViewController",
                           code: -1,
                           userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            visionModel.featureProvider = ThresholdProvider()
            let objectRecognition = VNCoreMLRequest(model: visionModel,
                                                    completionHandler: self.handleRecognition)
            self.objectRecognitionRequest = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    //MARK: Handle recognition
    
    func handleRecognition(request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: {
            // perform all the UI updates on the main queue
            if let results = request.results {
                let _ = self.calculateScore(results)
                self.drawVisionRequestResults(results)
            }
        })
    }
    
    func calculateScore(_ results: [Any]) -> PlayerScore {
        let recognizedObjects = results
            .filter({$0 is VNRecognizedObjectObservation})
            .map({$0 as! VNRecognizedObjectObservation})
        
        if recognizedObjects.count == 0 {
            return PlayerScore()
        }
        
        let board = visionToBoardConverter.convert(recognizedObjects)
        let score = scoreCalculator.getScore(board)
        
        self.drawScore(score)
        
        return score
    }
    
    func drawScore(_ score: PlayerScore) {
        
        print("======== new score ==========")
        let orderList: [LandType] = [.city, .dessert, .forrest, .grass, .mine, .plains, .sea]
        
        var scoreText = ""
        for landType in orderList {
            if score.domainScores[landType] != nil {
                let domainScore = score.domainScores[landType]!
                let domainScoreText = "\(domainScore.type): \(domainScore.score)"
                print(domainScoreText)
                scoreText += domainScoreText + "\n"
            } else {
                let domainScoreText = "\(landType): 0"
                scoreText += domainScoreText + "\n"
            }
        }
        
        self.scoreLabel.text = scoreText
    }
    
    //MARK: Draw recognized objects
    
    func drawVisionRequestResults(_ results: [Any]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay.sublayers = nil // remove all the old recognized objects
        
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let recognizedObject = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let bestRecognition = recognizedObject.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(recognizedObject.boundingBox, Int(bufferSize.width), Int(bufferSize.height))

            let objectLayer = self.createRecognizedObjectLayer(objectBounds,
                                                              bestRecognition);
            
            detectionOverlay.addSublayer(objectLayer)
        }
        
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    func createRecognizedObjectLayer(_ objectBounds: CGRect, _ recognition: VNClassificationObservation) -> CALayer {
        
        let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
        let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                        identifier: recognition.identifier,
                                                        confidence: recognition.confidence)
        shapeLayer.addSublayer(textLayer)
        
        return shapeLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        let largeFont = UIFont(name: "Helvetica", size: 24.0)!
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0 // retina rendering
        // rotate the layer into screen orientation and scale and mirror
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    // MARK: Setup AV Capture
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let exifOrientation = exifOrientationFromDeviceOrientation()

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: exifOrientation,
                                                        options: [:])
        do {
            try imageRequestHandler.perform(self.objectRecognitionRequest)
        } catch {
            print(error)
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        
        // setup Vision parts
        addDetectionOverlay()
        updateLayerGeometry()
        setupVision()
        
        // start the capture
        startCaptureSession()
    }
    
    func addDetectionOverlay() {
        detectionOverlay = CALayer() // container layer that has all the renderings of the observations
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: rootLayer.bounds.midX,
                                            y: rootLayer.bounds.midY)
        rootLayer.addSublayer(detectionOverlay)
    }
    
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
        
        // rotate the layer into screen orientation and scale and mirror
        detectionOverlay.setAffineTransform(
            CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0))
                .scaledBy(x: scale, y: -scale))
        // center the layer
        detectionOverlay.position = CGPoint (x: bounds.midX, y: bounds.midY)
        
        CATransaction.commit()
    }
    
}
