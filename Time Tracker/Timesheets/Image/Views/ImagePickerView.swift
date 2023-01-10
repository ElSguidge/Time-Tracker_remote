//
//  ImagePickerView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 19/12/2022.
//
import UIKit
import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    
    
    @Binding var selectedImage: UIImage?
    
    
    @Environment(\.presentationMode) var isPresented
    
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
}
