//
//  PlayfieldViewController.swift
//  Gridy
//
//  Created by Cynthia Nikolai on 12/8/20.
//  Copyright © 2020 Cynthia Nikolai. All rights reserved.
//

import UIKit

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
        //self.moves.text = String(describing: 0)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
//        present(viewController, animated: true)
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
    }

    @IBAction func showHint(_ sender: Any) {
        let popupVC = UIStoryboard(name: "Playfield", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopupViewController
        //self.addChild(popupVC)
        //popupVC.view.frame = self.view.frame
        popupVC.creation = creation
        //self.view.addSubview(popupVC.view)
        //popupVC.didMove(toParent: self)
        present(popupVC, animated: true)
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
        addPlaceHolderImages()
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
    
    private func addPlaceHolderImages() {
        for _ in 0 ..< puzzle.solvedImages.count {
            puzzle.boardImages.append(blankImage)
        }
        // insert lookup image for puzzle pieces
        //puzzle.piecesImages.append(hintImage)
        piecesCollectionView.reloadData()
        boardCollectionView.reloadData()
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
            return puzzle.boardImages.count
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
            cell.image = puzzle.boardImages[indexPath.item]

        }
        return cell
    }
    
    func updateNumMoves(numMoves:Int) {
        self.moves.text = String(describing: numMoves)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == (puzzle.piecesImages.count - 1) {
//            hintImageView.isHidden = false
//            hintImageView.layer.borderColor = UIColor.black.cgColor
//            hintImageView.layer.borderWidth = 5
//            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(hideHint), userInfo: nil, repeats: false)
        }
    }
}

// MARK:- CollectionView Layout

extension PlayfieldViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == piecesCollectionView {
            let width = (piecesCollectionView.frame.size.width-50)/6
            return CGSize(width: width, height: width)
        }
        else {
            let width = boardCollectionView.frame.size.width/CGFloat(puzzle.boardImages.count).squareRoot()
            return CGSize(width: width, height: width)        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == piecesCollectionView {
               return 5
               }
               else {
                   return 0
               }
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == piecesCollectionView {
              return 5
               }
               else {
                  return 0
               }
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
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if collectionView == boardCollectionView {
            return true
        } else {
            return false
        }
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
        
                }
            }
        }

func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
      guard let indexPath = destinationIndexPath else {
           return UICollectionViewDropProposal(operation: .forbidden)
       }
       if indexPath.row >= puzzle.solvedImages.count {
           return UICollectionViewDropProposal(operation: .forbidden)
       } else if collectionView == boardCollectionView {
           return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
       } else {
           return UICollectionViewDropProposal(operation: .forbidden)
       }
   }
}
