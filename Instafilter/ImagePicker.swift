//
//  ImagePicker.swift
//  Instafilter
//
//  Created by Alex Oliveira on 18/10/21.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    //    typealias UIViewControllerType = UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
}
