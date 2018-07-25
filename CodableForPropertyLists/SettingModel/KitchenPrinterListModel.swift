//
//  KitchenPrinterListModel.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/19.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

struct KitchenPrinterSection:Codable {
    var sectionName = ""
    var version = ""
    var cells = [KitchenPrinterInfo]()
}

struct KitchenPrinterInfo:Codable {
    var id = ""
    var stationName = ""
    var deviceID = ""
    var stationIP = ""
    var printerSeries = ""
    var printerbrand = ""
    var isIndicator = true
}

class KitchenPrinterListModel: NSObject {
    
    static var sharedInstance = KitchenPrinterListModel()
    fileprivate let cellsKey = PlistKey.cellsKey.rawValue
    
    //MARK: 傳值給外部使用
    
    ///清除出單機清單
    func clearKitchenPrinterList(){
        let defoutIndex = 0
        let path = plistPath(plistString: PlistName.kitchenPrinterList.rawValue)
        let kitchenPrinterPList = getDataFromPlist(plistString: PlistName.kitchenPrinterList.rawValue)
        guard kitchenPrinterPList.count > 0 else {
            return
        }
        let modifyKitchenPrinterPList:NSMutableArray = []
        var kitchenPrinterList = kitchenPrinterPList.object(at: defoutIndex) as! [String: Any]
        kitchenPrinterList[cellsKey] = modifyKitchenPrinterPList
        
        kitchenPrinterPList.replaceObject(at: defoutIndex, with: kitchenPrinterList)
        kitchenPrinterPList.write(toFile: path, atomically: true)
    }
    
    ///取得內場出單機清單
    func getKitchenPrinterList()->[KitchenPrinterInfo]{
        let datas = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.kitchenPrinterList.rawValue) as! [[String: Any]]
        var kitchenPrinterList = [KitchenPrinterInfo]()
        for itemDictionary in datas {
            let cells = itemDictionary[cellsKey] as! [[String:Any]]
            for cellDic in cells {
                let id = cellDic["id"] as? String ?? ""
                let stationName = cellDic["stationName"] as? String ?? ""
                let deviceID = cellDic["deviceID"] as? String ?? ""
                let stationIP = cellDic["stationIP"] as? String ?? ""
                let printerSeries = cellDic["printerSeries"] as? String ?? ""
                let printerbrand = cellDic["printerbrand"] as? String ?? ""
                let kpInfo = KitchenPrinterInfo(id:id, stationName: stationName, deviceID:deviceID, stationIP:stationIP, printerSeries:printerSeries, printerbrand:printerbrand, isIndicator:true)
                kitchenPrinterList.append(kpInfo)
            }
        }
        return kitchenPrinterList
    }
    
    //MARK: 讀寫Plist資料
    
    /// 儲存內場出單機清單資料至Plist
    ///
    /// - Parameter data: API回傳的訂單dictionary data
    func saveKitchenPrinterList(list:[PrinterList]){
        let defoutIndex = 0
        let path = plistPath(plistString: PlistName.kitchenPrinterList.rawValue)
        let rootArray = getDataFromPlist(plistString: PlistName.kitchenPrinterList.rawValue)
        clearKitchenPrinterList()
    
        guard rootArray.count > 0 else {
            return
        }
        
        var itemDictionary = rootArray.object(at: defoutIndex) as! [String: Any]
        
        var atPresentPrinterArray  = [[String:Any]]()
        for p in list{
            let printerDictionary:[String:Any] = ["id":p.id, "stationName": p.stationName, "deviceID": p.deviceID, "stationIP": "", "isIndicator": true, "printerSeries":"", "printerbrand":""]
            atPresentPrinterArray.append(printerDictionary)
        }
        itemDictionary[cellsKey] = atPresentPrinterArray
        rootArray.replaceObject(at: defoutIndex, with: itemDictionary)
        rootArray.write(toFile: path, atomically: true)
    }
    
    ///後台備份資料回寫桌邊出單機設定
    func updateKitchenPrinter(backUpKitchenPrinter: [[String:Any]]){        
        let defoutIndex = 0
        let path = plistPath(plistString: PlistName.kitchenPrinterList.rawValue)
        let kitchenPrinterListPlist = getDataFromPlist(plistString: PlistName.kitchenPrinterList.rawValue)
        guard kitchenPrinterListPlist.count > 0 else {
            return
        }
        var kitchenPrinterList = kitchenPrinterListPlist.object(at: defoutIndex) as! [String: Any]
        
        kitchenPrinterList[cellsKey] = backUpKitchenPrinter
        kitchenPrinterListPlist.replaceObject(at: defoutIndex, with: kitchenPrinterList)
        kitchenPrinterListPlist.write(toFile: path, atomically: true)
    }
    
    func reloadPrinterList() -> [KitchenPrinterSection] {        
        let datas = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.kitchenPrinterList.rawValue) as! [[String: Any]]
        
        var tempOutputArray = [KitchenPrinterSection]()
        for itemDictionary in datas {
            let cells = itemDictionary[cellsKey] as! [[String:Any]]
            let sectionName = itemDictionary["sectionName"] as! String
            let version = itemDictionary["version"] as! String
            var kitchenPrinterInfoArray = [KitchenPrinterInfo]()
            for cellDic in cells {
                let id = cellDic["id"] as? String ?? ""
                let stationName = cellDic["stationName"] as? String ?? ""
                let deviceID = cellDic["deviceID"] as? String ?? ""
                let stationIP = cellDic["stationIP"] as? String ?? ""
                let printerSeries = cellDic["printerSeries"] as? String ?? ""
                let printerbrand = cellDic["printerbrand"] as? String ?? ""
                let kpInfo = KitchenPrinterInfo(id:id, stationName: stationName, deviceID:deviceID, stationIP:stationIP, printerSeries:printerSeries, printerbrand:printerbrand, isIndicator:true)
                kitchenPrinterInfoArray.append(kpInfo)
            }
            let kitchenPrinterSection = KitchenPrinterSection(sectionName: sectionName, version:version, cells: kitchenPrinterInfoArray)
            tempOutputArray.append(kitchenPrinterSection)
        }
        return tempOutputArray
    }
    
    //MARK: 其他
    fileprivate func plistPath(plistString:String) -> String{
        return PlistHelper.sharedInstance.getPlistPathString(plistString: plistString)
    }
    
    fileprivate func getDataFromPlist(plistString:String) -> NSMutableArray{        
        return PlistHelper.sharedInstance.getDataFromPlist(plistName:plistString)
    }

}
