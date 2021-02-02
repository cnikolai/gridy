//
//  MainViewController.swift
//  Gridy
//
//  Created by Cynthia Nikolai on 12/8/20.
//  Copyright © 2020 Cynthia Nikolai. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class MainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate  {

    var localImages = [UIImage].init()
    var creation = Creation.init()
    var initialImageViewOffset = CGPoint()
    let imageNames = ["Boats", "Car", "Crocodile", "Park", "TShirts"]
    
    @IBOutlet weak var PickGridyPicture: UIImageView! {
        didSet {
            PickGridyPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(processPicked(image:))))
            PickGridyPicture.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var PhotoLibraryPicture: UIImageView! {
    didSet {
       PhotoLibraryPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(processPicked(image:))))
       PhotoLibraryPicture.isUserInteractionEnabled = true    }
    }
    @IBOutlet weak var CameraPicture: UIImageView!{
    didSet {
       CameraPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(processPicked(image:))))
       CameraPicture.isUserInteractionEnabled = true
    }
    }
    
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
            @unknown default:
                break
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
            default:
                break
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
        

        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImages.append(image)
            }
        }
    }
    
    @objc func processPicked(image: UIImage?) {
         if let newImage = image {
             creation.image = newImage
             //LocalPicture.image = creation.image
             //animateImageChange()
         }
         else {
            let imageName = imageNames.shuffled().first!
            creation.image = UIImage(named: imageName)!
        }
        PresentImageChooserViewController()
     }
    
    func PresentImageEditorViewController() {
        let storyboard = UIStoryboard(name: "ImageEditor", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageEditorViewController") as! ImageEditorViewController
        viewController.creation = creation
        present(viewController, animated: true)
    }

    func PresentImageChooserViewController() {
            let storyboard = UIStoryboard(name: "ImageChooser", bundle: nil)
            
            let viewController = storyboard.instantiateViewController(withIdentifier: "ImageChooserViewController") as! ImageChooserViewController
            viewController.creation = creation
            present(viewController, animated: true)
        }


    func configure() {
           // collect images
           collectLocalImageSet()
       }
           
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configure()
    }
}
