//
//  DetailModel.swift
//  CodableForPropertyLists
//
//  Created by Laibit on 2018/7/24.
//  Copyright © 2018年 Laibit. All rights reserved.
//

import UIKit

struct TablePrinterSet: Codable {
    var isOpenCashbox: Bool
    var isOpenSaleSheet: Bool
    var saleSheetQuantity: Int
    var isOpenMenuSheet : Bool
    var menuSheetQuantity: Int
    var printerInfo:PrinterInfo
}

struct PrinterInfo:Codable{
    var id = ""
    var stationName = ""
    var deviceID = ""
    var stationIP = ""
    var printerSeries = ""
    var printerbrand = ""
}

class DetailModel: NSObject {
    static var sharedInstance = DetailModel()
    
    private func getURL(plistName:String)->URL{
        var url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        url.appendPathComponent(plistName)
        url.appendPathExtension("plist")
        return url
    }
    
    func getDetailValue(){
        let url = getURL(plistName: "DetailSetting")
        var settings: TablePrinterSet?
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            settings = try decoder.decode(TablePrinterSet.self, from: data)
            print(settings)
        } catch {
            print(error)
        }
    }
    
    func setDetailValue(){
        let url = getURL(plistName: "DetailSetting")
        let someSettings = TablePrinterSet(isOpenCashbox: true, isOpenSaleSheet: false, saleSheetQuantity: 5, isOpenMenuSheet: false, menuSheetQuantity: 5, printerInfo: PrinterInfo(id: "123", stationName: "EPSON", deviceID: "DEVICE", stationIP: "123456", printerSeries: "852", printerbrand: "654"))
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(someSettings)
            try data.write(to: url)
        } catch {
            print(error)
        }
    }

}
