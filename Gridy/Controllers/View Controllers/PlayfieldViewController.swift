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

extension PlayfieldViewController {
    func canBecomeFocused() -> Bool {
        return true
    }
}

// MARK: - PlayfieldViewController

class PlayfieldViewController: UIViewController, UICollectionViewDelegate {
    
    // MARK:- Outlets
    
    @IBOutlet weak var piecesCollectionView: UICollectionView!
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var moves: UILabel!
    
    @IBAction func NewGame(_ sender: UIButton) {
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
    }

    @IBAction func showHint(_ sender: Any) {
        let popupVC = UIStoryboard(name: "Playfield", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopupViewController
        popupVC.modalPresentationStyle = .fullScreen
        popupVC.creation = creation
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
        piecesCollectionView.dragInteractionEnabled = true
        
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        boardCollectionView.dragDelegate = self
        boardCollectionView.dropDelegate = self
        boardCollectionView.dragInteractionEnabled = true

        let nib = UINib(nibName: "PuzzleImageCell", bundle: nil)
        piecesCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        boardCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
    }
    
    // Swipe action
    @objc private func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == UISwipeGestureRecognizer.Direction.up {
            if let view = sender.view as? UIImageView {
                puzzle.boardImages.remove(at: view.tag)
                // turn into blank cell.
                puzzle.boardImages.insert(blankImage, at: view.tag)
                removeBlankImage()
                puzzle.piecesImages.append(view.image!)
                //replace blank cell.
                boardCollectionView.reloadData()
                let indexToRemove = IndexPath.init(row: view.tag, section: 0)
                piecesCollectionView.deleteItems(at: [indexToRemove])
            }
        }
    }
    
    private func removeBlankImage() {
        let index = puzzle.piecesImages.firstIndex { image in
            image == blankImage
        }
        guard index != nil else { return }
        puzzle.piecesImages.remove(at: index!)
    }
    
    private func addPlaceHolderImages() {
        for _ in 0 ..< puzzle.solvedImages.count {
            puzzle.boardImages.append(blankImage)
        }
        piecesCollectionView.reloadData()
        boardCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension PlayfieldViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == piecesCollectionView {
            return puzzle.piecesImages.count
        }
        if collectionView == boardCollectionView {
            return puzzle.boardImages.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PuzzleImageCell
        if collectionView == piecesCollectionView {
            cell.image = puzzle.piecesImages[indexPath.item]
        }
        if collectionView == boardCollectionView {
            cell.image = puzzle.boardImages[indexPath.item]
            // Swipe (up) gesture recognizer
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeGesture.direction = UISwipeGestureRecognizer.Direction.up
            cell.imageView.addGestureRecognizer(swipeGesture)
            cell.imageView.isUserInteractionEnabled = true
            cell.imageView.tag = indexPath.row
        }

        return cell
    }
    
    func updateNumMoves(numMoves:Int) {
        self.moves.text = String(describing: numMoves)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == (puzzle.piecesImages.count - 1) {
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
        if collectionView == piecesCollectionView {
            // get the image
            let image = puzzle.piecesImages[indexPath.item]
            if image != blankImage {
                selectedIndexPath = indexPath

                let itemProvider = NSItemProvider(object: image as UIImage)
                let dragItem = UIDragItem(itemProvider: itemProvider)
                dragItem.localObject = image
                return [dragItem]
            }
        }
        return []
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
                let item = coordinator.items.first
                    // - happens in the same collection view
                if let sourceIndexPath = selectedIndexPath {
                    collectionView.performBatchUpdates ({
                        // get the dragged image
                        let dragItem = item?.dragItem.localObject as! UIImage
                        // check if destination has blank image
                       if puzzle.boardImages[destinationIndex.item] == blankImage {
                           // replace destination image with dragged image and update collectionview
                           self.puzzle.boardImages[destinationIndex.row] = dragItem
                           boardCollectionView.insertItems(at: [destinationIndex])
                           // insert blank image where dragged image was and update collectionview
                           self.puzzle.piecesImages[sourceIndexPath.row] = blankImage
                           piecesCollectionView.insertItems(at: [sourceIndexPath])
                       }
                   })
                    coordinator.drop(item!.dragItem, toItemAt: destinationIndex)
                        numMoves+=1
                        updateNumMoves(numMoves: numMoves)
                    if (self.puzzle.solvedImages == self.puzzle.boardImages) {
                        //end the game
                        let alertController = UIAlertController(title: "You Won!", message: "Congratulations", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
                        }
                        alertController.addAction(okAction)
                        present(alertController, animated: true)
                    }
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
