//
//  Creation.swift
//  Gridy
//
//  Created by Cynthia Nikolai on 11/29/20.
//  Copyright © 2020 Cynthia Nikolai. All rights reserved.
//

import Foundation
import UIKit

class Creation {
    var image: UIImage
    
    static var defaultImage: UIImage {
        return UIImage.init(named: "Gridy-name-small-grey")!
    }
        
    init() {
        // stored property initialization
        image = Creation.defaultImage
    }
    
    init(image: UIImage) {
        // stored property initialization
        self.image = image
    }
}
