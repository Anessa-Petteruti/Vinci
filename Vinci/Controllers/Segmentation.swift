//import Foundation
//import Vision
//import AVFoundation
//import UIKit
//
////var allObservations: [String] = []
//
//extension ViewController {
//
//    func setupSegmentation() {
//        guard let modelURL = Bundle.main.url(forResource: "DeepLabV3", withExtension: "mlmodelc") else {
//            print("Unable to locate the DeepLabV3.mlmodel file")
//            return
//        }
//
//        do {
//            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
//            let segmentationRequest = VNCoreMLRequest(model: visionModel, completionHandler: segmentationDidComplete)
//            self.requests = [segmentationRequest]
//        } catch let error {
//            print("Error creating VNCoreMLModel: \(error)")
//        }
//    }
//
//
//    func segmentationDidComplete(request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
//            if let results = request.results,
//               let sampleBuffer = self.currentSampleBuffer,
//               let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
//                self.extractDetections(results, pixelBuffer: pixelBuffer)
//            }
//        }
//    }
//
//    func processSegmentationMask(_ segmentationMask: CVPixelBuffer) -> CVPixelBuffer {
//        let width = CVPixelBufferGetWidth(segmentationMask)
//        let height = CVPixelBufferGetHeight(segmentationMask)
//
//        // Create a bitmap context for rendering
//        let bytesPerRow = width * 4
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
//        guard let renderingContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue) else {
//            return segmentationMask
//        }
//
//        // Render the segmentation mask with a color
//        let color = UIColor.red.cgColor
//        renderingContext.setFillColor(color)
//        renderingContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
//
//        // Create a new pixel buffer with the rendered mask
//        var processedMask: CVPixelBuffer?
//        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, nil, &processedMask)
//        if let processedMask = processedMask {
//            CVPixelBufferLockBaseAddress(processedMask, [])
//            let baseAddress = CVPixelBufferGetBaseAddress(processedMask)
//            let contextData = renderingContext.data
//            let contextWidth = renderingContext.width
//            let contextHeight = renderingContext.height
//            let contextBytesPerRow = renderingContext.bytesPerRow
//            let contextBytesPerPixel = 4
//            for y in 0..<contextHeight {
//                let maskOffset = y * contextBytesPerRow
//                let contextOffset = y * contextBytesPerRow
//                memcpy(baseAddress! + maskOffset, contextData! + contextOffset, contextBytesPerPixel * contextWidth)
//            }
//            CVPixelBufferUnlockBaseAddress(processedMask, [])
//
//            return processedMask
//        }
//
//        return segmentationMask
//    }
//
//    func displaySegmentationMask(_ processedMask: CVPixelBuffer, on originalPixelBuffer: CVPixelBuffer) {
//        // Create a CIImage from the processed mask
//        let processedImage = CIImage(cvPixelBuffer: processedMask)
//
//        // Create a CIImage from the original pixel buffer
//        let originalImage = CIImage(cvPixelBuffer: originalPixelBuffer)
//
//        // Composite the processed mask image onto the original image
//        let compositedImage = processedImage.composited(over: originalImage)
//
//        // Convert the composited image to a UIImage
//        let context = CIContext()
//        let outputImage = context.createCGImage(compositedImage, from: compositedImage.extent)
//        let uiImage = UIImage(cgImage: outputImage!)
//
//        // Display the resulting image
//        let imageView = UIImageView(image: uiImage)
//        imageView.contentMode = .scaleAspectFit
//        imageView.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//        detectionLayer.sublayers = nil
//        detectionLayer.addSublayer(imageView.layer)
//    }
//
//    func captureOutputSegmentation(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        currentSampleBuffer = sampleBuffer
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
//        do {
//            try imageRequestHandler.perform(requests)
//        } catch {
//            print("Error performing image request: \(error)")
//        }
//    }
//
//    // ...
//}
