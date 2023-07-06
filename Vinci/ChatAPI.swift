import Foundation
import Alamofire

class ChatAPI {
    func getChatGPTResponse(userMessage: String) throws -> String {
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
        
        let semaphore = DispatchSemaphore(value: 0) // Create a semaphore
        
        var chatGPTResponse: String?
        var responseError: Error?
        
        AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseJSON { response in
                do {
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any],
                           let choices = json["choices"] as? [[String: Any]],
                           let message = choices.first?["message"] as? [String: String],
                           let content = message["content"] {
                            chatGPTResponse = "Vinci: \(content)"
                        } else {
                            throw NSError(domain: "ChatGPT response error", code: 0, userInfo: nil)
                        }
                    case .failure(let error):
                        responseError = error
                    }
                } catch {
                    responseError = error
                }
                
                semaphore.signal() // Signal the semaphore to indicate completion
            }
        
        semaphore.wait() // Wait for the network request to complete
        
        if let error = responseError {
            throw error
        }
        
        if let response = chatGPTResponse {
            conversation.append(response)
            print("CONVERSATION IN CHATAPI", conversation)
            return response
        } else {
            throw NSError(domain: "ChatGPT response error", code: 0, userInfo: nil)
        }
    }
}
