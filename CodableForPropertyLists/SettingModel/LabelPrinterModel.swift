//
//  LabelPrinterModel.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/18.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

enum LabelPrinterSectionIndex:Int {
    ///開關欄
    case indexLabelPrinterSwitch = 0
    ///標籤機資訊欄
    case indexLabelPrinterInfo = 1
    ///標籤樣式欄
    case indexLabelSetting = 2
}

struct LabelPrintInfo:Codable {
    var id = ""
    var switchStatus = false
    var labelName = ""
    var labelIP = ""
    var labelID = ""
    var labelSensMode = ""
    var labelSize = ""
    var labelType = ""
}

struct LabelPrinter{
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
    var items = [LabelPrinterSections]()
}

struct LabelPrinterSections {
    var detailSectionName = ""
    var details = [Any]()
}

struct LabelPrinterDetailInfos {
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
    var detialInfos = [UnitDetail]()
}

enum LabelPrintSection:Int {
    ///基本資訊欄
    case infoSection = 0
    enum InfoRows:Int{
        case switchRow = 0
    }
    //輸入IP欄位
    case ipSection = 1
    enum IPRows:Int{
        case deviceIDRow = 0
        case ipRow = 1
    }
    //出單設定欄位
    case settingSection = 2
    enum SettingRows:Int{
        case labelSensModeRow = 0
        case labelSizeRow = 1
        case labelTypeRow = 2
    }
}

class LabelPrinterModel: NSObject {
    static var sharedInstance = LabelPrinterModel()
    
    fileprivate let cellsKey = PlistKey.cellsKey.rawValue
    fileprivate let detailsKey = PlistKey.detailsKey.rawValue
    fileprivate let detailSettingsKey = PlistKey.detailSettingsKey.rawValue
    fileprivate let detailInfosKey = PlistKey.detailInfosKey.rawValue
    fileprivate let itemsKey = PlistKey.itemsKey.rawValue
    fileprivate let valueKey = PlistKey.valueKey.rawValue
    //MARK: 傳值給外部使用
    
    ///寫入ip
    func setIPAddress(ip:String, labelPrinterInfo:LabelPrinterInfo){
        let modifyLabelPrinterPList:NSMutableArray = []
        let path = plistPath(plistString: "LabelPrinter")
        var labelPrinterPlists = getDataFromPlist(plistString: "LabelPrinter")
        for labelPrinterPlist in labelPrinterPlists{
            var labelPrinter = labelPrinterPlist as! [String:Any]
            let idForPlist = labelPrinter["id"] as? String ?? ""
            if labelPrinterInfo.id == idForPlist {
                var labelPrinterItems = labelPrinter["items"] as! [[String:Any]]
                var labelTargetInfo = labelPrinterItems[LabelPrintSection.ipSection.rawValue]
                var details = labelTargetInfo["details"] as! [[String: Any]]
                details[LabelPrintSection.IPRows.ipRow.rawValue]["value"] = ip
                labelTargetInfo["details"] = details
                labelPrinterItems[LabelPrintSection.ipSection.rawValue] = labelTargetInfo
                labelPrinter["items"] = labelPrinterItems
            }
            modifyLabelPrinterPList.add(labelPrinter)
        }
        labelPrinterPlists = modifyLabelPrinterPList
        labelPrinterPlists.write(toFile: path, atomically: true)        
    }
    
    ///由id取得標籤機是否開啟列印
    func getLabelPriinterSwitchStatus(id:String)->String{
        var switchStatus = false
        let labelPrintList = getLabelPrinterInfos()
        for labelPrint in labelPrintList{
            if id == labelPrint.id{
                switchStatus = labelPrint.switchStatus
                break
            }
        }
        return switchStatus == false ? "關閉":"開啟"
    }
    
    ///由id取得標籤機ipAddress
    func getLabelPriinterIpAddress(id:String)->String{
        let labelPrintList = getLabelPrinterInfos()
        let currentPrinterAreaInfoResult = labelPrintList.filter{ labelPrint in
            if id == labelPrint.id {
                return true
            }
            return false
        }
        guard let currentPrinterAreaInfo = currentPrinterAreaInfoResult.first else{
            return ""
        }                
        return currentPrinterAreaInfo.labelIP
    }
    
    ///取得標籤機清單
    func getLabelPrinterInfos() -> [LabelPrintInfo]{
        //標籤機的樣板設定plist，提取標籤機檔案時樣板不需提取出來使用
        let templateLabelID = "6d41f007-1d0d-4478-c22"
        var labelPrints = [LabelPrintInfo]()
        let labelPrinterInfos = self.loadLabelPrinterList()
        for labelPrinterInfo in labelPrinterInfos{
            guard labelPrinterInfo.id != templateLabelID else{
                continue
            }

            let id = labelPrinterInfo.id
            let labelInfo = labelPrinterInfo.items[LabelPrintSection.infoSection.rawValue].details as! [UnitDetail]
            let labelName = labelInfo[LabelPrintSection.InfoRows.switchRow.rawValue].title
            let switchStatu = labelInfo[LabelPrintSection.InfoRows.switchRow.rawValue].value == "0" ? false:true
            
            let labelIPInfo = labelPrinterInfo.items[LabelPrintSection.ipSection.rawValue].details as! [UnitDetail]
            let labelID = labelIPInfo[LabelPrintSection.IPRows.deviceIDRow.rawValue].value
            let labelIP = labelIPInfo[LabelPrintSection.IPRows.ipRow.rawValue].value
            
            let settingInfos = labelPrinterInfo.items[LabelPrintSection.settingSection.rawValue].details[0] as! LabelPrinterDetailInfos
            let labelSensMode = settingInfos.detialInfos[LabelPrintSection.SettingRows.labelSensModeRow.rawValue].value
            let labelSize = settingInfos.detialInfos[LabelPrintSection.SettingRows.labelSizeRow.rawValue].value
            let labelType = settingInfos.detialInfos[LabelPrintSection.SettingRows.labelTypeRow.rawValue].value
            let labelPrint = LabelPrintInfo(id:id, switchStatus: switchStatu, labelName:labelName, labelIP: labelIP, labelID:labelID, labelSensMode: labelSensMode, labelSize: labelSize, labelType: labelType)
            labelPrints.append(labelPrint)
        }
        return labelPrints
    }
    
    //MARK: 讀寫Plist資料
    func clearLabelPrinterPlist(){
        let path = plistPath(plistString: PlistName.labelPrinter.rawValue)
        let labelPrinterPList = getDataFromPlist(plistString: PlistName.labelPrinter.rawValue)
        guard labelPrinterPList.count > 0 else {
            return
        }
        labelPrinterPList.removeAllObjects()
        labelPrinterPList.write(toFile: path, atomically: true)
    }
    
    
    //後台備份資料回寫裝置
    func updateLabelPrinter(backUplabelPrinters: [[String:Any]]){
        guard backUplabelPrinters.count > 0 else {
            return
        }
        var labelPrinterObjects = [LabelPrintInfo]()
        for backUplabelPrinter in backUplabelPrinters{
            let id = backUplabelPrinter["id"] as? String ?? ""
            let switchStatus = backUplabelPrinter["switchStatus"] as? Bool ?? false
            let labelName = backUplabelPrinter["labelName"] as? String ?? ""
            let labelIP = backUplabelPrinter["labelIP"] as? String ?? ""
            let labelID = backUplabelPrinter["labelID"] as? String ?? ""
            let labelSensMode = backUplabelPrinter["labelSensMode"] as? String ?? ""
            let labelSize = backUplabelPrinter["labelSize"] as? String ?? ""
            let labelType = backUplabelPrinter["labelType"] as? String ?? ""
            let labelPrintInfo = LabelPrintInfo(id: id, switchStatus: switchStatus, labelName:labelName, labelIP: labelIP, labelID: labelID, labelSensMode: labelSensMode, labelSize: labelSize, labelType: labelType)
            labelPrinterObjects.append(labelPrintInfo)
        }
       
        let modifyLabelPrinterPList:NSMutableArray = []
        let path = plistPath(plistString: PlistName.labelPrinter.rawValue)
        var labelPrinterPlists = getDataFromPlist(plistString: PlistName.labelPrinter.rawValue)
        clearLabelPrinterPlist()
        
        for labelPrinter in labelPrinterObjects{
            let labelPrinterDetail = addLabelPrinter(labelPrintInfo: labelPrinter, labelPrinterPList: labelPrinterPlists)
            modifyLabelPrinterPList.add(labelPrinterDetail)
        }
        labelPrinterPlists = modifyLabelPrinterPList
        labelPrinterPlists.write(toFile: path, atomically: true)
    }
    
    fileprivate func addLabelPrinter(labelPrintInfo:LabelPrintInfo, labelPrinterPList:NSMutableArray) -> [String:Any]{
        let defultSetting = "0"
        let labelPrinterLists = labelPrinterPList
        var printerList = labelPrinterLists[0] as! [String:Any]
        printerList["id"] = labelPrintInfo.id
        printerList["title"] = labelPrintInfo.id
        var items = printerList["items"] as! [[String:Any]]
        var printSwitchItem = items[LabelPrintSection.infoSection.rawValue]
        var printInfoItem = items[LabelPrintSection.ipSection.rawValue]
        var otherSettingItem = items[LabelPrintSection.settingSection.rawValue]
        
        //初始化標籤機開關
        var details = printSwitchItem["details"] as! [[String: Any]]
        details[LabelPrintSection.InfoRows.switchRow.rawValue]["title"] = labelPrintInfo.labelName
        details[LabelPrintSection.InfoRows.switchRow.rawValue]["value"] = labelPrintInfo.switchStatus == false ? "0":"1"
        printSwitchItem["details"] = details
        items[LabelPrintSection.infoSection.rawValue] = printSwitchItem
        
        //初始化標籤機名稱和IP
        details = printInfoItem["details"] as! [[String: Any]]
        details[LabelPrintSection.IPRows.deviceIDRow.rawValue]["value"] = labelPrintInfo.labelID
        details[LabelPrintSection.IPRows.ipRow.rawValue]["value"] = labelPrintInfo.labelIP
        printInfoItem["details"] = details
        items[LabelPrintSection.ipSection.rawValue] = printInfoItem
        
        //初始化其他
        details = otherSettingItem["details"] as! [[String: Any]]
        
        var detailInfos = details[0]["detailInfos"] as! [[String: Any]]
        detailInfos[LabelPrintSection.SettingRows.labelSensModeRow.rawValue]["value"] = labelPrintInfo.labelSensMode
        detailInfos[LabelPrintSection.SettingRows.labelSizeRow.rawValue]["value"] = labelPrintInfo.labelSize
        detailInfos[LabelPrintSection.SettingRows.labelTypeRow.rawValue]["value"] = labelPrintInfo.labelType
        details[0]["detailInfos"] = detailInfos
        
        details[0]["value"] = defultSetting
        otherSettingItem["details"] = details
        items[LabelPrintSection.settingSection.rawValue] = otherSettingItem
        printerList["items"] = items
        return printerList
    }
    
    fileprivate func updateKitchenPrinterDetail(labelPrinterTemp:[String:Any], labelPrinter:LabelPrintInfo) -> [String:Any]{
         let defultSetting = "0"
        var labelPrinterPlistTemp = labelPrinterTemp
        labelPrinterPlistTemp["id"] = labelPrinter.id
        labelPrinterPlistTemp["title"] = labelPrinter.id
        var items = labelPrinterPlistTemp["items"] as! [[String:Any]]
        var printSwitchItem = items[LabelPrintSection.infoSection.rawValue]
        var printInfoItem = items[LabelPrintSection.ipSection.rawValue]
        var otherSettingItem = items[LabelPrintSection.settingSection.rawValue]
        
        //初始化標籤機開關
        var details = printSwitchItem["details"] as! [[String: Any]]
        details[LabelPrintSection.InfoRows.switchRow.rawValue]["title"] = labelPrinter.labelName //名稱
        details[LabelPrintSection.InfoRows.switchRow.rawValue]["value"] = labelPrinter.switchStatus == false ? "0":"1"
        printSwitchItem["details"] = details
        items[LabelPrintSection.infoSection.rawValue] = printSwitchItem
        
        //初始化標籤機名稱和IP
        details = printInfoItem["details"] as! [[String: Any]]
        details[LabelPrintSection.IPRows.deviceIDRow.rawValue]["value"] = labelPrinter.labelID
        details[LabelPrintSection.IPRows.ipRow.rawValue]["value"] = labelPrinter.labelIP
        printInfoItem["details"] = details
        items[LabelPrintSection.ipSection.rawValue] = printInfoItem
        
        //初始化其他
        details = otherSettingItem["details"] as! [[String: Any]]
        
        var detailInfos = details[0]["detailInfos"] as! [[String: Any]]
        detailInfos[LabelPrintSection.SettingRows.labelSensModeRow.rawValue]["value"] = labelPrinter.labelSensMode
        detailInfos[LabelPrintSection.SettingRows.labelSizeRow.rawValue]["value"] = labelPrinter.labelSize
        detailInfos[LabelPrintSection.SettingRows.labelTypeRow.rawValue]["value"] = labelPrinter.labelType
        details[0]["detailInfos"] = detailInfos
        
        details[0]["value"] = defultSetting
        otherSettingItem["details"] = details
        items[LabelPrintSection.settingSection.rawValue] = otherSettingItem
        labelPrinterPlistTemp["items"] = items
        
        return labelPrinterPlistTemp
    }
    
    func fetchLabelPrinterInfo(labelPrinterInfo:LabelPrinterInfo) -> LabelPrinter{
        var labelPrinter = LabelPrinter()
        let labelPrinters = loadLabelPrinterList()
        
        let kitchenPrinterisExist = labelPrinters.filter{$0.id == labelPrinterInfo.id}
        if kitchenPrinterisExist.count > 0 {
            labelPrinter = kitchenPrinterisExist.first!
        }else{
            addLabelPrinterDetail(labelPrinterInfo: labelPrinterInfo)
            let labelPrintersAgain = loadLabelPrinterList()
            labelPrinter = labelPrintersAgain.filter{ $0.id == labelPrinterInfo.id}.first!
        }
        return labelPrinter
    }
    
    ///新增標籤機資訊
    fileprivate func addLabelPrinterDetail(labelPrinterInfo:LabelPrinterInfo){
        let path = plistPath(plistString: PlistName.labelPrinter.rawValue)
        let labelPrinterLists = getDataFromPlist(plistString: PlistName.labelPrinter.rawValue)
        guard labelPrinterLists.count > 0 else {
            return 
        }
        let defultSetting = "0"
        
        var printerList = labelPrinterLists[0] as! [String:Any]
        printerList["id"] = labelPrinterInfo.id
        printerList["title"] = labelPrinterInfo.id

        var items = printerList[itemsKey] as! [[String:Any]]
        var printSwitchItem = items[LabelPrintSection.infoSection.rawValue]
        var printInfoItem = items[LabelPrintSection.ipSection.rawValue]
        var otherSettingItem = items[LabelPrintSection.settingSection.rawValue]
        
        //初始化標籤機開關
        var details = printSwitchItem[detailsKey] as! [[String: Any]]
        details[LabelPrintSection.InfoRows.switchRow.rawValue]["title"] = labelPrinterInfo.labelName
        details[LabelPrintSection.InfoRows.switchRow.rawValue][valueKey] = defultSetting
        printSwitchItem[detailsKey] = details
        items[LabelPrintSection.infoSection.rawValue] = printSwitchItem
        
        //初始化標籤機名稱和IP
        details = printInfoItem[detailsKey] as! [[String: Any]]
        details[LabelPrintSection.IPRows.deviceIDRow.rawValue][valueKey] = labelPrinterInfo.labelID
        details[LabelPrintSection.IPRows.ipRow.rawValue][valueKey] = labelPrinterInfo.labelIP
        printInfoItem[detailsKey] = details
        items[LabelPrintSection.ipSection.rawValue] = printInfoItem
        
        //初始化其他
        details = otherSettingItem[detailsKey] as! [[String: Any]]
        
        var detailInfos = details[0][detailInfosKey] as! [[String: Any]]
        detailInfos[LabelPrintSection.SettingRows.labelSensModeRow.rawValue][valueKey] = defultSetting
        detailInfos[LabelPrintSection.SettingRows.labelSizeRow.rawValue][valueKey] = defultSetting
        detailInfos[LabelPrintSection.SettingRows.labelTypeRow.rawValue][valueKey] = defultSetting
        details[0][detailInfosKey] = detailInfos
        
        details[0][valueKey] = defultSetting
        otherSettingItem[detailsKey] = details
        items[LabelPrintSection.settingSection.rawValue] = otherSettingItem

        //寫入資料
        printerList[itemsKey] = items
        labelPrinterLists.add(printerList)
        labelPrinterLists.write(toFile: path, atomically: true)
    }
    
    //取得標籤資訊
    func loadLabelPrinterList()->[LabelPrinter]{
        var labelPrinters = [LabelPrinter]()
        let kitchenPrinterDetails = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.labelPrinter.rawValue) as! [[String: Any]]
        for kitchenPrinterDetail in kitchenPrinterDetails{
            var labelPrinterSections = [LabelPrinterSections]()
            
            let id = kitchenPrinterDetail["id"] as? String ?? ""
            let title = kitchenPrinterDetail["title"] as? String ?? ""
            let subTitle = kitchenPrinterDetail["subTitle"] as? String ?? ""
            let isIndicator = kitchenPrinterDetail["isIndicator"] as? Bool ?? false
            let displayType = kitchenPrinterDetail["displayType"] as? String ?? ""
            let value = kitchenPrinterDetail[valueKey] as? String ?? ""
            let items = kitchenPrinterDetail[itemsKey] as! [[String:Any]]
            for item in items{
                var LabelPrinterDetails = [Any]()
                let detailSectionName = item["detailSectionName"] as? String ?? ""
                let details = item[detailsKey] as? [[String:Any]] ?? [[String:Any]]()
                for detail in details{
                    var lpd:Any?
                    let id = detail["id"] as? String ?? ""
                    if id == "樣式"{
                        var labelPrinterDetailInfos = [UnitDetail]()
                        let title = detail["title"] as? String ?? ""
                        let subTitle = detail["subTitle"] as? String ?? ""
                        let isIndicator = detail["isIndicator"] as? Bool ?? false
                        let displayType = detail["displayType"] as? String ?? ""
                        let value = detail[valueKey] as? String ?? ""
                        let detailInfos = detail[detailInfosKey] as? [[String:Any]] ?? [[String:Any]]()
                        for detailInfo in detailInfos{
                            let id = detailInfo["id"] as? String ?? ""
                            let title = detailInfo["title"] as? String ?? ""
                            let subTitle = detailInfo["subTitle"] as? String ?? ""
                            let isIndicator = detailInfo["isIndicator"] as? Bool ?? false
                            let displayType = detailInfo["displayType"] as? String ?? ""
                            let value = detailInfo[valueKey] as? String ?? ""
                            let lpdInfo = UnitDetail(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value)
                            labelPrinterDetailInfos.append(lpdInfo)
                        }
                        lpd = LabelPrinterDetailInfos(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value, detialInfos:labelPrinterDetailInfos)
                    }else{
                        let title = detail["title"] as? String ?? ""
                        let subTitle = detail["subTitle"] as? String ?? ""
                        let isIndicator = detail["isIndicator"] as? Bool ?? false
                        let displayType = detail["displayType"] as? String ?? ""
                        let value = detail[valueKey] as? String ?? ""
                        lpd = UnitDetail(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value)
                    }
                    
                    LabelPrinterDetails.append(lpd)
                }
                let kps = LabelPrinterSections(detailSectionName: detailSectionName, details: LabelPrinterDetails)
                labelPrinterSections.append(kps)
            }
            let kp = LabelPrinter(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value, items: labelPrinterSections)
            labelPrinters.append(kp)
        }
        return labelPrinters
    }
    
    func reloadLabelPrinterInfo() -> [PrinterDetailSection] {
        var printerDetailSectionArray = [PrinterDetailSection]()        
        let printerDetails = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.labelPrinter.rawValue) as! [[String: Any]]
        for printerDetail in printerDetails {
            var printerDetailArray = [PrinterDetail]()
            let sectionName = printerDetail["sectionName"] as! String
            let cells = printerDetail[cellsKey] as! [[String:Any]]
            for cellDic in cells {
              
            }
            let pdetailSection = PrinterDetailSection(sectionName: sectionName, cells: printerDetailArray)
            printerDetailSectionArray.append(pdetailSection)
        }
        return printerDetailSectionArray
    }
    
    ///寫入標籤機樣式設定功能
    func setLabelPrintDownMenu(detialInfos:[UnitDetail], labelPrinterInfo:LabelPrinterInfo, selectlistIndexPath:IndexPath){
        var replaceRowIndex = 0
        var labelPrinter = [String:Any]()
        let path = plistPath(plistString: PlistName.labelPrinter.rawValue)
        let labelPrinterLists = getDataFromPlist(plistString: PlistName.labelPrinter.rawValue)
        for (index, items) in labelPrinterLists.enumerated(){
            let item = items as! [String: Any]
            let id = item["id"] as! String
            if labelPrinterInfo.id == id{
                labelPrinter = item
                replaceRowIndex = index
            }
        }
        
        var items = labelPrinter[itemsKey] as! [[String:Any]]
        var otherSettingItem = items[LabelPrintSection.settingSection.rawValue]
        
        //更新其他
        var details = otherSettingItem[detailsKey] as! [[String: Any]]
        var detailInfos = details[0][detailInfosKey] as! [[String: Any]]
        detailInfos[LabelPrintSection.SettingRows.labelSensModeRow.rawValue][valueKey] = detialInfos[0].value
        detailInfos[LabelPrintSection.SettingRows.labelSizeRow.rawValue][valueKey] = detialInfos[1].value
        detailInfos[LabelPrintSection.SettingRows.labelTypeRow.rawValue][valueKey] = detialInfos[2].value
        details[0][detailInfosKey] = detailInfos
        
        otherSettingItem[detailsKey] = details
        items[LabelPrintSection.settingSection.rawValue] = otherSettingItem
        
        //寫入資料
        labelPrinter[itemsKey] = items
        labelPrinterLists.replaceObject(at: replaceRowIndex, with: labelPrinter)
        labelPrinterLists.write(toFile: path, atomically: true)
    }
    
    ///寫入標籤機IP
    func updateLabelPrinterIP(indexPath:IndexPath, ipAddress:String, labelPrinterInfo:LabelPrinterInfo){
        var replaceRowIndex = 0
        var labelPrinter = [String:Any]()
        let path = plistPath(plistString: PlistName.labelPrinter.rawValue)
        let labelLists = getDataFromPlist(plistString: PlistName.labelPrinter.rawValue)
        for (index, items) in labelLists.enumerated(){
            let item = items as! [String: Any]
            let id = item["id"] as! String
            if labelPrinterInfo.id == id{
                labelPrinter = item
                replaceRowIndex = index
            }
        }
        
        var items = labelPrinter[itemsKey] as! [[String: Any]]
        var item = items[LabelPrinterSectionIndex.indexLabelPrinterInfo.rawValue]
        var details = item[detailsKey] as! [[String: Any]]
        details[1][valueKey] = ipAddress
        
        //寫入資料
        item[detailsKey] = details
        items[LabelPrinterSectionIndex.indexLabelPrinterInfo.rawValue] = item
        labelPrinter[itemsKey] = items
        labelLists.replaceObject(at: replaceRowIndex, with: labelPrinter)
        labelLists.write(toFile: path, atomically: true)
    }
    
    ///改變標籤機switch狀態
    func changeSwitchEnable(indexPath:IndexPath, switchEnable:Bool, labelPrinterInfo:LabelPrinterInfo){
        var replaceRowIndex = 0
        var labelPrinter = [String:Any]()
        let path = plistPath(plistString: PlistName.labelPrinter.rawValue)
        let labelLists = getDataFromPlist(plistString: PlistName.labelPrinter.rawValue)
        for (index, items) in labelLists.enumerated(){
            let item = items as! [String: Any]
            let id = item["id"] as! String
            if labelPrinterInfo.id == id{
                labelPrinter = item
                replaceRowIndex = index
            }
        }
        
        var items = labelPrinter[itemsKey] as! [[String: Any]]
        var item = items[LabelPrinterSectionIndex.indexLabelPrinterSwitch.rawValue]
        var details = item[detailsKey] as! [[String: Any]]
        details[0][valueKey] = switchEnable == false ? "0":"1"
        
        //寫入資料
        item[detailsKey] = details
        items[LabelPrinterSectionIndex.indexLabelPrinterSwitch.rawValue] = item
        labelPrinter[itemsKey] = items
        labelLists.replaceObject(at: replaceRowIndex, with: labelPrinter)
        labelLists.write(toFile: path, atomically: true)
        
        //改變出單機清單的開關狀態
        changeLabelPrinterListEnable(indexPath: indexPath, switchEnable: switchEnable)
    }
    
    func changeLabelPrinterListEnable(indexPath:IndexPath, switchEnable:Bool){
        let path = plistPath(plistString: PlistName.labelPrinterList.rawValue)
        
        let printerDetails = getDataFromPlist(plistString: PlistName.labelPrinterList.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var items = printerDetails.object(at: indexPath.section) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var cellDic = cells[indexPath.row]
        cellDic["isOpen"] = switchEnable
        
        //寫入資料
        cells[indexPath.row] = cellDic
        items[cellsKey] = cells
        printerDetails.replaceObject(at: indexPath.section, with: items)
        printerDetails.write(toFile: path, atomically: true)
    }
    

    
    //MARK: 其他
    fileprivate func plistPath(plistString:String) -> String{        
        return PlistHelper.sharedInstance.getPlistPathString(plistString: plistString)
    }
    
    fileprivate func getDataFromPlist(plistString:String) -> NSMutableArray{                
        return PlistHelper.sharedInstance.getDataFromPlist(plistName:plistString)
    }

}
