//
//  ImageChooserViewController.swift
//  Gridy
//
//  Created by Cynthia Nikolai on 12/8/20.
//  Copyright © 2020 Cynthia Nikolai. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class ImageChooserViewController: UIViewController  {

    var creation:Creation!
    
    var topCellItems: [String] = [
        "Boats",
        "Car",
        "Crocodile",
        "Park",
        "TShirts"
    ]
    
    @IBOutlet weak var unsolvedPuzzle: UICollectionView!
    
    func configure() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        unsolvedPuzzle.collectionViewLayout = layout
        unsolvedPuzzle.backgroundColor = .white
        unsolvedPuzzle.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CELL")
        unsolvedPuzzle.dragInteractionEnabled = true
        unsolvedPuzzle.dataSource = self as UICollectionViewDataSource
        unsolvedPuzzle.delegate = self as UICollectionViewDelegate
        unsolvedPuzzle.contentInset = UIEdgeInsets(top:4, left:4,bottom:4,right:4)
        view.addSubview(unsolvedPuzzle)
        
        // apply creation data to the views
        unsolvedPuzzle.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    @objc func processPicked(image: UIImage?) {
        if let newImage = image {
            creation.image = newImage
        }
        
        let storyboard = UIStoryboard(name: "ImageEditor", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageEditorViewController") as! ImageEditorViewController
        viewController.creation = creation
        present(viewController, animated: true)
    }
}

extension ImageChooserViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topCellItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((collectionView.frame.width-8)/3), height: ((collectionView.frame.width-8)/3))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CELL", for: indexPath)
        cell.backgroundColor = .white
        
        let image = UIImageView(image: UIImage(named: topCellItems[indexPath.row])!)
        image.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(image)
        image.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4).isActive = true
        image.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 4).isActive = true
        image.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 4).isActive = true
        image.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 4).isActive = true
        image.contentMode = .scaleAspectFill
        image.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let image = UIImage(named: topCellItems[indexPath.row]) {
            processPicked(image: image)
        }
    }
}
