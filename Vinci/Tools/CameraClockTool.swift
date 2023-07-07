import Foundation
import LangChain
import SwiftUI

public struct CameraClockTool: BaseTool {
    @Binding var isCameraClockViewActive: Bool
    
    public init(isCameraClockViewActive: Binding<Bool>) {
        _isCameraClockViewActive = isCameraClockViewActive
    }
    
    public func name() -> String {
        "camera to display a clock with the current time on it"
    }
    
    public func description() -> String {
        "use when the user asks what the time is and you want to display the time on a clock"
    }
    
    public func _run(args: String) throws -> String {
        
        DispatchQueue.main.async {
            isCameraClockViewActive = true
            isARActive = true
            isCameraViewActive = false
            isARButtonActive = false
        }
        
        // Return a success message or any relevant result
        return "Navigated to Camera View and displaying clock to tell time"
    }
}
