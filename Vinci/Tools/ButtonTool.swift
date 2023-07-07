import Foundation
import LangChain
import SwiftUI

public struct ButtonTool: BaseTool {
    @Binding var isARButtonViewActive: Bool
    
    public init(isARButtonViewActive: Binding<Bool>) {
        _isARButtonViewActive = isARButtonViewActive
    }
    
    public func name() -> String {
        "camera to display an interactive button that takes the user to a link"
    }
    
    public func description() -> String {
        "use when the user asks to be taken to Wikipedia"
    }
    
    public func _run(args: String) throws -> String {
        
        DispatchQueue.main.async {
            isARButtonViewActive = true
            isARButtonActive = true
            isARActive = false
            isCameraViewActive = false
        }
        
        // Return a success message or any relevant result
        return "Navigated to Camera View and displaying button"
    }
}
