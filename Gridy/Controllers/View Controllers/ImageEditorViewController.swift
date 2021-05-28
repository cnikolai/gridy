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

class ImageEditorViewController: UIViewController {

    // MARK:- Local Variables
    var creation: Creation!
    private var initialImageViewOffset = CGPoint()
    
    // MARK:- Outlets
    @IBOutlet weak var creationImageView: UIImageView!
    @IBOutlet weak var creationFrame: GridView!
   
       
    // MARK:- Actions
    @IBAction func startPuzzle(_ sender: UIButton) {
        presentPlayfieldViewController()
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
    
    // MARK:- Helper

    private func configure() {
//        NSLayoutConstraint.activate([
//            creationImageView.centerXAnchor.constraint(equalTo: creationFrame.centerXAnchor),
//            creationImageView.centerYAnchor.constraint(equalTo: creationFrame.centerYAnchor),
//            creationImageView.leadingAnchor.constraint(greaterThanOrEqualTo: creationFrame.leadingAnchor),
//            creationImageView.trailingAnchor.constraint(lessThanOrEqualTo: creationFrame.trailingAnchor),
//            creationImageView.heightAnchor.constraint(equalTo: creationFrame.widthAnchor, multiplier: 1)
//                ])
        
        // apply creation data to the views
        creationImageView.image = creation.image
        creationImageView.isUserInteractionEnabled = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_:)))
        creationImageView.addGestureRecognizer(panGestureRecognizer)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_:)))
        creationImageView.addGestureRecognizer(rotationGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_:)))
        creationImageView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    private func presentPlayfieldViewController() {
        let storyboard = UIStoryboard(name: "Playfield", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PlayfieldViewController") as! PlayfieldViewController
        viewController.creation = creation
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    // MARK:- Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
}

// MARK:- Simultaneous GestureRecognizer

//extension ImageEditorViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
//        -> Bool {
//
//            // simultaneous gesture recognition will only be supported for creationImageView
//            if gestureRecognizer.view != creationImageView {
//                return false
//            }
//
//            return true
//    }
//}
