//
//  Puzzle.swift
//  Gridy
//
//  Created by Cynthia Nikolai on 2/2/21.
//  Copyright © 2021 Cynthia Nikolai. All rights reserved.
//

import UIKit
import Foundation

class Puzzle {
    var piecesImages: [UIImage]
    var solvedImages: [UIImage]
    var boardImages: [UIImage] = []
    
    init(Images: [UIImage]) {
        self.piecesImages = Images.shuffled()
        self.solvedImages = Images
    }
}

extension UIImage {
    
    var topHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height/2))) else { return nil }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }
    var bottomHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: 0,  y: CGFloat(Int(size.height)-Int(size.height/2))), size: CGSize(width: size.width, height: CGFloat(Int(size.height) - Int(size.height/2))))) else { return nil }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }
    var leftHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width/2, height: size.height))) else { return nil }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }
    var rightHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(Int(size.width)-Int((size.width/2))), y: 0), size: CGSize(width: CGFloat(Int(size.width)-Int((size.width/2))), height: size.height)))
            else { return nil }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }
    var splitedInFourParts: [UIImage] {
        guard case let topHalf = topHalf,
              case let bottomHalf = bottomHalf,
            let topLeft = topHalf?.leftHalf,
            let topRight = topHalf?.rightHalf,
            let bottomLeft = bottomHalf?.leftHalf,
            let bottomRight = bottomHalf?.rightHalf else{ return [] }
        return [topLeft, topRight, bottomLeft, bottomRight]
    }
    var splitedInSixteenParts: [UIImage] {
        var array = splitedInFourParts.flatMap({$0.splitedInFourParts})
        // if you need it in reading order you need to swap some image positions
        array.swapAt(2, 4)
        array.swapAt(3, 5)
        array.swapAt(10, 12)
        array.swapAt(11, 13)
        
        return array
    }
}
