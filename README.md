# SortableCollectionView
A sortable `UICollectionView` compatible iOS7+.You can customize your drag view (e.g. add a scale transform and a different background) as you need via delegate method.The speed of scroll is ratio to the distance between drag view and the edge just like the first page collectionView in Alipay iOS app. 

# Demo
**Flowlayout**

![Flowlayout](https://raw.githubusercontent.com/luowenxing/SortableCollectionView/master/demoFlow.gif)

**Waterfall**

![Waterfall](https://raw.githubusercontent.com/luowenxing/SortableCollectionView/master/demoWaterfall.gif)

# Installation
There is no other dependency in `SortableCollectionView`.Just add `SortableCollectionView.swift` to your project.

# Usage
* Use or subclass `SortableCollectionView` as your `UICollectionView` in xib/stroyboard.
* Implement delegate of `UICollectionView` and `UICollectionViewLayout` as usual.
* Implement delegate method in `SortableCollectionViewDelegate` and set `sortableDelegate`.
```
@objc protocol SortableCollectionViewDelegate:NSObjectProtocol {
    // customize your drag view at sort begin. 
    optional func beginDragAndInitDragCell(collectionView:SortableCollectionView,dragCell:UIView)
    
    // reset your drag view at sort end
    optional func endDragAndResetDragCell(collectionView:SortableCollectionView,dragCell:UIView)
    
    // oprate the sorted cell as you want. e.g. add a delete button if the cell is not be dragged move.
    optional func endDragAndOperateRealCell(collectionView:SortableCollectionView,realCell:UICollectionViewCell,isMoved:Bool)
    
    // exchange data source after sorting.
    func exchangeDataSource(fromIndex:NSIndexPath,toIndex:NSIndexPath)
}
```
* It's recomanded to implement `NSCopying` protocol in your `UICollectionViewCell`.In this case,the drag view will be the copy of `UICollectionViewCell` and you can do more customizing in your delegate method(e.g. set background color.).Otherwise the drag view will be the `snapshotViewAfterScreenUpdates` which is a single snapshot view without view hierarchy.  

# Improvement
* Supporting cell animation (e.g. shake).
* Scrolling a bit unsmoothly in rare cases.
