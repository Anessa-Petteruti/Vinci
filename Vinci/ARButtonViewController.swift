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


class ARButtonViewController: UIViewController, ARSCNViewDelegate {
    private var arView: ARSCNView!
    private var buttonNode: SCNNode!

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

        // Call addButtonNodeToScene()
        addButtonNodeToScene()

        // Add lighting to the scene
        addLighting()

        // Start the AR session
        startARSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the AR session when the view is about to disappear
        arView.session.pause()
    }

    func startARSession() {
        // Create and configure the AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal // Enable plane detection if needed

        // Run the AR session
        arView.session.run(configuration)
    }

    func addButtonNodeToScene() {
        // Create a rounded button geometry
        let buttonRadius: CGFloat = 0.05
        let buttonGeometry = SCNCylinder(radius: buttonRadius, height: 0.01)

        // Set the material for the button
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        buttonGeometry.materials = [material]

        // Create a node with the button geometry
        buttonNode = SCNNode(geometry: buttonGeometry)

        // Set the position and scale of the button node
        buttonNode.position = SCNVector3(0, 0, -1) // Adjust the position here
        buttonNode.scale = SCNVector3(1, 1, 1) // Adjust the scale here

        // Add the button node to the AR scene's root node
        arView.scene.rootNode.addChildNode(buttonNode)
    }

    func addLighting() {
        // Add an omni light to the scene for proper lighting and shading
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 1000
        lightNode.position = SCNVector3(0, 1, 0) // Adjust the position here

        arView.scene.rootNode.addChildNode(lightNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Handle updates to AR anchors if needed
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: arView)

        // Perform a hit test to check if the button node was tapped
        let hitTestResults = arView.hitTest(location, options: nil)
        guard let hitNode = hitTestResults.first?.node else { return }

        // Check if the tapped node is the button node
        if hitNode == buttonNode {
            openExternalLink()
        }
    }

    func openExternalLink() {
        guard let url = URL(string: "https://en.wikipedia.org/wiki/Wikipedia") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}


struct ARButtonHostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ARButtonViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
