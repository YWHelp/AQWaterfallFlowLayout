//
//  AQWaterfallFlowLayout.swift
//  AQWaterFall
//
//  Created by c on 2019/5/23.
//  Copyright © 2019 c. All rights reserved.
//

import UIKit

enum AQWaterfallFlowLayoutStyle {
    case verticalEqualWidth /** 竖向瀑布流 item等宽不等高 */
    case verticalEqualHeight /** 竖向瀑布流 item等高不等宽 */
}

/// 瀑布流代理
@objc protocol AQWaterfallFlowLayoutDataSource : class {

    //计算itemSize的代理方法，将item的高度与indexPath传递给外界
    func waterfallLayout(_ layout : AQWaterfallFlowLayout, sizeForItemAtIndexPath indexPath : IndexPath) -> CGSize
    //设置区头大小
    func waterfallLayout(_ layout : AQWaterfallFlowLayout, sizeForHeaderViewInSection section: NSInteger) -> CGSize
    //设置区尾大小
    func waterfallLayout(_ layout : AQWaterfallFlowLayout, sizeForFooterViewInSection section: NSInteger) -> CGSize
    //列数
    func columnCountInWaterFlowLayout(_ layout : AQWaterfallFlowLayout) -> NSInteger
    //行数
    func rowCountInWaterFlowLayout(_ layout : AQWaterfallFlowLayout) -> NSInteger
    //列间距
    func columnMarginInWaterFlowLayout(_ layout : AQWaterfallFlowLayout) -> CGFloat
    //行间距
    func rowMarginInWaterFlowLayout(_ layout : AQWaterfallFlowLayout) -> CGFloat
    //边缘之间的间距
    func edgeInsetInWaterFlowLayout(_ layout : AQWaterfallFlowLayout) -> UIEdgeInsets
}

class AQWaterfallFlowLayout: UICollectionViewLayout {
    // 瀑布流数据源代理
    weak var dataSource : AQWaterfallFlowLayoutDataSource?
    var flowLayoutStyle:AQWaterfallFlowLayoutStyle = .verticalEqualWidth
    /** 默认的列数*/
    fileprivate var columnCount:NSInteger{
        get {
            return self.dataSource?.columnCountInWaterFlowLayout(self) ?? 2
        }
    }
    /** 默认的行数*/
    fileprivate var rowCount:NSInteger {
        get{
            return self.dataSource?.rowCountInWaterFlowLayout(self) ?? 5
        }
    }
    /** 每一列之间的间距*/
    fileprivate var columnMargin:CGFloat{
        get{
            return self.dataSource?.columnMarginInWaterFlowLayout(self) ?? 10
        }
    }
    /** 每一行之间的间距*/
    fileprivate var rowMargin:CGFloat{
        get{
            return self.dataSource?.rowMarginInWaterFlowLayout(self) ?? 10
        }
    }
    /** 边缘之间的间距*/
    fileprivate var sectionInset:UIEdgeInsets{
        get{
            return self.dataSource?.edgeInsetInWaterFlowLayout(self) ?? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    var stickyHeader:Bool = true
    /** 存放所有cell的布局属性*/
    fileprivate var attrsArray = [UICollectionViewLayoutAttributes]()
    /** 存放每一列的最大y值*/
    fileprivate var columnHeights = [CGFloat]()
    /** 存放每一行的最大x值*/
    fileprivate var rowWidths = [CGFloat]()
    /** 内容的高度*/
    fileprivate var maxColumnHeight:CGFloat = 0
    /** 内容的宽度*/
    fileprivate var maxRowWidth:CGFloat = 0
    override func prepare() {
        super.prepare()
        if flowLayoutStyle == .verticalEqualWidth {
            self.maxColumnHeight = 0
            self.columnHeights.removeAll()
            for _ in 0..<self.columnCount {
                self.columnHeights.append(self.sectionInset.top)
            }
        }else if flowLayoutStyle == .verticalEqualHeight {
            
            //记录最后一个的内容的横坐标和纵坐标
            self.maxColumnHeight = 0
            self.columnHeights.removeAll()
            self.columnHeights.append(self.sectionInset.top)
            
            self.maxRowWidth = 0
            self.rowWidths.removeAll()
            self.rowWidths.append(self.sectionInset.left)
        }
        self.attrsArray.removeAll()
        let sectionCount = self.collectionView!.numberOfSections
        for section in 0..<sectionCount {
            //获取每一组头视图
            if let headerSize = self.dataSource?.waterfallLayout(self, sizeForHeaderViewInSection: section), !headerSize.equalTo(CGSize.zero) {
                if let headerAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)){
                    self.attrsArray.append(headerAttrs)
                }
            }
            
            //开始创建组内的每一个cell的布局属性
            let rowCount = self.collectionView!.numberOfItems(inSection: section)
            var row = 0
            while row < rowCount {
                let indexPath = IndexPath(item: row, section: section)
                if let attrs = self.layoutAttributesForItem(at: indexPath){
                    self.attrsArray.append(attrs)
                }
                row += 1
            }
            
            //获取每一组脚视图
            if let footerSize = self.dataSource?.waterfallLayout(self, sizeForFooterViewInSection: section), !footerSize.equalTo(CGSize.zero) {
                if let footerAttrs = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(item: 0, section: section)){
                    self.attrsArray.append(footerAttrs)
                }
            }
        }
    }
    
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return stickyHeader
//    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if self.flowLayoutStyle == .verticalEqualWidth {
           attrs.frame = self.itemFrameOfVerticalEqualWidthWaterFlow(indexPath)
        }else if self.flowLayoutStyle == .verticalEqualHeight {
           attrs.frame = self.itemFrameOfVerticalEqualHeightWaterFlow(indexPath)
        }
        return attrs
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attri:UICollectionViewLayoutAttributes?
        if elementKind == UICollectionView.elementKindSectionHeader {
            attri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            attri?.frame = self.headerViewFrameOfVerticalWaterFlow(indexPath)
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            attri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            attri?.frame = self.footerViewFrameOfVerticalWaterFlow(indexPath)
        }
        return attri
    }
    
    override var collectionViewContentSize: CGSize{
        get {
            if self.flowLayoutStyle == .verticalEqualWidth {
               return CGSize(width: 0, height: self.maxColumnHeight + self.sectionInset.bottom)
            }else if self.flowLayoutStyle == .verticalEqualHeight {
               return CGSize(width: 0, height: self.maxColumnHeight + self.sectionInset.bottom)
            }
            return CGSize.zero
        }
    }
}

extension AQWaterfallFlowLayout {
    //竖向瀑布流 item等宽不等高
    fileprivate func itemFrameOfVerticalEqualWidthWaterFlow(_ indexPath:IndexPath) -> CGRect{
        let collectionW = self.collectionView!.frame.size.width
        let w =  (collectionW - self.sectionInset.left - self.sectionInset.right - CGFloat(self.columnCount - 1)*self.columnMargin) / CGFloat(self.columnCount)
        let h = self.dataSource?.waterfallLayout(self, sizeForItemAtIndexPath: indexPath).height ?? 0
        //找出高度最短的那一列
        var destColumn:NSInteger = 0
        var minColumnHeight = self.columnHeights.first ?? 0
        for i in 1..<self.columnCount{
            let columnHeight = self.columnHeights[i]
            if minColumnHeight > columnHeight {
                minColumnHeight = columnHeight
                destColumn = i
            }
        }
        
        let x = self.sectionInset.left + CGFloat(destColumn)*(w+self.columnMargin)
        var y = minColumnHeight
        if y != self.sectionInset.top {
            y += self.rowMargin
        }
        
        //更新最短那列的高度
        self.columnHeights[destColumn] = CGRect(x: x, y: y, width: w, height: h).maxY
        let columnHeight = self.columnHeights[destColumn]
        if self.maxColumnHeight < columnHeight {
            self.maxColumnHeight = columnHeight
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    //竖向瀑布流 item等高不等宽
    fileprivate func itemFrameOfVerticalEqualHeightWaterFlow(_ indexPath:IndexPath) -> CGRect{
        let collectionW = self.collectionView!.frame.size.width
        
        let headViewSize = self.dataSource?.waterfallLayout(self, sizeForHeaderViewInSection: indexPath.section) ?? CGSize.zero

        let w =  self.dataSource?.waterfallLayout(self, sizeForItemAtIndexPath: indexPath).width ?? 0
        let h = self.dataSource?.waterfallLayout(self, sizeForItemAtIndexPath: indexPath).height ?? 0
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        //记录最后一行的内容的横坐标和纵坐标
        if (collectionW - (self.rowWidths.first ?? 0)) > w+self.sectionInset.right {
            x = self.rowWidths.first == self.sectionInset.left ?  self.sectionInset.left : ((self.rowWidths.first ?? 0) + self.columnMargin)
            if (self.columnHeights.first ?? 0) == self.sectionInset.top {
                y = self.sectionInset.top
            } else if (self.columnHeights.first ?? 0) == self.sectionInset.top + headViewSize.height {
                y =  self.sectionInset.top + headViewSize.height + self.rowMargin
            }else {
                let ch = (self.columnHeights.first ?? 0) - h
                y = ch > 0 ? ch : 0
            }
            self.rowWidths[0] = x + w
            if self.columnHeights.first == self.sectionInset.top || self.columnHeights.first == self.sectionInset.top + headViewSize.height {
                self.columnHeights[0] = y + h
            }
        } else if (collectionW - (self.rowWidths.first ?? 0)) == (w + self.sectionInset.right) {
            //换行
            x = self.sectionInset.left
            y = (self.columnHeights.first ?? 0) + self.rowMargin
            
            self.rowWidths[0] = x+w
            self.columnHeights[0] = y + h

        } else {
            //换行
            x = self.sectionInset.left
            y = (self.columnHeights.first ?? 0) + self.rowMargin
            self.rowWidths[0] = x + w
            self.columnHeights[0] = y + h
        }
        //记录内容的高度
        self.maxColumnHeight = self.columnHeights.first ?? 0
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    //返回头视图的布局frame
    fileprivate func headerViewFrameOfVerticalWaterFlow(_ indexPath:IndexPath) -> CGRect {
        let size = self.dataSource?.waterfallLayout(self, sizeForHeaderViewInSection: indexPath.section)  ??  CGSize.zero
        if self.flowLayoutStyle == .verticalEqualWidth {
            let x: CGFloat = 0
            var y: CGFloat = self.maxColumnHeight == 0 ? self.sectionInset.top : self.maxColumnHeight
            if self.dataSource?.waterfallLayout(self, sizeForFooterViewInSection: indexPath.section).height == 0 {
                y = self.maxColumnHeight == 0 ? self.sectionInset.top : self.maxColumnHeight + self.rowMargin
            }
            self.maxColumnHeight = y + size.height
            self.columnHeights.removeAll()
            for _ in 0..<self.columnCount {
                self.columnHeights.append(self.maxColumnHeight)
            }
            return CGRect(x: x, y: y, width: self.collectionView!.frame.size.width, height: size.height)
        }else if self.flowLayoutStyle == .verticalEqualHeight {
            let x: CGFloat = 0
            var y: CGFloat = self.maxColumnHeight == 0 ? self.sectionInset.top : self.maxColumnHeight
            if self.dataSource?.waterfallLayout(self, sizeForFooterViewInSection: indexPath.section).height == 0 {
                y = self.maxColumnHeight == 0 ? self.sectionInset.top : self.maxColumnHeight + self.rowMargin
            }
            self.maxColumnHeight = y + size.height
            self.rowWidths[0] = self.collectionView!.frame.size.width
            
            self.columnHeights[0] = self.maxColumnHeight
            
            return CGRect(x: x, y: y, width: self.collectionView!.frame.size.width, height: size.height)
        }
        return CGRect.zero
    }
    //返回脚视图的布局frame
    fileprivate func footerViewFrameOfVerticalWaterFlow(_ indexPath:IndexPath) -> CGRect{
        let size = self.dataSource?.waterfallLayout(self, sizeForFooterViewInSection: indexPath.section)  ??  CGSize.zero
        if self.flowLayoutStyle == .verticalEqualWidth {
            let x: CGFloat = 0
            let y: CGFloat = size.height == 0 ? self.maxColumnHeight : self.maxColumnHeight + self.rowMargin
            self.maxColumnHeight = y + size.height
            self.columnHeights.removeAll()
            for _ in 0..<self.columnCount {
                self.columnHeights.append(self.maxColumnHeight)
            }
            return CGRect(x: x, y: y, width: self.collectionView!.frame.size.width, height: size.height)
        }else if self.flowLayoutStyle == .verticalEqualHeight {
            let x: CGFloat = 0
            let y: CGFloat = size.height == 0 ? self.maxColumnHeight : self.maxColumnHeight + self.rowMargin
            self.maxColumnHeight = y + size.height
            
            self.rowWidths[0] = self.collectionView!.frame.size.width
            self.columnHeights[0] = self.maxColumnHeight
            return CGRect(x: x, y: y, width: self.collectionView!.frame.size.width, height: size.height)
        }
        return CGRect.zero
    }
}
