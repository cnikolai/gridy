//
//  ViewController.swift
//  Gridy
//
//  Created by Cynthia Nikolai on 12/8/20.
//  Copyright © 2020 Cynthia Nikolai. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate  {

    var localImages = [UIImage].init()
    var creation = Creation.init()
    var initialImageViewOffset = CGPoint()
    
    @IBOutlet weak var LocalPicture: UIImageView!
    @IBOutlet weak var PhotoLibraryPicture: UIImageView!
    @IBOutlet weak var CameraPicture: UIImageView!
    
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

            let noPermissionMessage = "Looks like FrameIT have access to your camera:( Please use Setting app on your device to permit FrameIT accessing your camera"

            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            }
        }
        else {
            troubleAlert(message: "Sincere apologies, it looks like we can't access your camera at this time")
        }
    }

    func displayLibrary() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionMessage = "Looks like Gridy doesn't have access to your photos:( Please use Setting app on your device to permit Gridy accessing your library"

            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            }
        }
        else {
            troubleAlert(message: "Sincere apologies, it looks like we can't access your photo library at this time")
        }
    }

    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let newImage = info[.originalImage] as? UIImage
        processPicked(image: newImage)
    }

    func troubleAlert(message: String?) {
        let alertController = UIAlertController(title: "Oops...", message:message , preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Got it", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }

    func pickRandom() {
        processPicked(image: randomImage())
    }

    func randomImage() -> UIImage? {

        let currentImage = creation.image

        if localImages.count > 0 {
            while true {
                let randomIndex = Int(arc4random_uniform(UInt32(localImages.count)))
                let newImage = localImages[randomIndex]
                if newImage != currentImage {
                    return newImage
                }
            }
        }
        return nil
    }

    func collectLocalImageSet() {
        localImages.removeAll()
        let imageNames = ["Boats", "Car", "Crocodile", "Park", "TShirts"]

        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImages.append(image)
            }
        }
    }
    
    func processPicked(image: UIImage?) {
         if let newImage = image {
             creation.image = newImage
             //LocalPicture.image = creation.image
             animateImageChange()
         }
     }
     
     func animateImageChange() {
         UIView.transition(with: self.LocalPicture, duration: 0.4, options: .transitionCrossDissolve, animations: {
             self.LocalPicture.image = self.creation.image
         }, completion: nil)
     }
    
    func displayImagePickingOptions() {
        let storyboard = UIStoryboard(name: "ImageEditor", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageEditorViewController") as! ImageEditorViewController
        viewController.image = UIImage.init(named: "Car")!
        present(viewController, animated: true)
        
//        let alertController = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)
//
//        // create camera action
//        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (action) in
//            self.displayCamera()
//        }
//
//        // add camera action to alert controller
//        alertController.addAction(cameraAction)
//
//        // create library action
//        let libraryAction = UIAlertAction(title: "Library pick", style: .default) { (action) in
//            self.displayLibrary()
//        }
//
//        // add library action to alert controller
//        alertController.addAction(libraryAction)
//
//        // create random action
//        let randomAction = UIAlertAction(title: "Random", style: .default) { (action) in
//            self.pickRandom()
//        }
//
//        // add random action to alert controller
//        alertController.addAction(randomAction)
//
//        // create cancel action
//        let canceclAction = UIAlertAction(title: "Cancel", style: .cancel)
//
//        // add cancel action to alert controller
//        alertController.addAction(canceclAction)
//
//        present(alertController, animated: true) {
//            // code to execute after the controller finished presenting
//        }
    }


    func configure() {
           // collect images
           collectLocalImageSet()

           // apply creation data to the views
           LocalPicture.image = creation.image
           
           LocalPicture.isUserInteractionEnabled = true

           // create tap gesture recognizer
           let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
           tapGestureRecognizer.delegate = self
           LocalPicture.addGestureRecognizer(tapGestureRecognizer)
           
           let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
           panGestureRecognizer.delegate = self
           LocalPicture.addGestureRecognizer(panGestureRecognizer)
           
           let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
           rotationGestureRecognizer.delegate = self
           LocalPicture.addGestureRecognizer(rotationGestureRecognizer)
           
           let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
           pinchGestureRecognizer.delegate = self
           LocalPicture.addGestureRecognizer(pinchGestureRecognizer)
       }
       
    @objc func changeImage(_ sender: UITapGestureRecognizer) {
        displayImagePickingOptions()
    }
    
       @objc func moveImageView(_ sender: UIPanGestureRecognizer) {
           let translation = sender.translation(in: LocalPicture.superview)
           
           if sender.state == .began {
               initialImageViewOffset = LocalPicture.frame.origin
           }
           
           let position = CGPoint(x: translation.x + initialImageViewOffset.x - LocalPicture.frame.origin.x, y: translation.y + initialImageViewOffset.y - LocalPicture.frame.origin.y)
           
           LocalPicture.transform = LocalPicture.transform.translatedBy(x: position.x, y: position.y)
       }
       
       @objc func rotateImageView(_ sender: UIRotationGestureRecognizer) {
           LocalPicture.transform = LocalPicture.transform.rotated(by: sender.rotation)
           sender.rotation = 0
       }
       
       @objc func scaleImageView(_ sender: UIPinchGestureRecognizer) {
           LocalPicture.transform = LocalPicture.transform.scaledBy(x: sender.scale, y: sender.scale)
           sender.scale = 1
       }
       
       func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                              shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
           -> Bool {
               
               // simultaneous gesture recognition will only be supported for LocalPicture
               if gestureRecognizer.view != LocalPicture {
                   return false
               }
               
               // neither of the recognized gestures should not be tap gesture
               if gestureRecognizer is UITapGestureRecognizer
                   || otherGestureRecognizer is UITapGestureRecognizer
                   || gestureRecognizer is UIPanGestureRecognizer
                   || otherGestureRecognizer is UIPanGestureRecognizer {
                   return false
               }
               
               return true
       }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configure()
    }


}

