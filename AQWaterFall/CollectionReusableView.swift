//
//  CollectionReusableView.swift
//  AQWaterFall
//
//  Created by c on 2019/5/28.
//  Copyright © 2019 c. All rights reserved.
//

import UIKit

class CollectionReusableView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.green
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
