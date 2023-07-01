import Foundation
import LangChain
import SwiftUI

// need to define TextResponseTool() and BoundingBoxTool()
public struct CameraBoxTool: BaseTool {
    @Binding var isCameraViewActive: Bool
    
    public init(isCameraViewActive: Binding<Bool>) {
        _isCameraViewActive = isCameraViewActive
    }
    
    public func name() -> String {
        "Bounding box"
    }
    
    public func description() -> String {
        "use when you want to find an object"
    }
    
    public func _run(args: String) throws -> String {
        DispatchQueue.main.async {
            isCameraViewActive = true
            print("CAMERA ACTIVE", isCameraViewActive)
        }
        
        // Return a success message or any relevant result
        return "Bounding box detection started."
    }
}
