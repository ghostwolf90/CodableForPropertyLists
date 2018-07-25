//
//  BleConnectTableViewCell.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/21.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

class BleConnectTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleDetailLabel: UILabel!
    @IBOutlet weak var moreOptionBlueBtn: UIButton!
    
    var controllerType = ControllerType.tablePrinter
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func moreOptionBluePress(_ sender: UIButton) {
    
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
        }
        
        layer.roundCorners(coners, radius: 4)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
