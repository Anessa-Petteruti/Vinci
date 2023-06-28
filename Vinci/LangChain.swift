
import Foundation
// need to define TextResponseTool() and BoundingBoxTool()
public struct BoundingBoxTool: BaseTool {
    public init() {}
    public func name() -> String {
        "Bounding box"
    }
    
    public func description() -> String {
        "useful for drawing attention to an object by drawing a bounding box around it"
    }
    
    public func _run(args: String) throws -> nil {
        DispatchQueue.main.async {
        self.setupDetector()
        self.setupLayers()
    }
    // Return a success message or any relevant result
    return "Bounding box detection started."
    }
    
    
}

let query = "please point out the water bottle"

let agent = initialize_agent(llm: llm, tools: [TextResponseTool(), BoundingBoxTool()])
let answer = await agent.run(args: query)
print(answer) // should draw a bounding box around the water bottles AND print something like "sure, I've here are all the boxes in the frame"

