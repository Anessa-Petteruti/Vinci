//
//  ViewController.swift
//  Vinci
//
//  Created by Anessa Petteruti on 6/28/23.
//

import Foundation
import UIKit
import SwiftUI
import Vision
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    private var arView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the ARSCNView
        arView = ARSCNView(frame: view.bounds)
        arView.delegate = self

        // Configure the ARSCNView
        let scene = SCNScene()
        arView.scene = scene

        // Add the ARSCNView to the view hierarchy
        view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Call addCubeToScene()
        addCubeToScene()

        // Start the AR session
        startARSession()
    }

    func startARSession() {
        // Create and configure the AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal // Enable plane detection if needed

        // Run the AR session
        arView.session.run(configuration)
    }

    func addCubeToScene() {
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        cubeNode.position = SCNVector3(0, 0, -1) // Adjust the position here
        arView.scene.rootNode.addChildNode(cubeNode)
    }

    // ARSCNViewDelegate methods for updating the AR scene
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Handle updates to AR anchors if needed
    }
}


struct ARHostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ARViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
