//
//  CollectionViewCell.swift
//  Pet App
//
//  Created by maya on 2020/10/10.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var videoImage: UIImageView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // cellの枠の太さ
        self.layer.borderWidth = 1.0
        // cellの枠の色
        self.layer.borderColor = UIColor.black.cgColor
    }
}
