//
//  switchCell.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/16.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

enum ControllerType {
    case labelPrinter
    case tablePrinter
    case orderSetting
    case otherSetting
    case kitchenPrinter
    case bleReader
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchObject: UISwitch!
    @IBOutlet weak var bottomlineView: UIView!
    var pressSwitchHandler: ((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUISwitch()
    }
    
    func initUISwitch(){
        switchObject.tintColor = UIColor.QlieerStyleGuide.qlrPaleGrey // the "off" color
        switchObject.onTintColor = UIColor.QlieerStyleGuide.qlrLightQlieer // the "on" color
        switchObject.layer.cornerRadius = 16
        switchObject.backgroundColor = UIColor.QlieerStyleGuide.qlrPaleGrey
    }

    @IBAction func switchAction(_ sender: UISwitch) {
        pressSwitchHandler?(sender.isOn)
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
