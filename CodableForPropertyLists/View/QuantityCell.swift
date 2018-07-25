//
//  QuantityCell.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/17.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

class QuantityCell: UITableViewCell {

    @IBOutlet weak var titltLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    var controllerType = ControllerType.tablePrinter
    var detailSections = [DetailSection]()
    var indexPath = IndexPath(row: 0, section: 0)
    var selectIndex = IndexPath(row: 0, section: 0)
    var pressSwitchHandler: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //-
    @IBAction func minusPress(_ sender: UIButton) {
        let quantity = PrinterDetailModel.sharedInstance.changeOrderSettingQuantity(indexPath: indexPath, selectIndex:selectIndex, detailSection: detailSections, changeType: .minus)
        quantityLabel.text = quantity
        pressSwitchHandler?()
    }
    
    //+
    @IBAction func plusPress(_ sender: UIButton) {
        let quantity = PrinterDetailModel.sharedInstance.changeOrderSettingQuantity(indexPath: indexPath, selectIndex:selectIndex ,detailSection: detailSections, changeType: .plus)
        quantityLabel.text = quantity
        pressSwitchHandler?()
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

        // Configure the view for the selected state
    }

}
