//
//  PlistHelper.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2017/11/1.
//  Copyright © 2017年 QLIEER. All rights reserved.
//

import UIKit

enum PlistName:String {
    case printerDetail = "PrinterDetailV3"
    case labelPrinterList = "LabelPrinterList"
    case labelPrinter = "LabelPrinter"
    case kitchenPrinterList = "KitchenPrinterList"
    case kitchenPrinterDetail = "KitchenPrinterDetailV4"
    case bLEPreference = "BLEPreference"
    case otherSetting = "OtherSettingV2"
}

struct PlistVersionSetting:Codable{
    var id = ""
    var printerDetailVersion = ""
    var labelPrinterListVersion = ""
    var kitchenPrinterListVersion = ""
    var bLEPreferenceVersion = ""
    var otherSettingVersion = ""
}

enum PlistKey:String {
    case cellsKey = "cells"
    case detailsKey = "details"
    case detailSettingsKey = "detailSettings"
    case detailInfosKey = "detailInfos"
    case itemsKey = "items"
    case valueKey = "value"
}

enum PrintersType:String {
    case none = "none"
    case normal = "normal" //一般印單機
    case label = "label" //標籤機
}

class PlistHelper {
    static var sharedInstance = PlistHelper()
    let plistName = "PlistVersion"
    
    //MARK: 讀寫Plist資料
    
    /// 儲存內場出單機清單資料至Plist
    ///
    /// - Parameter data: API回傳的訂單dictionary data
    func savePrinterListFromServer(data:[[String : Any]]?){
        //將後台傳來的出單機和標籤機整理成PrinterList物件
        var printerList = [PrinterList]()
        if let dicts = data{
            for KitchenPrinter in dicts{
                let id = KitchenPrinter["id"] as! String
                let showName = KitchenPrinter["showName"] as! String
                let deviceArea = KitchenPrinter["deviceArea"] as! String
                var type = PrintersType.none
                if KitchenPrinter["type"] != nil {
                    type = PrintersType(rawValue:KitchenPrinter["type"] as! String)!
                }
                let pl = PrinterList(id:id, stationName: showName, deviceID:deviceArea, stationIP:"", isIndicator:true, printerSeries:"", printerbrand:"", type:type)
                printerList.append(pl)
            }
            let labelPrinters = printerList.filter {$0.type == PrintersType.label}
            LabelPrinterListModel.sharedInstance.saveLabelPrinterList(list: labelPrinters)
            
            let kitchenPrinters = printerList.filter {$0.type == PrintersType.normal}
            KitchenPrinterListModel.sharedInstance.saveKitchenPrinterList(list: kitchenPrinters)
            
        }
    }
    
    func setID(id:String){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = paths + "/" + plistName + ".plist"
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path))){
            if let bundle  = Bundle.main.path(forResource: plistName, ofType: "plist"){
                do{
                    try fileManager.copyItem(atPath: bundle, toPath: path)
                }catch{
                    print("copy failure.")
                }
                let versionDictionary = NSMutableDictionary(contentsOfFile: path)!
                versionDictionary["id"] = id
                versionDictionary.write(toFile: path, atomically: true)
            }
        }
    }
    
    func getID()->String{
        let plistName = "PlistVersion"
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = paths + "/" + plistName + ".plist"
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path))){
            let bundle  = Bundle.main.path(forResource: plistName, ofType: "plist")
            do{
                try fileManager.copyItem(atPath: bundle!, toPath: path)
            }catch{
                print("copy failure.")
            }
        }
        let versionDictionary = NSDictionary(contentsOfFile: path)!
        let id = versionDictionary["id"] as? String ?? ""
        return id
    }
    
    func getVersion()->PlistVersionSetting{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = paths + "/" + plistName + ".plist"
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path))){
            let bundle  = Bundle.main.path(forResource: plistName, ofType: "plist")
            do{
                try fileManager.copyItem(atPath: bundle!, toPath: path)
            }catch{
                print("copy failure.")
            }
        }
        let versionDictionary = NSDictionary(contentsOfFile: path)!
        let id = versionDictionary["id"] as? String ?? ""
        let printerDetailVersion = versionDictionary["printerDetailVersion"] as? String ?? ""
        let labelPrinterListVersion = versionDictionary["labelPrinterListVersion"] as? String ?? ""
        let kitchenPrinterListVersion = versionDictionary["kitchenPrinterListVersion"] as? String ?? ""
        let bLEPreferenceVersion = versionDictionary["bLEPreferenceVersion"] as? String ?? ""
        let otherSettingVersion = versionDictionary["otherSettingVersion"] as? String ?? ""
        let plistVersionSetting = PlistVersionSetting(id:id, printerDetailVersion: printerDetailVersion, labelPrinterListVersion: labelPrinterListVersion, kitchenPrinterListVersion: kitchenPrinterListVersion, bLEPreferenceVersion: bLEPreferenceVersion, otherSettingVersion: otherSettingVersion)
        return plistVersionSetting
    }
    
    ///取得PlistPathString
    func getPlistPathString(plistString:String) -> String{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = paths + "/" + plistString + ".plist"
        return path
    }
    
    ///取得Plist內容
    func getDataFromPlist(plistName:String) -> NSMutableArray{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = paths + "/" + plistName + ".plist"
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path))){
            if let bundle  = Bundle.main.path(forResource: plistName, ofType: "plist"){
                do{
                    try fileManager.copyItem(atPath: bundle, toPath: path)
                }catch{
                    print("copy failure.")
                }
            }
        }
        
        return NSMutableArray(contentsOfFile: path) ?? []
    }
    
}
