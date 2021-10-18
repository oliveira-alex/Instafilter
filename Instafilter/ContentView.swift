//
//  ContentView.swift
//  Instafilter
//
//  Created by Alex Oliveira on 18/10/21.
//

import SwiftUI

struct ContentView: View {
    @State private var blurAmount: CGFloat = 0 {
        didSet {
            print("New value is \(blurAmount)") // Now it gets printed, because of the new binding set
        }
    }
    
    var body: some View {
        let blur = Binding<CGFloat>(
            get: { self.blurAmount },
            set: { self.blurAmount = $0 }
        )
        
        VStack {
            Text("Hello, world!")
                .blur(radius: blurAmount)
            
            Slider(value: blur, in: 0...20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
