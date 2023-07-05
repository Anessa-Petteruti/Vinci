import Foundation
import LangChain
import SwiftUI

public struct CameraBoxTool: BaseTool {
    @Binding var isCameraViewActive: Bool
    
    public init(isCameraViewActive: Binding<Bool>) {
        _isCameraViewActive = isCameraViewActive
    }
    
    public func name() -> String {
        "camera view and bounding box"
    }
    
    public func description() -> String {
        "use when you want to find an object"
    }
    
    public func _run(args: String) throws -> String {
        conversation.append("Vinci: Let me see if I can find it!")
        
        
//        Thread.sleep(forTimeInterval: 1)
        
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        DispatchQueue.main.async {
            isCameraViewActive = true
        }
        //        }
        
        
        
        // Return a success message or any relevant result
        return "Navigated to Camera View and finding object"
    }
}
