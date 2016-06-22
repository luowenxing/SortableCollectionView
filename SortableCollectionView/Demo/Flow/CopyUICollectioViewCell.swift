//
//  CopyUICollectioViewCell.swift
//  Test
//
//  Created by Luo on 5/3/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

class CopyUICollectioViewCell : UICollectionViewCell,NSCopying {
    func copyWithZone(zone: NSZone) -> AnyObject {
        let cell = NSBundle.mainBundle().loadNibNamed("CopyUICollectioViewCell", owner: nil, options: nil).first as! CopyUICollectioViewCell
        cell.textLabel.text = self.textLabel.text
        cell.imageView.backgroundColor = self.imageView.backgroundColor
        cell.frame = self.frame
        return cell
    }
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
}

