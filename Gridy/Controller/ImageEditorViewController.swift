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

class ImageEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate  {

    var creation:Creation!
    var initialImageViewOffset = CGPoint()
    var localImages = [UIImage].init()

        
    @IBOutlet weak var creationFrame: UIView!
    @IBOutlet weak var creationImageView: UIImageView!
        
    func displayImagePickingOptions() {
        let alertController = UIAlertController(title: "Choose image", message: nil, preferredStyle: .actionSheet)

        // create camera action
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (action) in
            self.displayCamera()
        }

        // add camera action to alert controller
        alertController.addAction(cameraAction)

        // create library action
        let libraryAction = UIAlertAction(title: "Library pick", style: .default) { (action) in
            self.displayLibrary()
        }

        // add library action to alert controller
        alertController.addAction(libraryAction)

        // create random action
        let randomAction = UIAlertAction(title: "Random", style: .default) { (action) in
            self.pickRandom()
        }

        // add random action to alert controller
        alertController.addAction(randomAction)

        // create cancel action
        let canceclAction = UIAlertAction(title: "Cancel", style: .cancel)

        // add cancel action to alert controller
        alertController.addAction(canceclAction)

        present(alertController, animated: true) {
            // code to execute after the controller finished presenting
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
            let noPermissionMessage = "Looks like FrameIT have access to your photos:( Please use Setting app on your device to permit FrameIT accessing your library"

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
            //creationImageView.image = creation.image
            animateImageChange()
        }
    }
    
    func animateImageChange() {
        UIView.transition(with: self.creationImageView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.creationImageView.image = self.creation.image
        }, completion: nil)
    }

    func configure() {
        // collect images
        collectLocalImageSet()

        //self.view.backgroundColor = [UIColor, colorWithPatternImage,[UIImage self.creation.image]];

        // apply creation data to the views
        creationImageView.image = creation.image
        creationFrame.backgroundColor = UIColor.yellow
        
        creationImageView.isUserInteractionEnabled = true
        
//        let renderer1 = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 500))
//        let img1 = renderer1.image { ctx in
//            ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
//            ctx.cgContext.setLineWidth(3)
//
//            ctx.cgContext.move(to: CGPoint(x: 50, y: 450))
//            ctx.cgContext.addLine(to: CGPoint(x: 250, y: 50))
//            ctx.cgContext.addLine(to: CGPoint(x: 450, y: 450))
//            ctx.cgContext.addLine(to: CGPoint(x: 50, y: 450))
//
//            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
//            ctx.cgContext.addRect(rectangle)
//            ctx.cgContext.drawPath(using: .fillStroke)
//        }

        // create tap gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
        tapGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
        panGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(panGestureRecognizer)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
        rotationGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
        pinchGestureRecognizer.delegate = self
        creationImageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func moveImageView(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: creationImageView.superview)
        
        if sender.state == .began {
            initialImageViewOffset = creationImageView.frame.origin
        }
        
        let position = CGPoint(x: translation.x + initialImageViewOffset.x - creationImageView.frame.origin.x, y: translation.y + initialImageViewOffset.y - creationImageView.frame.origin.y)
        
        creationImageView.transform = creationImageView.transform.translatedBy(x: position.x, y: position.y)
    }
    
    @objc func rotateImageView(_ sender: UIRotationGestureRecognizer) {
        creationImageView.transform = creationImageView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    @objc func scaleImageView(_ sender: UIPinchGestureRecognizer) {
        creationImageView.transform = creationImageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
            
            // simultaneous gesture recognition will only be supported for creationImageView
            if gestureRecognizer.view != creationImageView {
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
        // Do any additional setup after loading the view, typically from a nib.

        configure()
    }
    
    func displaySharingOptions() {
        // define content to share
        let note = "I Framed IT!"
        let image = composeCreationImage()
        let items = [image as Any, note as Any]
        
        // create activity view controller
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view // so that iPads won't crash
        
        // present the view controller
        present(activityViewController, animated: true, completion: nil)
    }
    
    func composeCreationImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(creationFrame.bounds.size, false, 0)
        creationFrame.drawHierarchy(in: creationFrame.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
   @objc func changeImage(_ sender: UITapGestureRecognizer) {
       displayImagePickingOptions()
   }
}

class GridView: UIView {

    var numberOfColumns: Int = 4
    var numberOfRows: Int = 4
    var lineWidth: CGFloat = 1.0
    var lineColor: UIColor = UIColor.red

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {

            context.setLineWidth(lineWidth)
            context.setStrokeColor(UIColor.white.cgColor)

            let columnWidth = Int(rect.width) / (numberOfColumns + 1)
            for i in 1...numberOfColumns {
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                startPoint.x = CGFloat(columnWidth * i)
                startPoint.y = 0.0
                endPoint.x = startPoint.x
                endPoint.y = frame.size.height
                context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                context.strokePath()
            }

            let rowHeight = Int(rect.height) / (numberOfRows + 1)
            for j in 1...numberOfRows {
                var startPoint = CGPoint.zero
                var endPoint = CGPoint.zero
                startPoint.x = 0.0
                startPoint.y = CGFloat(rowHeight * j)
                endPoint.x = frame.size.width
                endPoint.y = startPoint.y
                context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
                context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
                context.strokePath()
            }
        }
    }
}
