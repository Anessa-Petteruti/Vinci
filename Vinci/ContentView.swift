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
                    destination: SecondView(),
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
        CameraView()
    }
}

struct Tab3View: View {
    var body: some View {
        VStack {
            Text("My artifacts, scenes, profile")
                .font(.title)
                .padding()
            
            // Add more content specific to Tab 3
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



struct ChatView: View {
    @State private var conversation: [String] = []
    @State private var userInput = ""
    @State private var scrollToBottom = true // Track whether to scroll to the bottom
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(conversation, id: \.self) { message in
                            if message.starts(with: "Vinci:") {
                                let parts = message.split(separator: ":", maxSplits: 1)
                                if let name = parts.first, let content = parts.last {
                                    HStack(alignment: .top) {
                                        Text(name.trimmingCharacters(in: .whitespaces))
                                            .bold()
                                            .font(.interFont(size: 16, weight: .semibold))
                                                                                
                                        Text(content.trimmingCharacters(in: .whitespaces))
                                            .font(.interFont(size: 16, weight: .light))
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .id(UUID())
                                    .padding()
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            } else {
                                let parts = message.split(separator: ":", maxSplits: 1)
                                if let name = parts.first, let content = parts.last {
                                    HStack(alignment: .top) {
                                        Text(name.trimmingCharacters(in: .whitespaces))
                                            .bold()
                                            .font(.interFont(size: 16, weight: .semibold))
                                                                                
                                        Text(content.trimmingCharacters(in: .whitespaces))
                                            .font(.interFont(size: 16, weight: .light))
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .id(UUID())
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding()
                    .onChange(of: conversation, perform: { _ in
                        // Scroll to the bottom when the conversation updates
                        if scrollToBottom {
                            withAnimation {
                                scrollView.scrollTo(conversation.count - 1, anchor: .bottom)
                            }
                        }
                    })
                    .background(Color.clear)
                }
            }
            .onAppear {
                scrollToBottom = true // Scroll to the bottom on initial appearance
            }
            
            HStack {
                TextField("Enter your message", text: $userInput, onCommit: sendMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .font(.system(size: 16, weight: .light))
                
                Button(action: sendMessage) {
                    Text("Send")
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(4)
                        .font(.system(size: 16, weight: .light))
                }
                .padding()
                .disabled(userInput.isEmpty)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            clearTextField()
        }
    }
    
    func sendMessage() {
        let userMessage = userInput
        conversation.append("You: \(userMessage)")
        
        // Make a request to ChatGPT
        let chatGPTResponse = getChatGPTResponse(userMessage: userMessage)
        
        clearTextField()
    }
    
    func clearTextField() {
        userInput = ""
    }
    
    func getChatGPTResponse(userMessage: String) -> String {
        let apiKey = "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"
        let endpoint = "https://api.openai.com/v1/chat/completions"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        let parameters: Parameters = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": userMessage]
            ]
        ]
        
        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let chatGPTResponse = choices.first?["message"] as? [String: String],
                       let content = chatGPTResponse["content"] {
                        scrollToBottom = false // Disable automatic scrolling while appending AI reply
                        // Update the UI with the response from ChatGPT
                        DispatchQueue.main.async {
                            self.conversation.append("Vinci: \(content)")
                            scrollToBottom = true // Re-enable automatic scrolling after appending AI reply
                        }
                    }
                case .failure(let error):
                    print("Error making ChatGPT request: \(error.localizedDescription)")
                }
            }
        
        return ""  // Return an empty string for now, as the actual response will be updated asynchronously
    }
}

struct ChatGPTResponse: Decodable {
    struct Choice: Decodable {
        let text: String
    }
    
    let choices: [Choice]
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
    }
}

struct CameraView: View {
    @State private var isCameraActive = false
    private let session = AVCaptureSession()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    var body: some View {
        VStack {
            if isCameraActive {
                // Display the camera preview
                CameraPreview(previewLayer: previewLayer)
            } else {
                // Show a placeholder or alternative content when camera is inactive
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
}



extension Font {
    static func interFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let font = UIFont(name: "Inter-\(weight)", size: size) {
            return Font(font)
        }
        return Font.system(size: size, weight: weight)
    }
}
