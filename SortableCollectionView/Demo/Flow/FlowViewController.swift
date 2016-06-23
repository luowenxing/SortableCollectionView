//
//  ViewController.swift
//  Test
//
//  Created by Luo on 4/15/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class FlowViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,SortableCollectionViewDelegate{

    
    @IBOutlet weak var collectionView: SortableCollectionView!
    private weak var panCell:UICollectionViewCell?
    private weak var originCell:UICollectionViewCell?
    private var timer:NSTimer?
    
    private lazy var dataSource:[Int] = {
        var source = [Int]()
        for i in 1..<101 {
            source.append(i)
        }
        return source
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CopyUICollectioViewCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "TestCell")
        self.collectionView.sortableDelegate = self
    }
    
    
    //#MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("TestCell", forIndexPath: indexPath) as! CopyUICollectioViewCell
        cell.imageView.backgroundColor = UIColor(red: CGFloat(arc4random()%255)/255.0, green: CGFloat(arc4random()%255)/255.0, blue: CGFloat(arc4random()%255)/255.0, alpha: 1.0)
        cell.textLabel.text = String(dataSource[indexPath.row])
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
   
//    uncomment below to test iOS9 original sort api
//    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//        
//    }
    
    //#MARK: SortableCollectionViewDelegate
    
    func exchangeDataSource(fromIndex: NSIndexPath, toIndex: NSIndexPath) {
        let temp = dataSource[fromIndex.row]
        dataSource[fromIndex.row] = dataSource[toIndex.row]
        dataSource[toIndex.row] = temp
    }
    
    func beginDragAndInitDragCell(collectionView: SortableCollectionView, dragCell: UIView) {
        dragCell.transform = CGAffineTransformMakeScale(1.2, 1.2)
        dragCell.backgroundColor = UIColor.lightGrayColor()
    }
    
    func endDragAndResetDragCell(collectionView: SortableCollectionView, dragCell: UIView) {
        dragCell.transform = CGAffineTransformMakeScale(1, 1)
        dragCell.backgroundColor = UIColor.whiteColor()
    }
    
}

