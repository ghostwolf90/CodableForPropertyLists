//
//  EditCell.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/18.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

enum ValidateEnum {
    case IP(_ : String)
    var isRight:Bool{
        var predicateStr:String!
        var currObject :String!
        switch self {
        case let .IP(str):
            predicateStr = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            currObject = str
        }
        let predacite = NSPredicate(format: "SELF MATCHES %@", predicateStr)
        return predacite.evaluate(with:currObject)
    }
}

class EditCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var editTextField: UITextField!
    
    var controllerType = ControllerType.tablePrinter
    var indexPath = IndexPath(row: 0, section: 0)
    var labelPrinterInfo = LabelPrinterInfo() //標籤機專用參數
    var pressCompleteHandler: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editTextField.delegate = self
    }
    
    //MARK : UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let result = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        print("result: \(result)")
        if !ValidateEnum.IP(result).isRight{
            print("IP有誤")
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let ipAddress = textField.text{
            LabelPrinterModel.sharedInstance.updateLabelPrinterIP(indexPath: indexPath, ipAddress: ipAddress, labelPrinterInfo: labelPrinterInfo)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let ipAddress = textField.text{
            LabelPrinterModel.sharedInstance.updateLabelPrinterIP(indexPath: indexPath, ipAddress: ipAddress, labelPrinterInfo: labelPrinterInfo)
        }
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
