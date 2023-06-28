

// need to define TextResponseTool() and BoundingBoxTool()

let query = "please point out the water bottle"

let agent = initialize_agent(llm: llm, tools: [TextResponseTool(), BoundingBoxTool()])
let answer = await agent.run(args: query)
print(answer) // should draw a bounding box around the water bottles AND say something like "sure, I've here are all the boxes in the frame"

