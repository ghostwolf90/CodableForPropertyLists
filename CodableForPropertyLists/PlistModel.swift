//
//  PlistModel.swift
//  CodableForPropertyLists
//
//  Created by Laibit on 2018/7/25.
//  Copyright © 2018年 Laibit. All rights reserved.
//

import UIKit

enum DisplayType:String {
    case string = "string"
    case switchEnable = "switch"
    case edit = "edit"
    case downMenu = "downMenu"
    case detail = "detail"
    case quantity = "quantity"
    case next = "next"
    case volume = "volume"
    case bleSelect = "bleSelect"
}

struct PlistSetting {
    var id: String
    var title: String
    var subTitle: String
    var displayType : DisplayType
}

struct Section{
    var name:String
    var plistSettings:[PlistSetting]
}

class PlistModel: NSObject {
    static var sharedInstance = PlistModel()
    
    func constructTablePrinterSetting()->[Section]{
        
        var sections = [Section]()
        let tablePrinter = PlistSetting(id: "isOpenCashBox", title: "使用錢箱", subTitle: "", displayType: .switchEnable)
        sections.append(Section(name: "", plistSettings: [tablePrinter]))
        
        let isOpenSaleSheet = PlistSetting(id: "isOpenSaleSheet", title: "交易明細", subTitle: "", displayType: .next)
        let isOpenMenuSheet = PlistSetting(id: "isOpenMenuSheet", title: "訂單明細", subTitle: "", displayType: .next)
        sections.append(Section(name: "列印設定", plistSettings: [isOpenSaleSheet, isOpenMenuSheet]))
        
        let selectPrinter = PlistSetting(id: "selectPrinter", title: "印單機選擇", subTitle: "", displayType: .next)
        sections.append(Section(name: "印單機連線", plistSettings: [selectPrinter]))
        print(sections)
        
        return sections
    }
    
}
