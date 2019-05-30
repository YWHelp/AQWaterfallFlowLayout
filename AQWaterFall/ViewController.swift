//
//  ViewController.swift
//  AQWaterFall
//
//  Created by c on 2019/5/23.
//  Copyright © 2019 c. All rights reserved.
//

import UIKit

class DataModel : NSObject {
    var img:String = ""
    var price:String = ""
    var w:CFloat = 0
    var h:CFloat = 0
}

class ViewController: UIViewController {
    var collectionView:UICollectionView!
    var heights:[CGFloat] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<20 {
            heights.append(CGFloat(arc4random() % (100 - 65) + 65))
        }
        self.view.backgroundColor = UIColor.white
        let layout = AQWaterfallFlowLayout()
        layout.flowLayoutStyle = .verticalEqualHeight
        layout.dataSource = self
        
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(collectionView)
        
        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        self.collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        self.collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "sectionFooter")
        // Do any additional setup after loading the view, typically from a nib.
    }
}

extension ViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        return cell
    }
}

extension ViewController:AQWaterfallFlowLayoutDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "sectionHeader", for: indexPath)
            headerView.backgroundColor = UIColor.purple
            return headerView
        }
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "sectionFooter", for: indexPath)
        footerView.backgroundColor = UIColor.green
        return footerView
    }
    
    func waterfallLayout(_ layout: AQWaterfallFlowLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: heights[indexPath.row], height:44 )
    }
    
    func waterfallLayout(_ layout: AQWaterfallFlowLayout, sizeForHeaderViewInSection section: NSInteger) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 50)
    }
    
    func waterfallLayout(_ layout: AQWaterfallFlowLayout, sizeForFooterViewInSection section: NSInteger) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 50)
    }
    
    func columnMarginInWaterFlowLayout(_ layout: AQWaterfallFlowLayout) -> CGFloat {
        return 10
    }
    
    func rowMarginInWaterFlowLayout(_ layout: AQWaterfallFlowLayout) -> CGFloat {
        return 10
    }
    
    func columnCountInWaterFlowLayout(_ layout: AQWaterfallFlowLayout) -> NSInteger {
        return 3
    }
    
    func rowCountInWaterFlowLayout(_ layout: AQWaterfallFlowLayout) -> NSInteger {
        return 6
    }
    
    func edgeInsetInWaterFlowLayout(_ layout: AQWaterfallFlowLayout) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
}

