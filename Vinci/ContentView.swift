//
//  ContentView.swift
//  Vinci
//
//  Created by Anessa Petteruti on 6/25/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isSecondScreenActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello")
                    .font(.interFont(size: 80, weight: .thin))
                
                Spacer().frame(height: 150)
                
                Button(action: {
                    isSecondScreenActive = true
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2.8)
                                .overlay(
                                    Arrow()
                                        .strokeBorder(.black, style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round))
                                    
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                    
                                )
                        ).animation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true))
                }
                
            }
            .padding()
            .background(
                NavigationLink(
                    destination: SecondView(),
                    isActive: $isSecondScreenActive,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            )
        }
    }
}


struct SecondView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(1...3, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Text("Tab \(index)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTab == index ? Color.white : Color.black)
                            .foregroundColor(selectedTab == index ? Color.black : Color.white)
                    }
                }
            }
            .frame(height: 50)
            
            TabView(selection: $selectedTab) {
                Text("Tab 1")
                    .tabItem {
                        Image(systemName: "1.circle")
                        Text("Tab 1")
                    }
                    .tag(1)
                
                Text("Tab 2")
                    .tabItem {
                        Image(systemName: "2.circle")
                        Text("Tab 2")
                    }
                    .tag(2)
                
                Text("Tab 3")
                    .tabItem {
                        Image(systemName: "3.circle")
                        Text("Tab 3")
                    }
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width < 0 {
                            selectedTab = min(selectedTab + 1, 3)
                        } else if gesture.translation.width > 0 {
                            selectedTab = max(selectedTab - 1, 1)
                        }
                    }
            )
        }
    }
}



struct Arrow: InsettableShape {
    var insetAmount = 0.0
    
    var animatableData: Double {
        get { insetAmount }
        set { insetAmount = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let verticalOffset = insetAmount * 0.001
        
        path.move(to: CGPoint(x: insetAmount, y: rect.midY - verticalOffset))
        path.addLine(to: CGPoint(x: rect.width - insetAmount, y: rect.midY - verticalOffset))
        path.addLine(to: CGPoint(x: rect.width - rect.width * 0.33, y: insetAmount + verticalOffset)) // Adjusted the sign here
        path.move(to: CGPoint(x: rect.width - insetAmount, y: rect.midY - verticalOffset))
        path.addLine(to: CGPoint(x: rect.width - rect.width * 0.33, y: rect.height - insetAmount + verticalOffset)) // Adjusted the sign here
        
        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arrow = self
        arrow.insetAmount += amount
        return arrow
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Font {
    static func interFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let font = UIFont(name: "Inter-\(weight)", size: size) {
            return Font(font)
        }
        return Font.system(size: size, weight: weight)
    }
}
