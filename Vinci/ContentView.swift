//
//  ContentView.swift
//  Vinci
//
//  Created by Anessa Petteruti on 6/25/23.
//

import SwiftUI
import AVFoundation
import Speech
import Alamofire
import CoreML
import Vision
import os.log
import LangChain
import Foundation
import NaturalLanguage
import ARKit


var highlightedObjects: [String] = []
var isCameraActive = false
var isCameraViewActive = false
var userInputGlobal = ""
var conversation: [String] = []
var isARActive = false

struct ContentView: View {
    @State private var isSecondScreenActive = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello")
                    .font(.interFont(size: 80, weight: .thin))
                
                Spacer().frame(height: 150)
                
                Button(action: {
                    isSecondScreenActive = true
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2.8)
                                .overlay(
                                    Arrow()
                                        .strokeBorder(.black, style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round))
                                    
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                    
                                )
                        ).animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true))
                }
                
            }
            .padding()
            .background(
                NavigationLink(
                    destination: SecondView(selectedTab: 1),
                    isActive: $isSecondScreenActive,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            )
        }
    }
}


struct SecondView: View {
    @State private var selectedTab = 1
    
    init(selectedTab: Int) {
        self._selectedTab = State(initialValue: selectedTab)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(1...3, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Text("Tab \(index)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTab == index ? Color.white : Color.black)
                            .foregroundColor(selectedTab == index ? Color.black : Color.white)
                    }
                }
            }
            .frame(height: 50)
            
            TabView(selection: $selectedTab) {
                Tab1View()
                    .tag(1)
                
                Tab2View()
                    .tag(2)
                
                Tab3View()
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width < 0 {
                            selectedTab = min(selectedTab + 1, 3)
                        } else if gesture.translation.width > 0 {
                            selectedTab = max(selectedTab - 1, 1)
                        }
                    }
            )
        }
    }
}

struct Tab1View: View {
    var body: some View {
        ChatView()
    }
}

struct Tab2View: View {
    var body: some View {
        VStack{
            if isARActive {
                ARHostedViewController().ignoresSafeArea()
            } else {
                HostedViewController().ignoresSafeArea()
            }
            
        }
    }
}

struct Tab3View: View {
    var body: some View {
        VStack {
            Text("My artifacts, scenes, Marketplace goes here")
        }
    }
}


struct Arrow: InsettableShape {
    var insetAmount = 0.0
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let verticalOffset = insetAmount * 0.001
        
        path.move(to: CGPoint(x: insetAmount, y: rect.midY - verticalOffset))
        path.addLine(to: CGPoint(x: rect.width - insetAmount, y: rect.midY - verticalOffset))
        path.addLine(to: CGPoint(x: rect.width - rect.width * 0.33, y: insetAmount + verticalOffset)) // Adjusted the sign here
        path.move(to: CGPoint(x: rect.width - insetAmount, y: rect.midY - verticalOffset))
        path.addLine(to: CGPoint(x: rect.width - rect.width * 0.33, y: rect.height - insetAmount + verticalOffset)) // Adjusted the sign here
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arrow = self
        arrow.insetAmount += amount
        return arrow
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.8)
            .stroke(Color.black, lineWidth: 5)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear {
                isAnimating = true
            }
            .onDisappear {
                isAnimating = false
            }
            .zIndex(1) // Set a higher zIndex to bring the loading indicator to the front
    }
}



struct ARPreview: UIViewRepresentable {
    let arView: ARSCNView
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect.zero)
        arView.frame = view.bounds
        view.addSubview(arView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        arView.frame = uiView.bounds
    }
}

struct ARContentView: View {
    let arView = ARSCNView()

    var body: some View {
        ARPreview(arView: arView)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Set up ARKit session and configuration here
                let configuration = ARWorldTrackingConfiguration()
                arView.session.run(configuration)
            }
            .onDisappear {
                // Pause ARKit session when the view disappears
                arView.session.pause()
            }
    }
}

// AR VIEW STARTS HERE
//struct ARClockView: View {
//    @State private var currentTime = Date()
//
//    var body: some View {
//        VStack {
//            ARSceneView(currentTime: $currentTime)
//                .frame(width: 300, height: 300)
//
//            Text(currentTimeAsString)
//                .font(.title)
//        }
//        .onAppear {
//            updateCurrentTime()
//        }
//    }
//
//    private func updateCurrentTime() {
//        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            currentTime = Date()
//        }
//        timer.fire()
//    }
//
//    private var currentTimeAsString: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter.string(from: currentTime)
//    }
//}
//
//struct ARSceneView: UIViewRepresentable {
//    @Binding var currentTime: Date
//
//    func makeUIView(context: Context) -> ARSCNView {
//        let arView = ARSCNView()
//
//        // Set up the AR scene and add the AR artifacts
//        // Use ARKit APIs to configure the AR scene and add 3D objects
//        // ...
//
//        // Update the clock artifact in the AR scene based on the current time
//        let clockNode = SCNNode()
//        arView.scene.rootNode.addChildNode(clockNode)
//
//        let clockGeometry = SCNText(string: getCurrentTimeAsString(), extrusionDepth: 0.1)
//        // Configure the clock geometry and appearance
//        // ...
//        clockNode.geometry = clockGeometry
//
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARSCNView, context: Context) {
//        // Update the AR scene if needed
//        // Use ARKit APIs to update the AR scene or adjust the clock artifact
//        // ...
//
//        // Update the clock geometry based on the current time
//        if let clockNode = uiView.scene.rootNode.childNode(withName: "clock", recursively: true) {
//            clockNode.geometry = SCNText(string: getCurrentTimeAsString(), extrusionDepth: 0.1)
//            // Configure the updated clock geometry and appearance
//            // ...
//        }
//    }
//
//    private func getCurrentTimeAsString() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        return formatter.string(from: currentTime)
//    }
//}
//
//class ARSceneViewCoordinator: NSObject, ARSessionDelegate {
//    static let shared = ARSceneViewCoordinator()
//    private var session: ARSession?
//
//    private override init() {
//        super.init()
//    }
//
//    func startARSession(_ configuration: ARConfiguration) {
//        session = ARSession()
//        session?.delegate = self
//        session?.run(configuration)
//        print("AR STARTED")
//    }
//
//    func stopARSession() {
//        session?.pause()
//        session = nil
//    }
//
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        // Handle AR session updates if needed
//    }
//
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        // Handle new AR anchors if needed
//    }
//
//    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
//        // Handle removed AR anchors if needed
//    }
//
//    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        // Handle updated AR anchors if needed
//    }
//
//    // Implement other ARSessionDelegate methods as required
//}



extension Font {
    static func interFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let font = UIFont(name: "Inter-\(weight)", size: size) {
            return Font(font)
        }
        return Font.system(size: size, weight: weight)
    }
}
