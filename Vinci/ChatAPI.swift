import Foundation
import Alamofire

class ChatAPI {
    static func getChatGPTResponse(userMessage: String) async throws -> String {
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
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(endpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON { response in
                    do {
                        switch response.result {
                        case .success(let value):
                            if let json = value as? [String: Any],
                               let choices = json["choices"] as? [[String: Any]],
                               let chatGPTResponse = choices.first?["message"] as? [String: String],
                               let content = chatGPTResponse["content"] {
                                continuation.resume(returning: content)
                                conversation.append("Vinci: \(content)")
//                                ConversationManager().conversation.append("Vinci: \(content)")
                                ConversationManager().addMessage("Vinci: \(content)")
                                print("THIS IS CONVERSATIONN", conversation)
                            } else {
                                throw NSError(domain: "ChatGPT response error", code: 0, userInfo: nil)
                            }
                        case .failure(let error):
                            throw error
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
