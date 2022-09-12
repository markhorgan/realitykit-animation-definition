// Copyright (c) 2022 Mark Horgan
//
// This source code is for individual learning purposes only. You may not copy,
// modify, merge, publish, distribute, create a derivative work or sell copies
// of the software in any work that is intended for pedagogical or
// instructional purposes.

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var animationType: AnimationType = .none
    
    var body: some View {
        VStack {
            ARViewContainer(animationType: $animationType).edgesIgnoringSafeArea([.top, .leading, .trailing])
            Menu {
                Button("From To By") {
                    animationType = .fromToBy
                }
                Button("Sampled") {
                    animationType = .sampled
                }
                Button("Orbit") {
                    animationType = .orbit
                }
                Button("Blend Tree") {
                    animationType = .blendTree
                }
                Button("Animation View") {
                    animationType = .animationView
                }
                Button("Animation Group") {
                    animationType = .animationGroup
                }
            } label: {
                Text("Animation Types")
                    .frame(height: 44)
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var animationType: AnimationType
    
    func makeUIView(context: Context) -> CustomARView {
        return CustomARView(frame: .zero)
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {
        uiView.runAnimation(animationType)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
