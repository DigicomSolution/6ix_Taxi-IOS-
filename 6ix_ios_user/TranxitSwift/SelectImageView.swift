//
//  SelectImageView.swift
//  
//
//  Created by CSS on 07/03/18.
//

import UIKit
import ImagePicker
import Lightbox

class SelectImageView : NSObject{
    
private var completion : (([UIImage])->())?
    
   static let main = SelectImageView()
    
    func show(imagePickerIn view : UIViewController, completion : @escaping ([UIImage])->()){
        
        let config = IPConfiguration()
        config.allowPinchToZoom = true
        config.canRotateCamera = true
        config.doneButtonTitle = Constants.string.Done
        config.flashButtonAlwaysHidden = false
        config.requestPermissionTitle = ""
        config.requestPermissionMessage = "will add later"
        self.completion = completion
        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        view.present(imagePicker, animated: true, completion: nil)
        
    }
    
    
}


extension SelectImageView : ImagePickerDelegate {
    
    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            return LightboxImage(image: $0)
        }
        
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        imagePicker.dismiss(animated: true) {
            self.completion?(images)
        }
    }
    
}
