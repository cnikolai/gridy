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

protocol HelperDelegate: class {
    var constant: Int { get }
    func showHelp()
}

extension HelperDelegate {
    
    var constant: Int {
        return 1
    }
}

// MARK: - PlayfieldViewController

class PlayfieldViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var piecesCollectionView: UICollectionView!
    
    @IBOutlet weak var boardCollectionView: UICollectionView!
    var creation = Creation.init()
  
    // - create our collection view
//    private lazy var boardCollectionView: UICollectionView = {
//        let collectionView = UICollectionView()
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.dragDelegate = self
//        collectionView.dropDelegate = self
//        return collectionView
//    }()
//
//    private lazy var piecesCollectionView: UICollectionView = {
//        let collectionView = UICollectionView()
//
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        collectionView.dragDelegate = self
//        collectionView.dropDelegate = self
//        return collectionView
//    }()
    
    // - split the image into 16 parts
//    private lazy var puzzleImages: [UIImage] = {
//        creation.image.splitedInSixteenParts
//    }()
    
    // - when you have the images you would add them to this object
    // - create our puzzle for this example
    private lazy var puzzle: Puzzle = {
        Puzzle.init(Images: creation.image.splitedInSixteenParts)
    }()
    
    weak var helperDelegate: HelperDelegate?
    
    // - when clicking on hint button, add hint imageview to subview and when youy click close you will remove it
    var hintImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    @objc func tappedHelpButton() {
        helperDelegate?.showHelp()
    }
    
    func configure() {
        // apply creation data to the views
//        creation.image = creation.image
//        creationFrame.backgroundColor = UIColor.yellow
//
//        creationImageView.isUserInteractionEnabled = true
        piecesCollectionView.dataSource = self
        piecesCollectionView.delegate = self
        piecesCollectionView.dragDelegate = self
        piecesCollectionView.dropDelegate = self
        piecesCollectionView.register(PuzzleImageCell.self, forCellWithReuseIdentifier: "cell")
        
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        boardCollectionView.dragDelegate = self
        boardCollectionView.dropDelegate = self
        boardCollectionView.register(PuzzleImageCell.self, forCellWithReuseIdentifier: "cell")

        
    }
}


// MARK: - UICollectionViewDataSource

extension PlayfieldViewController: UICollectionViewDataSource {

    // number of sections (this usually is 1)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // gives you the number of items (this is usually the array count)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // will return the number of images in the puzzle otherwise return 0
        if collectionView == piecesCollectionView {
            return puzzle.piecesImages.count
        }
        if collectionView == boardCollectionView {
            return puzzle.solvedImages.count
        }
        return 0
    }

    // mapping your array at index path . item to a cell(view)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // create an puzzle image cell and set the image to be the current image
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PuzzleImageCell
        if collectionView == piecesCollectionView {
            //cell.image = puzzle.piecesImages[indexPath.item]
            cell.setImage(image: puzzle.piecesImages[indexPath.item])
        }
        if collectionView == boardCollectionView {
            //cell.image = puzzle.solvedImages[indexPath.item]
            cell.setImage(image: puzzle.solvedImages[indexPath.item])

        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //when select, want it to be highlighted: come back to this
    }
}

// MARK: - UICollectionViewDragDelegate, UICollectionViewDropDelegate

extension PlayfieldViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDropInteractionDelegate {
    
    // the items that start the drag process at an index
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            // get the image and
        let image = puzzle.piecesImages[indexPath.item]
        let itemProvider = NSItemProvider(object: image as UIImage)
        
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = image
        return [dragItem]
    }
    
    // what will happen when you drop the item
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndex = coordinator.destinationIndexPath {
            if destinationIndex.row >= puzzle.solvedImages.count {
                return
            } else if collectionView == boardCollectionView {
                //move item from one to another
                //check which collection view dropping it from and append to collectionview
                let items = coordinator.items
                //https://developer.apple.com/documentation/uikit/uicollectionviewdropcoordinator
//                collectionView.performBatchUpdates({
//                    guard let dragItem = items.first?.dragItem.localObject as? UIImage else { return }
//
//                    if dragItem == puzzleImages[coordinator.destinationIndexPath.item]
//
//                    ....
//
//                }, completion: nil)
                
                
            }
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//        //if the destination index path.row > images count, return forbidden operation (can't drop here anymore )
//        //else if collection view == board collection view, return move operation with intent to insert into destination index path.
//        //else forbidden op.
//        return 
//    }
}
