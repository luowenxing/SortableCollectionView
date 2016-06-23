//
//  SortableCollectionView.swift
//  Test
//
//  Created by Luo on 6/21/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

@objc protocol SortableCollectionViewDelegate:NSObjectProtocol {
    // customize your drag view at sort begin.
    optional func beginDragAndInitDragCell(collectionView:SortableCollectionView,dragCell:UIView)
    
    // reset your drag view at sort end
    optional func endDragAndResetDragCell(collectionView:SortableCollectionView,dragCell:UIView)
    
    // oprate the sorted cell as you want. e.g. add a delete button if the cell is not be dragged move.
    optional func endDragAndOperateRealCell(collectionView:SortableCollectionView,realCell:UICollectionViewCell,isMoved:Bool)
    
    // exchange data source after sorting.
    optional func exchangeDataSource(fromIndex:NSIndexPath,toIndex:NSIndexPath)
}

class SortableCollectionView : UICollectionView {
    
    weak var sortableDelegate:SortableCollectionViewDelegate?
    
    private var superView:UIView!
    private var dragView:UIView!
    private var originCell:UICollectionViewCell?
    private var timer:NSTimer?
    
    private var fromIndex:NSIndexPath!
    private var toIndex:NSIndexPath?
    
    override func awakeFromNib() {
        self.decelerationRate = 0
        self.allowsSelection = true
        let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(SortableCollectionView.panGestureHandler(_:)))
        self.addGestureRecognizer(panGesture)
        self.superView = self.superview
    }
    
    private lazy var isDelegateImplementMovement:Bool = {
        if let delegate = self.sortableDelegate as? UICollectionViewDataSource {
            if #available(iOS 9.0, *) {
                if let _ = delegate.collectionView?(self, canMoveItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) {
                    return true
                }
            }
        }
        return false
    }()
    
    
    func panGestureHandler(sender:UILongPressGestureRecognizer) {
        let collectionViewPoint = sender.locationInView(self)
        let viewPoint = sender.locationInView(self.superView)
        if sender.state == .Began {
            if let index = self.indexPathForItemAtPoint(collectionViewPoint),originCell = self.cellForItemAtIndexPath(index) {
                if #available(iOS 9.0, *) {
                    if isDelegateImplementMovement {
                        self.beginInteractiveMovementForItemAtIndexPath(index)
                        return
                    }
                }
                self.beginMoveItemAtIndex(index, cell: originCell)
                dragView.center = viewPoint
            }
        } else if sender.state == .Changed {
            if #available(iOS 9.0, *) {
                if isDelegateImplementMovement {
                    self.updateInteractiveMovementTargetPosition(collectionViewPoint)
                    return
                }
            }
            self.updateMoveItem(viewPoint, collectionViewPoint: collectionViewPoint)
        } else if sender.state == .Ended {
            if #available(iOS 9.0, *) {
                if isDelegateImplementMovement {
                    self.endInteractiveMovement()
                    return
                }
            }
            self.endMoveItem()
            
        }
    }
    
    func beginMoveItemAtIndex(index:NSIndexPath,cell:UICollectionViewCell) {
        self.fromIndex = index
        self.originCell = cell
        cell.hidden = true
        if let copyable = originCell as? NSCopying {
            self.dragView = copyable.copyWithZone(nil) as! UIView
        } else {
            dragView = cell.snapshotViewAfterScreenUpdates(false)
        }
        self.superView.addSubview(dragView)
        dragView.autoresizesSubviews = false
        self.sortableDelegate?.beginDragAndInitDragCell?(self, dragCell: dragView)
        self.bringSubviewToFront(dragView)
    }
    
    func updateMoveItem(viewPoint:CGPoint,collectionViewPoint:CGPoint) {
        dragView.center = viewPoint
        self.moveItemToPoint(collectionViewPoint)
        self.scrollAtEdge()
    }
    
    func endMoveItem() {
        self.timer?.invalidate()
        self.timer = nil
        if let originCell = self.originCell {
            UIView.animateWithDuration(0.2, animations: {
                self.sortableDelegate?.endDragAndResetDragCell?(self, dragCell: self.dragView)
                self.dragView.frame = CGRect(x: originCell.frame.origin.x, y: originCell.frame.origin.y - self.contentOffset.y, width: originCell.frame.width, height: originCell.frame.height)
            }){
                _ in
                self.dragView.removeFromSuperview()
                originCell.hidden = false
                var isMoved = false
                if let toIndex = self.toIndex {
                    self.sortableDelegate?.exchangeDataSource?(self.fromIndex, toIndex: toIndex)
                    isMoved = true
                }
                self.sortableDelegate?.endDragAndOperateRealCell?(self, realCell: originCell, isMoved: isMoved)
            }
        }
    }
    
    func moveItemToPoint(collectionViewPoint:CGPoint){
        if let index = self.indexPathForItemAtPoint(collectionViewPoint),originCell = self.originCell {
            let cell = self.cellForItemAtIndexPath(index)
            if cell != originCell {
                self.performBatchUpdates({
                    if let fromIndex = self.indexPathForCell(originCell) {
                        self.moveItemAtIndexPath(fromIndex, toIndexPath: index)
                    }
                }){
                    success in
                    if success {
                          self.toIndex = index
                    }
                }
            }
        }
        
    }
    
    func scrollAtEdge(){
        let pinTop = dragView.frame.origin.y
        let pinBottom = self.frame.height - (dragView.frame.origin.y + dragView.frame.height)
        var speed:CGFloat = 0
        var isTop:Bool = true
        if pinTop < 0 {
            speed = -pinTop
            isTop = true
        } else if pinBottom < 0 {
            speed = -pinBottom
            isTop = false
        } else {
            self.timer?.invalidate()
            self.timer = nil
            return
        }
        if let originTimer = self.timer,originSpeed = (originTimer.userInfo as? [String:AnyObject])?["speed"] as? CGFloat{
            if abs(speed - originSpeed) > 10 {
                originTimer.invalidate()
                NSLog("speed:\(speed)")
                let timer = NSTimer(timeInterval: 1/60.0, target: self, selector: #selector(SortableCollectionView.autoScroll(_:)), userInfo: ["top":isTop,"speed": speed] , repeats: true)
                self.timer = timer
                NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            }
        } else {
            let timer = NSTimer(timeInterval: 1/60.0, target: self, selector: #selector(SortableCollectionView.autoScroll(_:)), userInfo: ["top":isTop,"speed": speed] , repeats: true)
            self.timer = timer
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
    }
    
    
    func autoScroll(timer:NSTimer) {
        if let userInfo = timer.userInfo as? [String:AnyObject] {
            if let top =  userInfo["top"] as? Bool,speed = userInfo["speed"] as? CGFloat {
                let offset = speed / 5
                let contentOffset = self.contentOffset
                if top {
                    self.contentOffset.y -= offset
                    self.contentOffset.y = self.contentOffset.y < 0 ? 0 : self.contentOffset.y
                }else {
                    self.contentOffset.y += offset
                    self.contentOffset.y = self.contentOffset.y > self.contentSize.height - self.frame.height ? self.contentSize.height - self.frame.height  : self.contentOffset.y
                }
                let point = CGPoint(x: dragView.center.x, y: dragView.center.y + contentOffset.y)
                self.moveItemToPoint(point)
            }
        }
    }
    
    
}
