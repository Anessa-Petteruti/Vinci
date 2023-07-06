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
import ARKit


class ARViewController: UIViewController, ARSCNViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
    
    // Detector
    private var videoOutput = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()
    var detectionLayer: CALayer! = nil
    private var arView: ARSCNView!
    
    
    
    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            
            //            self.setupLayers()
            //            self.setupDetector()
            print("ACTIVATING AR VIEW CONTROLLER")
            
            self.captureSession.startRunning()
            
            // Create the ARSCNView
            arView = ARSCNView(frame: view.bounds)
            arView.delegate = self
            
            // Configure the ARSCNView
            let scene = SCNScene()
            arView.scene = scene
            
            // Add the ARSCNView to the view hierarchy
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.addSubview(self.arView)
                self.arView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    self.arView.topAnchor.constraint(equalTo: self.view.topAnchor),
                    self.arView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    self.arView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    self.arView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                ])
                
                // Add the preview layer on top of the ARSCNView
                self.view.layer.addSublayer(self.previewLayer)
                
                // Call addCubeToScene()
                self.addCubeToScene()
            }
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
        //        updateLayers()
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
        
        // Create the ARSCNView
//        arView = ARSCNView(frame: view.bounds)
//        arView.delegate = self
//
//        // Configure the ARSCNView
//        let scene = SCNScene()
//        arView.scene = scene
        
        print("IN CAPTURE SESSION AR")
        
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
    
    func addCubeToScene() {
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        cubeNode.position = SCNVector3(0, 0, -0.5)
        arView.scene.rootNode.addChildNode(cubeNode)
        print("AFTER ADDING CUBE")
        print("CUBE POSITION", cubeNode.position)
    }
    
}

struct ARHostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ARViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
