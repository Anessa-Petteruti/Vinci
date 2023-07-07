//
//  ChatView.swift
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
import LangChain
import NaturalLanguage

var highlightedObjects: [String] = []
var allObservations: [String] = [] // added this here with segmentation work


struct ChatView: View {
    //    @State private var conversation: [String] = []
    @State private var userInput = ""
    @State private var scrollToBottom = true // Track whether to scroll to the bottom
    
    @State private var isCameraViewActive = false // Passed into tool
    @State private var isCameraClockViewActive = false // Passed into tool
    @State private var isARButtonViewActive = false // Passed into tool
    
    @State private var llm = OpenAI()
    @State private var agent: AgentExecutor?
    
    @State private var isLoading = false
//    private let chatGPTTool = ChatGPTTool()
    
    
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
                                    .onAppear {
                                        print("CONVOOO", conversation)
                                    }
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
            .onChange(of: conversation) { _ in
                scrollToBottom = true
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
            
            
            if isLoading {
                LoadingIndicator()
                    .padding()
            }
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            clearTextField()
        }
        .background(
            NavigationLink(
                destination: SecondView(selectedTab: 2),
                isActive: $isCameraViewActive,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        )
        .background(
            NavigationLink(
                destination: SecondView(selectedTab: 2),
                isActive: $isCameraClockViewActive,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        )
        .background(
            NavigationLink(
                destination: SecondView(selectedTab: 2),
                isActive: $isARButtonViewActive,
                label: {
                    EmptyView()
                }
            )
            .hidden()
        )
        
    }
    
    
    func sendMessage() {
        let userMessage = userInput
        userInputGlobal = userInput
        conversation.append("You: \(userMessage)")
        
        DispatchQueue.main.async {
            userInput = ""
        }
        
        isLoading = true
        
        // Reset highlightedObjects so it doesn't display bounding boxes of previous run
        highlightedObjects = []
        
        // Collapse the keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        // ACTIVATES TOOL:
        agent = initialize_agent(llm: llm, tools: [ChatGPTTool(), ButtonTool(isARButtonViewActive: $isARButtonViewActive), CameraClockTool(isCameraClockViewActive: $isCameraClockViewActive), WeatherTool(), CameraBoxTool(isCameraViewActive: $isCameraViewActive)])
        
        
        Task {
            if let agent = agent {
                let answer = await agent.run(args: userMessage)
                
                let entities = agent.agent.getInputs()
                
                let fieldKeyword = "Action Input:"
                var extractedInputs: [String] = []
                
                for entity in entities {
                    let actionLog = entity.0.log
                    if let range = actionLog.range(of: fieldKeyword) {
                        let inputStartIndex = range.upperBound
                        let inputSubstring = actionLog[inputStartIndex...]
                        let input = String(inputSubstring.trimmingCharacters(in: .whitespacesAndNewlines))
                        
                        // Remove slashes and quotes from the input
                        let cleanedInput = input.replacingOccurrences(of: #"[\\"]"#, with: "", options: .regularExpression)
                        
                        // Split the cleaned input into individual words
                        let words = cleanedInput.components(separatedBy: .whitespaces)
                        
                        // Filter out the word "and" from the words array
                        let filteredWords = words.filter { $0.lowercased() != "and" }
                        
                        // Append individual words to the extractedInputs array
                        extractedInputs.append(contentsOf: filteredWords)
                    }
                }
                
                print("FINAL EXTRACTED ENTITIES", extractedInputs)
                
                
                // Perform word similarity using NLEmbedding
                var similarWords: [String] = []
                
                if let embedding = NLEmbedding.wordEmbedding(for: .english) {
                    
                    for entity in extractedInputs {
                        var maxSimilarity: Float = 0.8
                        var similarWord: String = ""
                        var foundExactMatch = false
                        print("ALL OBSERVATIONS IN CHAT", allObservations)
                        for observation in allObservations {
                            let similarity = Float(embedding.distance(between: entity, and: observation))
                            print("SIMILARITY", observation, similarity)
                            
                            // Stop if you have found exact match:
                            if similarity == 0.0 {
                                similarWords.append(entity)
                                foundExactMatch = true
                                break
                            } else if similarity < maxSimilarity {
                                print("LESS THAN")
                                maxSimilarity = similarity
                                similarWord = observation
                            }
                        }
                        
                        if !foundExactMatch {
                            print(similarWord)
                            similarWords.append(similarWord)
                        }
                    }
                }
       
                print("SIMILAR", similarWords)
                highlightedObjects = similarWords

                isLoading = false
                
            } else {
                print("Agent not initialized")
            }
        }
        
//        if (isCameraClockViewActive || isARActive || isCameraViewActive || isARButtonViewActive || isARButtonActive) {
//            print("CAMERA VIEW ACTIVE", isCameraViewActive)
//            print("NOT REQUESTING CHATGPT")
//        }
//        else {
//            // Make a request to ChatGPT
//            let chatGPTResponse = getChatGPTResponse(userMessage: userMessage)
//            print("IN CHAT GPT REQUEST AREA")
//        }
        
        
        isLoading = false
    }
    
    func clearTextField() {
        userInput = ""
    }
    
//    func getChatGPTResponse(userMessage: String) {
//        let apiKey = "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"
//        let endpoint = "https://api.openai.com/v1/chat/completions"
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(apiKey)",
//            "Content-Type": "application/json"
//        ]
//        let parameters: Parameters = [
//            "model": "gpt-3.5-turbo",
//            "messages": [
//                ["role": "system", "content": "You are a helpful assistant."],
//                ["role": "user", "content": userMessage]
//            ]
//        ]
//
//        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .validate()
//            .responseJSON { response in
//                switch response.result {
//                case .success(let value):
//                    if let json = value as? [String: Any],
//                       let choices = json["choices"] as? [[String: Any]],
//                       let chatGPTResponse = choices.first?["message"] as? [String: String],
//                       let content = chatGPTResponse["content"] {
//                        DispatchQueue.main.async {
//                            conversation.append("Vinci: \(content)")
//                            scrollToBottom = true // Re-enable automatic scrolling after appending AI reply
//                        }
//                    }
//                case .failure(let error):
//                    print("Error making ChatGPT request: \(error.localizedDescription)")
//                }
//            }
//    }

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
