import Foundation
import LangChain
import SwiftUI

public struct FindEntityTextResponseTool: BaseTool {
    
    public func name() -> String {
        "text response to user asking to find an object"
    }
    
    public func description() -> String {
        "use when you want to respond to the user to find an object and before you use the CameraBoxTool"
    }
    
    public func _run(args: String) throws -> String {
        conversation.append("Vinci: Let me see if I can find it!")
        
        // Return a success message or any relevant result
        return "Responded to user who wants to find an object"
    }
}
