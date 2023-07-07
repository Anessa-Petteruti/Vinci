import Foundation
import LangChain
import SwiftUI

public struct DummyTool: BaseTool {
    public func name() -> String {
        "text response to user asking about anything other than finding an object"
    }
    
    public func description() -> String {
        "use when you want to respond to the user when they are not asking you to find an object"
    }
    
    public func _run(args: String) throws -> String {
        return "hello"
    }
}
