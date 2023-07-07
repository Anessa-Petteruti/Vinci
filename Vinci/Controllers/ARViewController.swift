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
    private var timeNode: SCNNode!

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

        // Call addTimeNodeToScene()
        addTimeNodeToScene()

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

    func addTimeNodeToScene() {
        let textGeometry = SCNText(string: getCurrentTime(), extrusionDepth: 0.1)
        textGeometry.font = UIFont.systemFont(ofSize: 0.2)
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue

        timeNode = SCNNode(geometry: textGeometry)
        timeNode.position = SCNVector3(0, 0, -1) // Adjust the position here
        timeNode.scale = SCNVector3(0.2, 0.2, 0.2) // Adjust the scale here

        arView.scene.rootNode.addChildNode(timeNode)
    }

    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }

    func addLighting() {
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 1000
        directionalLight.castsShadow = true

        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.eulerAngles = SCNVector3(-Float.pi / 4, 0, 0) // Adjust the direction of the light

        arView.scene.rootNode.addChildNode(directionalNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Update the text geometry to display the current time
        let currentTime = getCurrentTime()
        if let textGeometry = timeNode.geometry as? SCNText {
            textGeometry.string = currentTime
        }
    }
}

struct ARHostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ARViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
