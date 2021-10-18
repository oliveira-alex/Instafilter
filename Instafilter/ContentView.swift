//
//  ContentView.swift
//  Instafilter
//
//  Created by Alex Oliveira on 18/10/21.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)
    }
    
    func loadImage() {
        guard let inputImage = UIImage(named: "Example") else { return }
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
//        let currentFilter = CIFilter.sepiaTone()
//        let currentFilter = CIFilter.crystallize()
        guard let currentFilter = CIFilter(name: "CITwirlDistortion") else { return }
        
//        currentFilter.intensity = 1 // for sepiaTone
//        currentFilter.inputImage = beginImage  // new way of set inputImage (doesn't work for all kinds of filters)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey) // old way of set inputImage
//        currentFilter.radius = 200 // for crystallize
        currentFilter.setValue(2000, forKey: kCIInputRadiusKey)
        currentFilter.setValue(CIVector(x: inputImage.size.width / 2, y: inputImage.size.height / 2), forKey: kCIInputCenterKey)
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
