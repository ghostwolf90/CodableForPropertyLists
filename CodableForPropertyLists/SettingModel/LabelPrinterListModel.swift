//
//  LabelPrinterListModel.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/21.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

struct LabelPrinterSection:Codable {
    var sectionName = ""
    var version = ""
    var cells = [LabelPrinterInfo]()
}

struct LabelPrinterInfo:Codable {
    var id = ""
    var labelName = ""
    var labelID = ""
    var labelIP = ""
    var isIndicator = false
    var labelSeries = ""
    var labelbrand = ""
}

class LabelPrinterListModel: NSObject {
    static var sharedInstance = LabelPrinterListModel()
    
    fileprivate let cellsKey = PlistKey.cellsKey.rawValue
    
    //MARK: 傳值給外部使用
    
    ///清除標籤機清單
    func clearLabelPrinterList(){
        let defoutIndex = 0
        let path = plistPath(plistString: PlistName.labelPrinterList.rawValue)
        let labelPrinterPList = getDataFromPlist(plistString: PlistName.labelPrinterList.rawValue)
        guard labelPrinterPList.count > 0 else {
            return
        }
        let modifyLabelPrinterPList:NSMutableArray = []
        var labelPrinterList = labelPrinterPList.object(at: defoutIndex) as! [String: Any]
        labelPrinterList[cellsKey] = modifyLabelPrinterPList
        
        labelPrinterPList.replaceObject(at: defoutIndex, with: modifyLabelPrinterPList)
        labelPrinterPList.write(toFile: path, atomically: true)
    }
    
    ///取得標籤機清單
    func getLabelPrinterList()->[LabelPrinterInfo]{
        let datas = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.labelPrinterList.rawValue) as! [[String: Any]]
        var labelPrinterInfoArray = [LabelPrinterInfo]()
        for itemDictionary in datas {
            let cells = itemDictionary[cellsKey] as! [[String:Any]]
            for cellDic in cells {
                let id = cellDic["id"] as? String ?? ""
                let labelName = cellDic["labelName"] as? String ?? ""
                let labelID = cellDic["labelID"] as? String ?? ""
                let labelIP = cellDic["labelIP"] as? String ?? ""
                let isIndicator = cellDic["isIndicator"] as? Bool ?? false
                let labelSeries = cellDic["labelSeries"] as? String ?? ""
                let labelbrand = cellDic["labelbrand"] as? String ?? ""
                let lpi = LabelPrinterInfo(id: id, labelName: labelName, labelID: labelID, labelIP: labelIP, isIndicator: isIndicator, labelSeries: labelSeries, labelbrand: labelbrand)
                labelPrinterInfoArray.append(lpi)
            }
        }
        return labelPrinterInfoArray
    }
    
    //MARK: 讀寫Plist資料
    
    /// 儲存標籤機清單資料至Plist
    ///
    /// - Parameter data: API回傳的訂單dictionary data
    func saveLabelPrinterList(list:[PrinterList]){
        let defoutIndex = 0
        let path = plistPath(plistString: PlistName.labelPrinterList.rawValue)
        let rootArray = getDataFromPlist(plistString: PlistName.labelPrinterList.rawValue)
        clearLabelPrinterList()
        
        guard rootArray.count > 0 else {
            return
        }
        
        var itemDictionary = rootArray.object(at: defoutIndex) as! [String: Any]
        
        var atPresentPrinterArray  = [[String:Any]]()
        for p in list{
            let printerDictionary:[String:Any] = ["id":p.id, "labelName": p.stationName, "labelID": p.deviceID, "labelIP": "", "isIndicator": true, "labelSeries":"", "labelbrand":""]
            atPresentPrinterArray.append(printerDictionary)
        }
        itemDictionary[cellsKey] = atPresentPrinterArray
        rootArray.replaceObject(at: defoutIndex, with: itemDictionary)
        rootArray.write(toFile: path, atomically: true)
    }
    
    //後台備份資料回寫裝置
    func updateLabelPrinterList(backUplabelPrinterList: [[String:Any]]){
        guard backUplabelPrinterList.count > 0  else {
            return
        }
        
        let defoutIndex = 0
        let path = plistPath(plistString: PlistName.labelPrinterList.rawValue)
        let labelPrinterListPlist = getDataFromPlist(plistString: PlistName.labelPrinterList.rawValue)
        guard labelPrinterListPlist.count > 0 else {
            return
        }
        var labelPrinterList = labelPrinterListPlist.object(at: defoutIndex) as! [String: Any]
        labelPrinterList[cellsKey] = backUplabelPrinterList
        labelPrinterListPlist.replaceObject(at: defoutIndex, with: labelPrinterList)
        labelPrinterListPlist.write(toFile: path, atomically: true)
    }
    
    func reloadLabelPrinterList() -> [LabelPrinterSection] {        
        let datas = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.labelPrinterList.rawValue) as! [[String: Any]]
        
        var kitchenPrinterSectionArray = [LabelPrinterSection]()
        for itemDictionary in datas {
            let cells = itemDictionary[cellsKey] as! [[String:Any]]
            let sectionName = itemDictionary["sectionName"] as! String
            let version = itemDictionary["version"] as! String
            var labelPrinterInfoArray = [LabelPrinterInfo]()
            for cellDic in cells {
                let id = cellDic["id"] as? String ?? ""
                let labelName = cellDic["labelName"] as? String ?? ""
                let labelID = cellDic["labelID"] as? String ?? ""
                let labelIP = cellDic["labelIP"] as? String ?? ""
                let isIndicator = cellDic["isIndicator"] as? Bool ?? false
                let labelSeries = cellDic["labelSeries"] as? String ?? ""
                let labelbrand = cellDic["labelbrand"] as? String ?? ""
                let lpi = LabelPrinterInfo(id: id, labelName: labelName, labelID: labelID, labelIP: labelIP, isIndicator: isIndicator, labelSeries: labelSeries, labelbrand: labelbrand)
                labelPrinterInfoArray.append(lpi)
            }
            let kitchenPrinterSection = LabelPrinterSection(sectionName: sectionName, version:version, cells: labelPrinterInfoArray)
            kitchenPrinterSectionArray.append(kitchenPrinterSection)
        }
        return kitchenPrinterSectionArray
    }
    
    //MARK: 其他
    fileprivate func plistPath(plistString:String) -> String{        
        return PlistHelper.sharedInstance.getPlistPathString(plistString: plistString)
    }
    
    fileprivate func getDataFromPlist(plistString:String) -> NSMutableArray{                
        return PlistHelper.sharedInstance.getDataFromPlist(plistName:plistString)
    }

}
