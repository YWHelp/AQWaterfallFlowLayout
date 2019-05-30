//
//  CollectionViewCell.swift
//  AQWaterFall
//
//  Created by c on 2019/5/28.
//  Copyright © 2019 c. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
