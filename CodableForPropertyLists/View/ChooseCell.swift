//
//  ChooseCell.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/16.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

class ChooseCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chooseImage: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var bottomlineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCornerRadius(isFirst:Bool = false, isLast:Bool = false){
        // 設定cell圓角
        var coners = UIRectCorner()
        if isFirst{
            coners.insert(UIRectCorner.topLeft)
            coners.insert(UIRectCorner.topRight)
        }
        
        if isLast{
            coners.insert(UIRectCorner.bottomLeft)
            coners.insert(UIRectCorner.bottomRight)
            bottomlineView.backgroundColor = UIColor.white
        }
        
        layer.roundCorners(coners, radius: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
