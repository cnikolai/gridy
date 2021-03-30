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

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

// MARK: - PlayfieldViewController

class PlayfieldViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK:- Outlets
    
    @IBOutlet weak var piecesCollectionView: UICollectionView!
    
    @IBOutlet weak var boardCollectionView: UICollectionView!
    
    @IBOutlet weak var moves: UILabel!
    
    @IBAction func NewGame(_ sender: UIButton) {
        //puzzle.piecesImages.shuffle()
        self.moves.text = String(describing: 0)
    }
    
    // MARK: - Local Variables
    
    var creation: Creation!
    private var selectedIndexPath: IndexPath?
    
    private lazy var puzzle: Puzzle = {
        Puzzle.init(Image: creation.image)
    }()
        
    private lazy var blankImage: UIImage = {
        UIImage(color: .white)!
    }()
    
    private lazy var hintImage: UIImage = {
        UIImage(named: "Gridy-lookup")!
    }()
    
    private var numMoves:Int = 0
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    // MARK:- Helper Function
    
    func configure() {
       
        piecesCollectionView.dataSource = self
        piecesCollectionView.delegate = self
        piecesCollectionView.dragDelegate = self
        piecesCollectionView.dropDelegate = self
       // piecesCollectionView.register(PuzzleImageCell.self, forCellWithReuseIdentifier: "Cell")
        piecesCollectionView.dragInteractionEnabled = true

        
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        boardCollectionView.dragDelegate = self
        boardCollectionView.dropDelegate = self
        //boardCollectionView.register(PuzzleImageCell.self, forCellWithReuseIdentifier: "Cell")
        boardCollectionView.dragInteractionEnabled = true

        let nib = UINib(nibName: "PuzzleImageCell", bundle: nil)
        piecesCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        boardCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
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
            cell.image = puzzle.piecesImages[indexPath.item]
        }
        if collectionView == boardCollectionView {
            cell.image = puzzle.solvedImages[indexPath.item]

        }
        return cell
    }
    
    func updateNumMoves(numMoves:Int) {
        self.moves.text = String(describing: numMoves)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //when select, want it to be highlighted: come back to this
    }
}

// MARK: - UICollectionViewDragDelegate, UICollectionViewDropDelegate

extension PlayfieldViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDropInteractionDelegate {
    
    // the items that start the drag process at an index
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        selectedIndexPath = indexPath

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
                let item = coordinator.items[0]
                //let item = puzzleImages[coordinator.destinationIndexPath!.item]
                print("coordinator proposal operation: ", coordinator.proposal.operation)

                switch coordinator.proposal.operation {
                    //move item from one to another
                    //check which collection view dropping it from and append to collectionview
                case .move:
                    print("inside move operation")
                    // - happens in the same collection view
                    if let sourceIndexPath = item.sourceIndexPath {
                        collectionView.performBatchUpdates ({
                            //moveStringToDataSource(at: sourceIndexPath.item, to: destinationIndex.item, for: collectionView)
                            // - old collection view
                            collectionView.deleteItems(at: [sourceIndexPath])
                            // - new collection view
                            collectionView.insertItems(at: [destinationIndex])
                        })
                        coordinator.drop(item.dragItem, toItemAt: destinationIndex)
                        numMoves+=1
                        updateNumMoves(numMoves: numMoves)
                    }
                case .copy:
                    print("inside copy operation")
                    let sourceIndexPath = item.sourceIndexPath ?? selectedIndexPath
                    // - happens in a different collection view
                    let itemProvider = item.dragItem.itemProvider
                    // async call
                    itemProvider.loadObject(ofClass: NSString.self) { (string, error) in
                        //if let string = string as? String {
                            DispatchQueue.main.async {
                                collectionView.performBatchUpdates ({
                                    //self.addStringToDataSource(string, at: destinationIndex.item, from: sourceIndexPath?.item, for: collectionView)
                                    // - old collection view
                                    if let sourceIndex = sourceIndexPath {
                                        self.piecesCollectionView.deleteItems(at: [sourceIndex])
                                    }
                                    // - new collection view
                                    collectionView.insertItems(at: [destinationIndex])
                                })
                                collectionView.insertItems(at: [destinationIndex])
                            }
                        //}
                    }
                default:
                    print("inside default operation")
                    return
                }
            }
        }
               
    }

func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
       // - Control how the drop is done at the destination index path
       if session.localDragSession != nil {
           // - If more than one item is selected, the code cancels the drop.
           guard session.items.count == 1 else {
               return UICollectionViewDropProposal(operation: .cancel)
           }
           
           // - For the single drop item you propose a move if you’re within the same collection view. Otherwise, you propose a copy.
           if collectionView.hasActiveDrag {
                print("inside drop proposal move")
               return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
           } else {
               guard collectionView != piecesCollectionView else {
                   return UICollectionViewDropProposal(operation: .cancel)
               }
               return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
           }
       } else {
           return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
       }
   }
}
