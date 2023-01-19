//
//  Coordinator.swift
//  Time Tracker
//
//  Created by Mark McKeon on 19/12/2022.
//

import UIKit
import SwiftUI

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var picker: ImagePickerView
    
    init(picker: ImagePickerView) {
        self.picker = picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            guard let data = selectedImage.compress(to: 400) else {
                return
            }
            guard let compressedImage = UIImage(data: data) else {
                            // handle error
                            return
                        }
            self.picker.selectedImage = compressedImage
            self.picker.isPresented.wrappedValue.dismiss()
            
        } else {
            
            return
        }
    }
}

