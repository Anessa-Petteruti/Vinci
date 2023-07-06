//
//  CameraView.swift
//  Vinci
//
//  Created by Anessa Petteruti on 7/6/23.
//

import Foundation
import SwiftUI
import AVFoundation
import Speech
import Alamofire
import CoreML
import Vision
import os.log


struct CameraView: View {
    //    @State private var isCameraActive = false
    @State private var detectedObjects: [String] = []
    
    private let session = AVCaptureSession()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    var body: some View {
        VStack {
            if isCameraActive {
                // Display the camera preview
                CameraPreview(previewLayer: previewLayer)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                
                
                if !detectedObjects.isEmpty {
                    VStack {
                        Text("Detected Objects")
                            .font(.title)
                            .padding()
                        
                        List(detectedObjects, id: \.self) { object in
                            Text(object)
                        }
                    }
                }
            } else {
                // Show a placeholder or alternative content when the camera is inactive
                Text("Camera Inactive")
                    .font(.title)
                    .padding()
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .background).async {
                setupCamera()
                startCamera()
            }
        }
        .onDisappear {
            stopCamera()
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVCaptureSessionDidStartRunning)) { _ in
            performObjectRecognition()
        }
        
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Unable to access camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            if session.canAddInput(input) {
                session.addInput(input)
            }
            session.commitConfiguration()
            
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    private func startCamera() {
        session.startRunning()
        DispatchQueue.main.async {
            isCameraActive = true
        }
    }
    
    private func stopCamera() {
        session.stopRunning()
        DispatchQueue.main.async {
            isCameraActive = false
        }
    }
    
    private func performObjectRecognition() {
        session.beginConfiguration()
        
        // Remove any existing video data outputs
        for output in session.outputs {
            session.removeOutput(output)
        }
        
        // Add a new video data output
        let videoOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        } else {
            print("Unable to add video data output to the session")
            return
        }
        
        session.commitConfiguration()
        
        // Set the sample buffer delegate
        let delegate = SampleBufferDelegate(detectedObjects: $detectedObjects)
        videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue.global(qos: .default))
        
        
        // Configure the video connection orientation
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
    }
    
}

class SampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Binding var detectedObjects: [String]
    let model: YOLOv3
    let visionModel: VNCoreMLModel
    
    init(detectedObjects: Binding<[String]>) {
        _detectedObjects = detectedObjects
        model = try! YOLOv3(configuration: MLModelConfiguration())
        visionModel = try! VNCoreMLModel(for: model.model)
        super.init()
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let uiImage = UIImage(ciImage: ciImage)
        
        processImage(uiImage)
    }
    
    private func processImage(_ image: UIImage) {
        guard let pixelBuffer = image.pixelBuffer() else {
            print("Unable to create pixel buffer from image")
            return
        }
        
        
        let request = VNCoreMLRequest(model: visionModel, completionHandler: { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                print("Failed to process image with YOLOv3 model: \(error?.localizedDescription ?? "")")
                return
            }
            
            // Process the results
            let objects = results.map { observation in
                return observation.labels[0].identifier
            }
            
            
        })
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }
}


extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )
        
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let cgImage = cgImage, let cgContext = context else {
            return nil
        }
        
        cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect.zero)
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        print(view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}

