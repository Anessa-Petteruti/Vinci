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
        VStack {
            Text("Hello")
                .font(.interFont(size: 80, weight: .thin))
            Button(action: {
                isSecondScreenActive = true
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 70, weight: .thin))
                    .foregroundColor(.black)
            }
        }
        .padding()
        NavigationLink(
            destination: SecondView(),
            isActive: $isSecondScreenActive,
            label: {
                EmptyView()
            }
        )
        .hidden()
    }
}

struct SecondView: View {
    var body: some View {
        Text("Second Screen")
            .font(.interFont(size: 24, weight: .bold))
            .padding()
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
