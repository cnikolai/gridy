//
//  PuzzleImageCell.swift
//  Gridy
//
//  Created by Cynthia Nikolai on 2/2/21.
//  Copyright © 2021 Cynthia Nikolai. All rights reserved.
//

import UIKit

class PuzzleImageCell: UICollectionViewCell {

    var image:UIImage?{
        didSet {
            imageView.image = image
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        isUserInteractionEnabled = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.gray.cgColor
    }
}
