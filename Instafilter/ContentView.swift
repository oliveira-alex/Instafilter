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
    
    @State private var filterHasIntensity = false
    @State private var filterIntensity = 0.0
    @State private var filterHasRadius = false
    @State private var filterRadius = 0.0
    @State private var filterHasScale = false
    @State private var filterScale = 0.0
    
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
        
        let radius = Binding<Double>(
            get:{
                self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing()
            }
        )
        
        let scale = Binding<Double>(
            get:{
                self.filterScale
            },
            set: {
                self.filterScale = $0
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
                
                VStack {
                    if filterHasIntensity {
                        HStack {
                            Text("Intensity")
                                .frame(minWidth: 65, alignment: .leading)
                            Slider(value: intensity)
//                                .disabled((image != nil && filterHasIntensity) ? false : true)
                        }
                    }
                    if filterHasRadius {
                        HStack {
                            Text("Radius")
                                .frame(minWidth: 65, alignment: .leading)
                            Slider(value: radius)
//                                .disabled((image != nil && filterHasRadius) ? false : true)
                        }
                    }
                    if filterHasScale {
                        HStack {
                            Text("Scale")
                                .frame(minWidth: 65, alignment: .leading)
                            Slider(value: scale)
//                                .disabled((image != nil && filterHasScale) ? false : true)
                        }
                    }
                }
                .padding(.vertical)
                
                HStack {
                    Button(currentFilterName) {
                        guard let _ = self.image else {
                            showingNoImageErrorAlert = true
                            return
                        }
                        
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
                        Alert(title: Text("No Picture Selected"),
                              message: Text("You need to select an picture first."),
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
        if let _ = currentFilter {
            currentFilter?.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        } else {
            image = Image(uiImage: inputImage)
        }
    }
    
    func applyProcessing() {
//        currentFilter.intensity = Float(filterIntensity)
//        currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        if filterHasIntensity { currentFilter?.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if filterHasRadius { currentFilter?.setValue(filterRadius * 200, forKey: kCIInputRadiusKey) }
        if filterHasScale { currentFilter?.setValue (filterScale * 10, forKey: kCIInputScaleKey) }
        
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
        
        guard let inputKeys = currentFilter?.inputKeys else { return }
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter?.setValue(filterIntensity, forKey: kCIInputIntensityKey)
            filterHasIntensity = true
            filterIntensity = 0.5
        } else {
            filterHasIntensity = false
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter?.setValue(filterRadius * 200, forKey: kCIInputRadiusKey)
            filterHasRadius = true
            filterRadius = 0.5
        } else {
            filterHasRadius = false
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter?.setValue (filterScale * 10, forKey: kCIInputScaleKey)
            filterHasScale = true
            filterScale = 0.5
        } else {
            filterHasScale = false
        }
        
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
