//
//  ViewController.swift
//  Vinci
//
//  Created by Anessa Petteruti on 6/28/23.
//

import Foundation
import UIKit
import SwiftUI
import AVFoundation
import Vision


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
//    var currentSampleBuffer: CMSampleBuffer?


    // Detector
    private var videoOutput = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()
    var detectionLayer: CALayer! = nil


    override func viewDidLoad() {
        checkPermission()

        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()

            self.setupLayers()
            self.setupDetector()

            self.captureSession.startRunning()
        }
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        switch UIDevice.current.orientation {
            // Home button on top
            case UIDeviceOrientation.portraitUpsideDown:
                self.previewLayer.connection?.videoOrientation = .portraitUpsideDown

            // Home button on right
            case UIDeviceOrientation.landscapeLeft:
                self.previewLayer.connection?.videoOrientation = .landscapeRight

            // Home button on left
            case UIDeviceOrientation.landscapeRight:
                self.previewLayer.connection?.videoOrientation = .landscapeLeft

            // Home button at bottom
            case UIDeviceOrientation.portrait:
                self.previewLayer.connection?.videoOrientation = .portrait

            default:
                break
            }

        // Detector
        updateLayers()
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
            case .authorized:
                permissionGranted = true

            // Permission has not been requested yet
            case .notDetermined:
                requestPermission()

            default:
                permissionGranted = false
            }
    }

    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }

    func setupCaptureSession() {
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }

        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)

        // Preview layer
        screenRect = UIScreen.main.bounds

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        previewLayer.connection?.videoOrientation = .portrait

        // Detector
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)

        videoOutput.connection(with: .video)?.videoOrientation = .portrait

        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
}




// ATTEMPT AT SEGMENTATION:
//import Foundation
//import UIKit
//import SwiftUI
//import AVFoundation
//import Vision
//import CoreML
//
//class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
//    private var permissionGranted = false
//    private let captureSession = AVCaptureSession()
//    private let sessionQueue = DispatchQueue(label: "sessionQueue")
//    private var previewLayer = AVCaptureVideoPreviewLayer()
//    private var screenRect: CGRect = .zero
//
//    // Detector
//    private var videoOutput = AVCaptureVideoDataOutput()
//    private var detectionRequests = [VNRequest]()
//    private var segmentationRequests = [VNRequest]()
//    private var detectionLayer: CALayer! = nil
//    private var maskOverlayLayer: CALayer! = nil
//
//    private var lastSampleBuffer: CMSampleBuffer?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        checkPermission()
//
//        sessionQueue.async { [unowned self] in
//            guard permissionGranted else { return }
//            self.setupCaptureSession()
//
//            self.setupLayers()
//            self.setupDetector()
//
//            self.captureSession.startRunning()
//        }
//    }
//
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        screenRect = UIScreen.main.bounds
//        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//
//        switch UIDevice.current.orientation {
//        case .portraitUpsideDown:
//            self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
//        case .landscapeLeft:
//            self.previewLayer.connection?.videoOrientation = .landscapeRight
//        case .landscapeRight:
//            self.previewLayer.connection?.videoOrientation = .landscapeLeft
//        case .portrait:
//            self.previewLayer.connection?.videoOrientation = .portrait
//        default:
//            break
//        }
//
//        updateLayers()
//    }
//
//    func checkPermission() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            permissionGranted = true
//        case .notDetermined:
//            requestPermission()
//        default:
//            permissionGranted = false
//        }
//    }
//
//    func requestPermission() {
//        sessionQueue.suspend()
//        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
//            self.permissionGranted = granted
//            self.sessionQueue.resume()
//        }
//    }
//
//    func setupCaptureSession() {
//        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else { return }
//        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
//
//        guard captureSession.canAddInput(videoDeviceInput) else { return }
//        captureSession.addInput(videoDeviceInput)
//
//        screenRect = UIScreen.main.bounds
//
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//        previewLayer.videoGravity = .resizeAspectFill
//        previewLayer.connection?.videoOrientation = .portrait
//
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
//        captureSession.addOutput(videoOutput)
//
//        videoOutput.connection(with: .video)?.videoOrientation = .portrait
//
//        DispatchQueue.main.async { [weak self] in
//            self?.view.layer.addSublayer(self!.previewLayer)
//        }
//    }
//
//    func setupDetector() {
//        guard let objectModelURL = Bundle.main.url(forResource: "YOLOv3", withExtension: "mlmodelc") else {
//            print("Unable to locate the YOLOv3.mlmodel file")
//            return
//        }
//
//        do {
//            let objectModel = try VNCoreMLModel(for: MLModel(contentsOf: objectModelURL))
//            let objectDetectionRequest = VNCoreMLRequest(model: objectModel, completionHandler: objectDetectionDidComplete)
//            detectionRequests = [objectDetectionRequest]
//        } catch let error {
//            print("Error creating VNCoreMLModel for object detection: \(error)")
//        }
//
//        guard let segmentationModelURL = Bundle.main.url(forResource: "DeepLabV3", withExtension: "mlmodelc") else {
//            print("Unable to locate the DeepLabv3.mlmodel file")
//            return
//        }
//
//        do {
//            let segmentationModel = try VNCoreMLModel(for: MLModel(contentsOf: segmentationModelURL))
//            let segmentationRequest = VNCoreMLRequest(model: segmentationModel, completionHandler: segmentationDidComplete)
//            segmentationRequests = [segmentationRequest]
//        } catch let error {
//            print("Error creating VNCoreMLModel for segmentation: \(error)")
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
//    func extractDetections(_ results: [Any]) {
//        detectionLayer.sublayers = nil
//        allObservations.removeAll()
//
//        for observation in results where observation is VNRecognizedObjectObservation {
//            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
//
//            let recognizedObject = objectObservation.labels[0].identifier
//            allObservations.append(recognizedObject)
//            let confidence = objectObservation.labels[0].confidence
//
//            if highlightedObjects.contains(recognizedObject) {
//                let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
//                let transformedBounds = CGRect(x: objectBounds.minX * screenRect.size.width,
//                                               y: objectBounds.minY * screenRect.size.height,
//                                               width: objectBounds.width * screenRect.size.width,
//                                               height: objectBounds.height * screenRect.size.height)
//
//                let boxLayer = drawBoundingBox(transformedBounds)
//
//                let labelLayer = createLabelLayer(recognizedObject, confidence)
//                boxLayer.addSublayer(labelLayer)
//
//                detectionLayer.addSublayer(boxLayer)
//
//                applySegmentationMask(to: transformedBounds)
//            }
//        }
//    }
//
//    func applySegmentationMask(to bounds: CGRect) {
//        guard let lastSampleBuffer = self.lastSampleBuffer else { return }
//
//        let imageRequestHandler = VNImageRequestHandler(cmSampleBuffer: lastSampleBuffer, orientation: .up, options: [:])
//
//        do {
//            try imageRequestHandler.perform(segmentationRequests)
//        } catch {
//            print("Error performing segmentation request: \(error)")
//        }
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
//        DispatchQueue.main.async { [weak self] in
//            self?.showSegmentationMask(results)
//        }
//    }
//
//    func showSegmentationMask(_ results: [Any]) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(lastSampleBuffer!) else {
//            return
//        }
//
//        let image = CIImage(cvPixelBuffer: pixelBuffer)
//        let orientedImage = image.oriented(.up)
//
//        for observation in results where observation is VNCoreMLFeatureValueObservation {
//            guard let segmentationObservation = observation as? VNCoreMLFeatureValueObservation else { continue }
//            guard let multiArray = segmentationObservation.featureValue.multiArrayValue else { continue }
//
//            let width = multiArray.shape[1].intValue // Width of the segmentation mask
//            let height = multiArray.shape[0].intValue // Height of the segmentation mask
//            let channels = multiArray.shape[2].intValue // Number of channels in the segmentation mask
//
//            let numElements = width * height * channels
//
//            let resizedMaskPixelBuffer = createResizedMaskPixelBuffer(width: width, height: height)
//            guard let resizedMaskBuffer = resizedMaskPixelBuffer else { continue }
//            CVPixelBufferLockBaseAddress(resizedMaskBuffer, .readOnly)
//
//            let baseAddress = CVPixelBufferGetBaseAddress(resizedMaskBuffer)
//            let pixelBufferBytesPerRow = CVPixelBufferGetBytesPerRow(resizedMaskBuffer)
//
//            // Iterate over each pixel in the resized mask and set the corresponding value from the multiArray
//            for y in 0..<height {
//                for x in 0..<width {
//                    let index = (y * width + x) * channels
//                    guard index < numElements else { continue } // Check if index is within bounds
//
//                    let value = multiArray[index].floatValue
//
//                    let pixelAddress = CVPixelBufferGetBaseAddress(resizedMaskBuffer)?.advanced(by: y * pixelBufferBytesPerRow + x)
//
//                    if let pixel = pixelAddress?.assumingMemoryBound(to: UInt8.self) {
//                        let clampedValue = UInt8(clamping: Int(value * 255))
//                        pixel.pointee = clampedValue
//                    }
//
//
//
//                }
//            }
//
//
//            CVPixelBufferUnlockBaseAddress(resizedMaskBuffer, .readOnly)
//
//            // Create a CIImage from the resized mask pixel buffer
//            let maskImage = CIImage(cvPixelBuffer: resizedMaskBuffer)
//
//            let combinedImage = maskImage
//                .cropped(to: orientedImage.extent)
//                .applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0, kCIInputContrastKey: 50])
//                .applyingFilter("CIMultiplyBlendMode", parameters: [kCIInputBackgroundImageKey: orientedImage])
//
//            DispatchQueue.main.async {
//                self.maskOverlayLayer?.removeFromSuperlayer()
//                self.maskOverlayLayer = CALayer()
//                self.maskOverlayLayer.frame = CGRect(x: 0, y: 0, width: self.screenRect.size.width, height: self.screenRect.size.height)
//                self.maskOverlayLayer.contents = combinedImage
//                self.view.layer.insertSublayer(self.maskOverlayLayer, below: self.detectionLayer)
//            }
//        }
//    }
//
//
//    func createResizedMaskPixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
//        var resizedMaskPixelBuffer: CVPixelBuffer?
//
//        let status = CVPixelBufferCreate(nil, width, height, kCVPixelFormatType_OneComponent8, nil, &resizedMaskPixelBuffer)
//
//        if status != kCVReturnSuccess {
//            print("Error creating resized mask pixel buffer")
//            return nil
//        }
//
//        CVPixelBufferLockBaseAddress(resizedMaskPixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//
//        return resizedMaskPixelBuffer
//    }
//
//
//
//
//
//    func setupLayers() {
//        detectionLayer = CALayer()
//        detectionLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//        self.view.layer.addSublayer(detectionLayer)
//        detectionLayer.zPosition = CGFloat.greatestFiniteMagnitude
//    }
//
//    func updateLayers() {
//        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//        maskOverlayLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
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
//    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
//        let boxLayer = CALayer()
//        boxLayer.frame = bounds
//        boxLayer.borderWidth = 3.0
//        boxLayer.borderColor = CGColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
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
//            try imageRequestHandler.perform(detectionRequests)
//        } catch {
//            print("Error performing object detection request: \(error)")
//        }
//    }
//}
//
//
//struct HostedViewController: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        return ViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//    }
//}
//
//
