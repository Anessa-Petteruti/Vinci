//
//  Detector.swift
//  Vinci
//
//  Created by Anessa Petteruti on 6/28/23.
//

import Foundation
import Vision
import AVFoundation
import UIKit

var allObservations: [String] = []

extension ViewController {

    func setupDetector() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") else {
            print("Unable to locate the YOLOv3.mlmodel file")
            return
        }

        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
            self.requests = [recognitions]
        } catch let error {
            print("Error creating VNCoreMLModel: \(error)")
        }
    }


    func detectionDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: {
            if let results = request.results {
                self.extractDetections(results)
            }
        })
    }

    func extractDetections(_ results: [VNObservation]) {
        detectionLayer.sublayers = nil

        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }

            // Get the recognized object label and confidence
            let recognizedObject = objectObservation.labels[0].identifier
            allObservations.append(recognizedObject)
            let confidence = objectObservation.labels[0].confidence


            if (highlightedObjects.count == 0) {
                print("NO HIGHLIGHTED OBJECTS YET")
            }
            else {
                // Check if any recognized object is in highlightedObjects
                if highlightedObjects.contains(recognizedObject) {
                    // Transformations
                    let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
                    let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)

                    let boxLayer = self.drawBoundingBox(transformedBounds)

                    // Add label and confidence text to the box layer
                    let labelLayer = self.createLabelLayer(recognizedObject, confidence)
                    boxLayer.addSublayer(labelLayer)

                    detectionLayer.addSublayer(boxLayer)
                }

            }


        }
    }

    func createLabelLayer(_ object: String, _ confidence: VNConfidence) -> CATextLayer {
        let labelLayer = CATextLayer()
        labelLayer.string = "\(object) (\(String(format: "%.2f", confidence * 100))%)"
        labelLayer.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        labelLayer.fontSize = 16
        labelLayer.foregroundColor = UIColor.white.cgColor
        labelLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
        labelLayer.alignmentMode = .center
        labelLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        labelLayer.position = CGPoint(x: 0.5 * labelLayer.frame.width, y: 0.5 * labelLayer.frame.height)

        return labelLayer
    }


    func setupLayers() {
        detectionLayer = CALayer()
        detectionLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        self.view.layer.addSublayer(detectionLayer)
        self.view.layer.insertSublayer(detectionLayer, at: UInt32(self.view.layer.sublayers?.count ?? 0))
        detectionLayer.zPosition = CGFloat.greatestFiniteMagnitude

    }


    func updateLayers() {
        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
    }

    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 3.0
        boxLayer.borderColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        boxLayer.cornerRadius = 4
        return boxLayer
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:]) // Create handler to perform request on the buffer
        do {
            try imageRequestHandler.perform(self.requests) // Schedules vision requests to be performed
        } catch {
            print(error)
        }
    }

}




////
////  Detector.swift
////  Vinci
////
////  Created by Anessa Petteruti on 6/28/23.
////
//
//import Foundation
//import Vision
//import AVFoundation
//import UIKit
//
//var allObservations: [String] = []
//
//extension ViewController {
//
//    func setupDetector() {
//        guard let objectModelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") else {
//            print("Unable to locate the YOLOv3.mlmodel file")
//            return
//        }
//
//        guard let segmentationModelURL = Bundle.main.url(forResource: "DeepLabV3", withExtension: "mlmodelc") else {
//            print("Unable to locate the DeepLabV3.mlmodel file")
//            return
//        }
//
//        do {
//            let objectModel = try VNCoreMLModel(for: MLModel(contentsOf: objectModelURL))
//            let segmentationModel = try VNCoreMLModel(for: MLModel(contentsOf: segmentationModelURL))
//
//            let objectDetectionRequest = VNCoreMLRequest(model: objectModel, completionHandler: objectDetectionDidComplete)
//            let segmentationRequest = VNCoreMLRequest(model: segmentationModel, completionHandler: segmentationDidComplete)
//
//            self.requests = [objectDetectionRequest, segmentationRequest]
//        } catch let error {
//            print("Error creating VNCoreMLModel: \(error)")
//        }
//    }
//
//    func objectDetectionDidComplete(request: VNRequest, error: Error?) {
//        if let error = error {
//            print("Object detection error: \(error)")
//            return
//        }
//
//        guard let results = request.results else {
//            print("No object detection results found")
//            return
//        }
//
//        extractDetections(results)
//    }
//
//    func segmentationDidComplete(request: VNRequest, error: Error?) {
//        if let error = error {
//            print("Segmentation error: \(error)")
//            return
//        }
//
//        guard let results = request.results else {
//            print("No segmentation results found")
//            return
//        }
//
//        extractSegmentation(results)
//    }
//
//    func extractSegmentation(_ results: [VNObservation]) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(lastSampleBuffer!) else {
//            return
//        }
//
//        let image = CIImage(cvPixelBuffer: pixelBuffer)
//        let orientedImage = image.oriented(.up)
//
//        for observation in results where observation is VNPixelBufferObservation {
//            guard let segmentationObservation = observation as? VNPixelBufferObservation else { continue }
//
//            let maskImage = CIImage(cvPixelBuffer: segmentationObservation.pixelBuffer)
//
//            let resizedMaskImage = maskImage
//                .cropped(to: orientedImage.extent)
//                .applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0, kCIInputContrastKey: 50])
//
//            let combinedImage = resizedMaskImage.applyingFilter("CIMultiplyBlendMode", parameters: [kCIInputBackgroundImageKey: orientedImage])
//
//            DispatchQueue.main.async {
//                self.showSegmentationResult(combinedImage)
//            }
//        }
//    }
//
//
//
//    func showSegmentationResult(_ image: CIImage) {
//        let imageView = UIImageView(image: UIImage(ciImage: image))
//        imageView.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//
//        let overlayView = UIView(frame: CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height))
//        overlayView.addSubview(imageView)
//
//        // Add the overlay view to your view hierarchy or replace the existing detectionLayer with this overlayView
//        self.view.addSubview(overlayView)
//    }
//
//
//
//    func detectionDidComplete(request: VNRequest, error: Error?) {
//        DispatchQueue.main.async(execute: {
//            if let results = request.results {
//                self.extractDetections(results)
//            }
//        })
//    }
//
//    func extractDetections(_ results: [VNObservation]) {
//        detectionLayer.sublayers = nil
//        print("THIS IS ALL OBSERVATIONS", allObservations)
//
//
//        for observation in results where observation is VNRecognizedObjectObservation {
//            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
//
//            // Get the recognized object label and confidence
//            let recognizedObject = objectObservation.labels[0].identifier
//            allObservations.append(recognizedObject)
//            let confidence = objectObservation.labels[0].confidence
//
//
//
//            if (highlightedObjects.count == 0) {
//                print("NO HIGHLIGHTED OBJECTS YET")
//            }
//            else {
//                // Check if any recognized object is in highlightedObjects
//                if highlightedObjects.contains(recognizedObject) {
//                    // Transformations
//                    let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
//                    let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
//
//                    let boxLayer = self.drawBoundingBox(transformedBounds)
//
//                    // Add label and confidence text to the box layer
//                    let labelLayer = self.createLabelLayer(recognizedObject, confidence)
//                    boxLayer.addSublayer(labelLayer)
//
//                    detectionLayer.addSublayer(boxLayer)
//                }
//
//            }
//
//
//        }
//    }
//
//    func createLabelLayer(_ object: String, _ confidence: VNConfidence) -> CATextLayer {
//        let labelLayer = CATextLayer()
//        labelLayer.string = "\(object) (\(String(format: "%.2f", confidence * 100))%)"
//        labelLayer.font = UIFont.systemFont(ofSize: 14, weight: .bold)
//        labelLayer.fontSize = 16
//        labelLayer.foregroundColor = UIColor.white.cgColor
//        labelLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
//        labelLayer.alignmentMode = .center
//        labelLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
//        labelLayer.position = CGPoint(x: 0.5 * labelLayer.frame.width, y: 0.5 * labelLayer.frame.height)
//
//        return labelLayer
//    }
//
//
//    func setupLayers() {
//        detectionLayer = CALayer()
//        detectionLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//        self.view.layer.addSublayer(detectionLayer)
//        self.view.layer.insertSublayer(detectionLayer, at: UInt32(self.view.layer.sublayers?.count ?? 0))
//        detectionLayer.zPosition = CGFloat.greatestFiniteMagnitude
//
//    }
//
//
//    func updateLayers() {
//        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//    }
//
//    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
//        let boxLayer = CALayer()
//        boxLayer.frame = bounds
//        boxLayer.borderWidth = 3.0
//        boxLayer.borderColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        boxLayer.cornerRadius = 4
//        return boxLayer
//    }
//
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        lastSampleBuffer = sampleBuffer
//
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
//        do {
//            try imageRequestHandler.perform(requests)
//        } catch {
//            print(error)
//        }
//    }
//
//
//
//
//}
//
