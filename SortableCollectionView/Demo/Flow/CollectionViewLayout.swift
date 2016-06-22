//
//  CollectionViewLayout.swift
//  Test
//
//  Created by Luo on 4/15/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class CollectionViewLayout : UICollectionViewFlowLayout {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
        let bounds = UIScreen.mainScreen().bounds
        self.itemSize = CGSize(width: bounds.width / 3.0, height: 100)
    }

    
//    override func collectionViewContentSize() -> CGSize {
//        let count = self.collectionView!.numberOfItemsInSection(0)
//        let page = ceil(Double(count) / 6.0)
//        return CGSize(width: CGFloat(page) * UIScreen.mainScreen().bounds.width , height: self.collectionView!.frame.height)
//    }
//    
}