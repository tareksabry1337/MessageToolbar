//
//  ImagePickerService.swift
//  MessageToolbar
//
//  Created by Vortex on 1/17/19.
//  Copyright © 2019 Vortex. All rights reserved.
//

import UIKit
import Photos

class ImagePickerService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private weak var viewController: (UIViewController & MessageToolbarDelegate)?
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        return imagePicker
    }()
    
    init(viewController: (UIViewController & MessageToolbarDelegate)?) {
        self.viewController = viewController
    }
    
    @objc func presentImagePicker() {
        requestPhotoLibraryAccess {
            self.viewController?.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            viewController?.didFinish?(picking: pickedImage)
        } else if let pickedImage = info[.originalImage] as? UIImage {
            viewController?.didFinish?(picking: pickedImage)
        }
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController?.didCancelPhotoPicking?()
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func requestPhotoLibraryAccess(completionHandler: @escaping () -> ()) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] authorizationStatus in
                guard let self = self else { return }
                if authorizationStatus == .authorized {
                    completionHandler()
                } else if authorizationStatus == .denied || authorizationStatus == .restricted {
                    self.viewController?.didDenyPhotoLibraryPermission?()
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                completionHandler()
            }
        case .denied, .restricted:
            viewController?.didDenyPhotoLibraryPermission?()
        }
    }
}
