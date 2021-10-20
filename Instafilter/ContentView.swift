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
    enum FilterNames: String {
        case Crystallize
    }
    
    @State private var image: Image?
    @State private var filterIntensity = 0.0
    
    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var showingNoImageErrorAlert = false
    
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State var currentFilter: CIFilter?
    @State private var currentFilterName = "Select a Filter"
    let context = CIContext()
    
    var body: some View {
        let intensity = Binding<Double>(
            get:{
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                    
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                        .disabled(image == nil ? true : false)
                }
                .padding(.vertical)
                
                HStack {
                    Button(currentFilterName) {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        guard let processedImage = self.processedImage else {
                            showingNoImageErrorAlert = true
                            return
                        }
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
//                    .disabled(image == nil ? true : false)
                    .alert(isPresented: $showingNoImageErrorAlert) {
                        Alert(title: Text("No Image Selected"),
                              message: Text("You need to select an image first."),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()) },
                    .default(Text("Edges")) { self.setFilter(CIFilter.edges()) },
                    .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()) },
                    .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()) },
                    .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()) },
                    .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()) },
                    .default(Text("Vignette")) { self.setFilter(CIFilter.vignette() )},
                    .cancel()
                ])
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
//        image = Image(uiImage: inputImage)
        

        let beginImage = CIImage(image: inputImage)
        guard let _ = currentFilter else { return }
        filterIntensity = 0.5
        currentFilter?.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
//        currentFilter.intensity = Float(filterIntensity)
//        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        guard let inputKeys = currentFilter?.inputKeys else { return }
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter?.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter?.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter?.setValue (filterIntensity * 10, forKey: kCIInputScaleKey) }
        
        guard let outputImage = currentFilter?.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        currentFilterName = String(currentFilter!.name.dropFirst(2))
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
