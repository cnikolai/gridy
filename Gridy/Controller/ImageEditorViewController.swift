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

class ImageEditorViewController: UIViewController  {

    var creation:Creation!
    var topCellItems: [String] = [
        "Boats",
        "Car",
        "Crocodile",
        "Park",
        "TShirts"
    ]
    
    
    @IBOutlet weak var unsolvedPuzzle: UIImageView!
    
    
    func configure() {
        unsolvedPuzzle.backgroundColor = .red
        view.addSubview(unsolvedPuzzle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do additional setup after loading the view
        configure()
    }

}
