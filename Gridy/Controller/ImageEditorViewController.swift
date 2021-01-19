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
    var topCellItems: [String] = [
        "Boats",
        "Car",
        "Crocodile",
        "Park",
        "TShirts"
    ]
    
    
    @IBOutlet weak var unsolvedPuzzle: UIImageView!
    
    
    func configure() {
        unsolvedPuzzle.backgroundColor = .clear
        unsolvedPuzzle.image = creation.image
        view.addSubview(unsolvedPuzzle)
        
        unsolvedPuzzle.isUserInteractionEnabled = true

      // create tap gesture recognizer
      //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeImage(_:)))
      //tapGestureRecognizer.delegate = self
      //unsolvedPuzzle.addGestureRecognizer(tapGestureRecognizer)

      let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
      //panGestureRecognizer.delegate = self
      unsolvedPuzzle.addGestureRecognizer(panGestureRecognizer)

      let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
      //rotationGestureRecognizer.delegate = self
      unsolvedPuzzle.addGestureRecognizer(rotationGestureRecognizer)

      let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
      //pinchGestureRecognizer.delegate = self
      unsolvedPuzzle.addGestureRecognizer(pinchGestureRecognizer)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do additional setup after loading the view
        configure()
    }
    
    @objc func moveImageView(_ sender: UIPanGestureRecognizer) {
               let translation = sender.translation(in: unsolvedPuzzle.superview)
    
               if sender.state == .began {
                   initialImageViewOffset = unsolvedPuzzle.frame.origin
               }
    
               let position = CGPoint(x: translation.x + initialImageViewOffset.x - unsolvedPuzzle.frame.origin.x, y: translation.y + initialImageViewOffset.y - unsolvedPuzzle.frame.origin.y)
    
               unsolvedPuzzle.transform = unsolvedPuzzle.transform.translatedBy(x: position.x, y: position.y)
           }
    
           @objc func rotateImageView(_ sender: UIRotationGestureRecognizer) {
               unsolvedPuzzle.transform = unsolvedPuzzle.transform.rotated(by: sender.rotation)
               sender.rotation = 0
           }
    
           @objc func scaleImageView(_ sender: UIPinchGestureRecognizer) {
               unsolvedPuzzle.transform = unsolvedPuzzle.transform.scaledBy(x: sender.scale, y: sender.scale)
               sender.scale = 1
           }
           
           func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
               -> Bool {
    
                   // simultaneous gesture recognition will only be supported for LocalPicture
                   if gestureRecognizer.view != unsolvedPuzzle {
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
    
   
}
