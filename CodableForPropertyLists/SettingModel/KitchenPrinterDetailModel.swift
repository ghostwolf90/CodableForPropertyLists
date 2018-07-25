//
//  KitchenPrinterDetailModel.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/20.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

enum SimpleImageType {
    case labelOrder
    case kitchenOrder
}

enum PrinterType:Int {
    case printerWay = 0
    case displayItemWay = 1
    case pageSize = 2
    case spaceHeight = 3
    case sheetQuantity = 4
}

enum LabelType:Int {
    case labelSensMode = 0
    case labelSize = 1
    case labelType = 2
}


//印單樣式
enum PrinterStyle : String{
    ///無
    case none
    ///印單方式
    case printerWay
    ///排列方式
    case displayItemWay
    ///出單機紙張大小
    case pageSize
    ///紙張抬頭高度
    case spaceHeight
    ///大單數量
    case sheetQuantity
    ///標籤機 - 感測方式
    case labelSensMode
    ///標籤機 - 貼紙大小
    case labelSize
    ///標籤機 - 貼紙排版
    case labelType
}

//印單方式
enum PrinterWay:Int {
    ///長單呈現
    case oneLongSheet = 0
    ///短單呈現
    case oneShortSheet = 1
    ///長單與短單兩份呈現
    case twoLongAndShortSheet = 2
}
enum PrinterWayValue:String {
    ///長單呈現
    case longSheet = "0"
    ///短單呈現
    case shortSheet = "1"
    ///長單與短單兩份呈現
    case longAndShortSheet = "2"
}
//品項呈現
enum DisplayItemWay:Int {
    ///整合
    case integration
    ///拆分
    case split
}
//紙張大小
enum PageSize:Int {
    case size57 = 0
    case size8 = 1
}
//夾單空間
enum SpaceHeight:Int {
    case none = 0
    case open = 1
}
//感測方式
enum LabelSensModeWay:Int {
    ///間隙紙
    case directThermal
    ///黑標紙
    case thermalTransfer
}
//貼紙大小
enum LabelSizeWay:Int {
    ///四公分
    case fourSize
    ///三點五公分
    case threeHalfSize
}
//貼紙排版
enum LabelTypeWay:Int {
    ///店名位置在右上角
    case typeA
    ///店名位置在下方
    case typeB
}

struct PrinterList{
    var id              : String
    var stationName     : String
    var deviceID        : String
    var stationIP       : String
    var isIndicator     : Bool
    var printerSeries   : String
    var printerbrand    : String
    var type            : PrintersType
}

//內場出單機架構
struct KitchenPrinter{
    struct KitchenPrinterSections{
        var detailSectionName = ""
        var details = [Any]()
    }
    
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
    var items = [KitchenPrinterSections]()
}

struct UnitDetail:Codable {
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
}

struct KitchenPrinterDetailInfos {
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
    var detialInfos = [UnitDetail]()
}

//傳值給外部使用struct
struct KitchenPrinterDevice:Codable {
    var id = ""
    var stationName = ""
    var deviceID = ""
    var stationIP = ""
    var printerSeries = ""
    var printerbrand = ""
}

struct KitchenDeviceInfo:Codable {
    var id = ""
    var deviceName = ""
    var deviceID = ""
    var switchStatus = false
    var printerWay = ""
    var displayItemWay = ""
    var buzzerVolume = ""
    var pageSize = ""
    var spaceHeight = ""
    var sheetQuantity = ""
    var printerList = [KitchenPrinterDevice]()
}

//enum
enum KitchPrintSection:Int {
    ///基本訊息欄
    case infoSection = 0
    enum DeviceInfoRows:Int {
        case deviceNameRow = 0
        case deviceID = 1
    }
    //是否啟用欄位
    case switchSection = 1
    enum SwitchRows:Int{
        case switchRow = 0
    }
    //其他設定欄位
    case settingSection = 2
    enum SettingsRows:Int {
        case orderType = 0
        case buzzer = 1
    }
    //收尋出單機欄位
    case deviceSection = 3
}

class KitchenPrinterDetailModel: NSObject {
    static var sharedInstance = KitchenPrinterDetailModel()
    fileprivate let tablePrinterUUID = "c1ae6243-6727-4f19-bae8-ae30075d77b2"
    fileprivate let cellsKey = PlistKey.cellsKey.rawValue
    fileprivate let detailsKey = PlistKey.detailsKey.rawValue
    fileprivate let valueKey = PlistKey.valueKey.rawValue
    
    //MARK: 傳值給外部使用
    
    /// 檢查週邊出單機是否吻合所選的出單機，比對後如果沒有就刪除
    ///
    /// - Parameters:
    ///   - selectKitchenPrinterInfo:
    ///   - aroundPrinter:
    func comparisonPlistPrinter(selectKitchenPrinterInfo:KitchenPrinterInfo, aroundPrinter:[TablePrinterInfo]){
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        var replaceRowIndex = 0
        var kitchenPrinter = [String:Any]()
        let printerDetails = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        let currentPrinterAreaInfoResult = printerDetails.filter{ items in
            if let item = items as? [String: Any], let id = item["id"] as? String{
                    return selectKitchenPrinterInfo.id == id
            }
            return false
        }
        
        // 找無對應的出單區
        guard let currentPrinterAreaInfo = currentPrinterAreaInfoResult.first as?  [String: Any] else{
            return
        }
        
        kitchenPrinter = currentPrinterAreaInfo
        replaceRowIndex = printerDetails.index(of: currentPrinterAreaInfo)

        var items = kitchenPrinter["items"] as! [[String:Any]]
        var searchDeviceItem = items[KitchPrintSection.deviceSection.rawValue]
        var plistDeviceList = searchDeviceItem[detailsKey] as! [[String: Any]]

        var isEdit = false
        for (index,plistPrnter) in plistDeviceList.enumerated().reversed(){
            var isExist = false
            let stationIP = plistPrnter["stationIP"] as? String ?? ""
            for aroundPrnter in aroundPrinter{
                //比對如果plist的出單機沒有和周邊出單機
                if stationIP == aroundPrnter.stationIP{
                    isExist = true
                    break
                }
            }
            // 若找無對應的ip則刪除
            if !isExist{
                isEdit = true
                plistDeviceList.remove(at: index)
            }
        }
        
        //如果沒有更新直接跳出
        if !isEdit{
            return
        }
        
        // 儲存Plist
        searchDeviceItem[detailsKey] = plistDeviceList
        items[KitchPrintSection.deviceSection.rawValue] = searchDeviceItem
        kitchenPrinter["items"] = items
        printerDetails.replaceObject(at: replaceRowIndex, with: kitchenPrinter)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    ///由id取得出單機是否開啟列印
    func getKitchenPriinterSwitchStatus(id:String)->String{
        var switchStatus = false
        let kitchenPrintList = getKitchenPrintList(isIncludedTablePrinter:false)
        for kitchenPrint in kitchenPrintList{
            if id == kitchenPrint.id{
                switchStatus = kitchenPrint.switchStatus
                break
            }
        }
        return switchStatus == false ? "關閉":"開啟"
    }
    
    ///取得內場出單機清單
    func getKitchenPrintList(isIncludedTablePrinter:Bool) -> [KitchenDeviceInfo]{
        var kitchenDeviceInfos = [KitchenDeviceInfo]()
        let kitchenPrinters = loadPrinterList()
        let kitchenPrinterList = KitchenPrinterListModel.sharedInstance.reloadPrinterList()
        let printerList = kitchenPrinterList[0].cells
        for printer in printerList{
            let kitchenPrinterisExist = kitchenPrinters.first(where:{$0.id == printer.id})
            if let kitchenPrinter = kitchenPrinterisExist{
                let id = printer.id
                var kitchenPrinterInfo = kitchenPrinter.items[KitchPrintSection.infoSection.rawValue].details
                var kitchenInfo = kitchenPrinterInfo[KitchPrintSection.DeviceInfoRows.deviceNameRow.rawValue] as! UnitDetail
                let deviceName = kitchenInfo.value
                //取得出單機資訊欄位
                kitchenInfo = kitchenPrinterInfo[KitchPrintSection.DeviceInfoRows.deviceID.rawValue] as! UnitDetail
                let deviceID = kitchenInfo.value
                //取得內場開關狀態
                kitchenPrinterInfo = kitchenPrinter.items[KitchPrintSection.switchSection.rawValue].details
                kitchenInfo = kitchenPrinterInfo[KitchPrintSection.SwitchRows.switchRow.rawValue] as! UnitDetail
                let switchStatus =  kitchenInfo.value == "0" ? false:true
                //取得印單樣式等資訊
                kitchenPrinterInfo = kitchenPrinter.items[KitchPrintSection.settingSection.rawValue].details
                kitchenInfo = kitchenPrinterInfo[KitchPrintSection.SettingsRows.buzzer.rawValue] as! UnitDetail
                let buzzer = kitchenInfo.value
                
                let printerStylesTemp = kitchenPrinter.items[KitchPrintSection.settingSection.rawValue].details[KitchPrintSection.SettingsRows.orderType.rawValue] as! KitchenPrinterDetailInfos
                let printerStyles = printerStylesTemp.detialInfos
                var printerWay = "0", displayItemWay = "0", pageSize = "0", spaceHeight = "0", sheetQuantity = "0"
                for printerStyle in printerStyles{
                    let printerStyleID = PrinterStyle(rawValue: printerStyle.id)!
                    switch printerStyleID {
                    case .printerWay:
                        printerWay = printerStyle.value
                    case .displayItemWay:
                        displayItemWay = printerStyle.value
                    case .pageSize:
                        pageSize = printerStyle.value
                    case .spaceHeight:
                        spaceHeight = printerStyle.value
                    case .sheetQuantity:
                        sheetQuantity = printerStyle.value
                    default:
                        break
                    }
                }
                var devices = [KitchenPrinterDevice]()
                let deviceList = kitchenPrinter.items[KitchPrintSection.deviceSection.rawValue].details as! [KitchenPrinterDevice]
                for device in deviceList{
                    let deviceInfo = KitchenPrinterDevice(id: device.id, stationName: device.stationName, deviceID:deviceID , stationIP: device.stationIP, printerSeries: device.printerSeries, printerbrand: device.printerbrand)
                    devices.append(deviceInfo)
                }
                let kitchenDeviceInfo = KitchenDeviceInfo(id:id, deviceName:deviceName, deviceID: deviceID, switchStatus: switchStatus, printerWay: printerWay, displayItemWay: displayItemWay, buzzerVolume: buzzer, pageSize:pageSize, spaceHeight:spaceHeight, sheetQuantity:sheetQuantity, printerList: devices)
                kitchenDeviceInfos.append(kitchenDeviceInfo)
            }
        }
        
        if isIncludedTablePrinter{
            //桌邊出單機資訊
            let tablePrinterInfo = PrinterDetailModel.sharedInstance.getTablePrint()
            let kitchenPrinterDevice = KitchenPrinterDevice(id: tablePrinterUUID, stationName:tablePrinterInfo.printerName , deviceID: tablePrinterInfo.tablePrinterDeviceID, stationIP: tablePrinterInfo.tablePrinterIP, printerSeries: tablePrinterInfo.printerSeries, printerbrand: tablePrinterInfo.printerbrand)
            let kitchenDeviceInfo = KitchenDeviceInfo(id: tablePrinterUUID, deviceName: tablePrinterInfo.tablePrinterName, deviceID: tablePrinterInfo.tablePrinterDeviceID, switchStatus: true, printerWay: "0", displayItemWay: "0", buzzerVolume: "9", pageSize: "0", spaceHeight:"0",sheetQuantity:"0", printerList: [kitchenPrinterDevice])
            kitchenDeviceInfos.append(kitchenDeviceInfo)
        }
        
        return kitchenDeviceInfos
    }
    
    //MARK: 讀寫Plist資料    
    
    func clearKitchenPrinterPlist(){
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        let kitchenPrinterPList = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        guard kitchenPrinterPList.count > 0 else {
            return
        }
        kitchenPrinterPList.removeAllObjects()
        kitchenPrinterPList.write(toFile: path, atomically: true)
    }
    
    ///後台備份資料回寫桌邊出單機設定
    func updateKitchenPrinterDetial(backUpKitchenPrinterDetial: [[String:Any]]){
        guard backUpKitchenPrinterDetial.count > 0 else {
            return 
        }
        var KitchenDeviceList = [KitchenDeviceInfo]()
        for backUpKitchenPrinter in backUpKitchenPrinterDetial{
            var printerDevices = [KitchenPrinterDevice]()
            let id = backUpKitchenPrinter["id"] as? String ?? ""
            let deviceID = backUpKitchenPrinter["deviceID"] as? String ?? ""
            let deviceName = backUpKitchenPrinter["deviceName"] as? String ?? ""
            let switchStatus = backUpKitchenPrinter["switchStatus"] as? Bool ?? false
            let printerWay = backUpKitchenPrinter["printerWay"] as? String ?? ""
            let displayItemWay = backUpKitchenPrinter["displayItemWay"] as? String ?? ""
            let buzzerVolume = backUpKitchenPrinter["buzzerVolume"] as? String ?? ""
            let pageSize = backUpKitchenPrinter["pageSize"] as? String ?? ""
            let spaceHeight = backUpKitchenPrinter["spaceHeight"] as? String ?? "0"
            let sheetQuantity = backUpKitchenPrinter["sheetQuantity"] as? String ?? "1"
            let printerList = backUpKitchenPrinter["printerList"] as? [[String:Any]] ?? [[String:Any]]()
            for printer in printerList{
                let id = printer["id"] as? String ?? ""
                let stationName = printer["stationName"] as? String ?? ""
                let deviceID = printer["deviceID"] as? String ?? ""
                let stationIP = printer["stationIP"] as? String ?? ""
                let printerSeries = printer["printerSeries"] as? String ?? ""
                let printerbrand = printer["printerbrand"] as? String ?? ""
                let kpd = KitchenPrinterDevice(id: id, stationName: stationName, deviceID: deviceID, stationIP: stationIP, printerSeries: printerSeries, printerbrand: printerbrand)
                printerDevices.append(kpd)
            }
            let kdi = KitchenDeviceInfo(id: id, deviceName:deviceName, deviceID: deviceID, switchStatus: switchStatus, printerWay: printerWay, displayItemWay: displayItemWay, buzzerVolume: buzzerVolume, pageSize:pageSize, spaceHeight:spaceHeight, sheetQuantity:sheetQuantity, printerList: printerDevices)
            KitchenDeviceList.append(kdi)
        }
        
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        var kitchenPrinterPList = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        clearKitchenPrinterPlist()                
        let modifyKitchenPrinterPList:NSMutableArray = []
        for kitchenDevice in KitchenDeviceList{
            let KitchenPrinterDetail = addKitchenPrinterDetail(KitchenDevice: kitchenDevice, KitchenPrinterPList: kitchenPrinterPList)
            modifyKitchenPrinterPList.add(KitchenPrinterDetail)
        }
        kitchenPrinterPList = modifyKitchenPrinterPList
        kitchenPrinterPList.write(toFile: path, atomically: true)
    }
    
    fileprivate func updateKitchenPrinterDetail(KitchenPrinterTemp:[String:Any], KitchenDevice:KitchenDeviceInfo, KitchenPrinterPList:NSMutableArray,index:Int) -> [String:Any]{
        
        var kitchenPrinterPlistTemp = KitchenPrinterTemp
        kitchenPrinterPlistTemp["id"] = KitchenDevice.id
        kitchenPrinterPlistTemp["title"] = KitchenDevice.id
        var items = kitchenPrinterPlistTemp["items"] as! [[String:Any]]
        var printInfoItem = items[KitchPrintSection.infoSection.rawValue]
        var openPrinterItem = items[KitchPrintSection.switchSection.rawValue]
        var otherSettingItem = items[KitchPrintSection.settingSection.rawValue]
        var searchDeviceItem = items[KitchPrintSection.deviceSection.rawValue]
        
        //初始化出單機名稱
        var details = printInfoItem[detailsKey] as! [[String: Any]]
        details[KitchPrintSection.DeviceInfoRows.deviceNameRow.rawValue][valueKey] = KitchenDevice.deviceName
        details[KitchPrintSection.DeviceInfoRows.deviceID.rawValue][valueKey] = KitchenDevice.deviceID
        printInfoItem[detailsKey] = details
        items[KitchPrintSection.infoSection.rawValue] = printInfoItem
        
        //初始化開啟菜口出單
        details = openPrinterItem[detailsKey] as! [[String: Any]]
        details[KitchPrintSection.SwitchRows.switchRow.rawValue][valueKey] = KitchenDevice.switchStatus == false ? "0":"1"
        openPrinterItem[detailsKey] = details
        items[KitchPrintSection.switchSection.rawValue] = openPrinterItem
        
        //初始化其他
        details = otherSettingItem[detailsKey] as! [[String: Any]]
        var detailInfos = details[KitchPrintSection.SettingsRows.orderType.rawValue]["detailInfos"] as! [[String: Any]]
        //印單樣式
        detailInfos[PrinterType.printerWay.rawValue][valueKey] = KitchenDevice.printerWay
        detailInfos[PrinterType.displayItemWay.rawValue][valueKey] = KitchenDevice.displayItemWay
        detailInfos[PrinterType.pageSize.rawValue][valueKey] = KitchenDevice.pageSize
        detailInfos[PrinterType.spaceHeight.rawValue][valueKey] = KitchenDevice.spaceHeight
        detailInfos[PrinterType.sheetQuantity.rawValue][valueKey] = KitchenDevice.sheetQuantity
        details[KitchPrintSection.SettingsRows.orderType.rawValue]["detailInfos"] = detailInfos
        //蜂鳴器
        var buzzerDetailInfos = details[KitchPrintSection.SettingsRows.buzzer.rawValue]
        buzzerDetailInfos[valueKey] = KitchenDevice.buzzerVolume
        details[KitchPrintSection.SettingsRows.buzzer.rawValue] = buzzerDetailInfos
        otherSettingItem[detailsKey] = details
        items[KitchPrintSection.settingSection.rawValue] = otherSettingItem
        
        //初始化出單機
        var printerDeviceArray = [[String:Any]]()
        for printer in KitchenDevice.printerList{
            let id = printer.id
            let stationName = printer.stationName
            let deviceID = printer.deviceID
            let stationIP = printer.stationIP
            let printerSeries = printer.printerSeries
            let printerbrand = printer.printerbrand
            let printerDic = ["id":id, "stationName":stationName,"deviceID":deviceID,"stationIP":stationIP,"printerSeries":printerSeries,"printerbrand":printerbrand]
            printerDeviceArray.append(printerDic)
        }
        searchDeviceItem[detailsKey] = printerDeviceArray
        items[KitchPrintSection.deviceSection.rawValue] = searchDeviceItem
        kitchenPrinterPlistTemp["items"] = items
        
        return kitchenPrinterPlistTemp
    }
    
    fileprivate func addKitchenPrinterDetail(KitchenDevice:KitchenDeviceInfo, KitchenPrinterPList:NSMutableArray) -> [String:Any]{
        let kitchenPrinterDetail = KitchenPrinterPList
        var kitchenPrinterPlistTemp = kitchenPrinterDetail[0] as! [String:Any]
        kitchenPrinterPlistTemp["id"] = KitchenDevice.id
        kitchenPrinterPlistTemp["title"] = KitchenDevice.id
        var items = kitchenPrinterPlistTemp["items"] as! [[String:Any]]
        var printInfoItem = items[KitchPrintSection.infoSection.rawValue]
        var openPrinterItem = items[KitchPrintSection.switchSection.rawValue]
        var otherSettingItem = items[KitchPrintSection.settingSection.rawValue]
        var searchDeviceItem = items[KitchPrintSection.deviceSection.rawValue]
        
        //初始化出單機名稱
        var details = printInfoItem[detailsKey] as! [[String: Any]]
        details[KitchPrintSection.DeviceInfoRows.deviceNameRow.rawValue][valueKey] = KitchenDevice.deviceName
        details[KitchPrintSection.DeviceInfoRows.deviceID.rawValue][valueKey] = KitchenDevice.deviceID
        printInfoItem[detailsKey] = details
        items[KitchPrintSection.infoSection.rawValue] = printInfoItem
        
        //初始化開啟菜口出單
        details = openPrinterItem[detailsKey] as! [[String: Any]]
        details[0][valueKey] = KitchenDevice.switchStatus == false ? "0":"1"
        openPrinterItem[detailsKey] = details
        items[KitchPrintSection.switchSection.rawValue] = openPrinterItem
        
        //初始化其他
        details = otherSettingItem[detailsKey] as! [[String: Any]]
        var detailInfos = details[0]["detailInfos"] as! [[String: Any]]
        //印單樣式
        detailInfos[PrinterType.printerWay.rawValue][valueKey] = KitchenDevice.printerWay
        detailInfos[PrinterType.displayItemWay.rawValue][valueKey] = KitchenDevice.displayItemWay
        detailInfos[PrinterType.pageSize.rawValue][valueKey] = KitchenDevice.pageSize
        detailInfos[PrinterType.spaceHeight.rawValue][valueKey] = KitchenDevice.spaceHeight
        detailInfos[PrinterType.sheetQuantity.rawValue][valueKey] = KitchenDevice.sheetQuantity
        details[KitchPrintSection.SettingsRows.orderType.rawValue]["detailInfos"] = detailInfos
        //蜂鳴器
        var buzzerDetailInfos = details[KitchPrintSection.SettingsRows.buzzer.rawValue]
        buzzerDetailInfos[valueKey] = KitchenDevice.buzzerVolume
        details[KitchPrintSection.SettingsRows.buzzer.rawValue] = buzzerDetailInfos
        otherSettingItem[detailsKey] = details
        items[KitchPrintSection.settingSection.rawValue] = otherSettingItem
        
        //初始化出單機
        var printerDeviceArray = [[String:Any]]()
        for printer in KitchenDevice.printerList{
            let id = printer.id
            let stationName = printer.stationName
            let deviceID = printer.deviceID
            let stationIP = printer.stationIP
            let printerSeries = printer.printerSeries
            let printerbrand = printer.printerbrand
            let printerDic = ["id":id, "stationName":stationName,"deviceID":deviceID,"stationIP":stationIP,"printerSeries":printerSeries,"printerbrand":printerbrand]
            printerDeviceArray.append(printerDic)
        }
        searchDeviceItem[detailsKey] = printerDeviceArray
        items[KitchPrintSection.deviceSection.rawValue] = searchDeviceItem
        kitchenPrinterPlistTemp["items"] = items
        
        return kitchenPrinterPlistTemp
    }
    
    ///寫入蜂鳴器數值
    func setBuzzerVolume(volume:String, kitchenPrinterInfo:KitchenPrinterInfo, selectIndexPath:IndexPath){
        let buzzerRow = 1
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        var kitchenPrinter = [String:Any]()
        var replaceRowIndex = 0
        let printerDetails = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        for (index, items) in printerDetails.enumerated(){
            let item = items as! [String: Any]
            let id = item["id"] as! String
            if kitchenPrinterInfo.id == id{
                kitchenPrinter = item
                replaceRowIndex = index
            }
        }
        
        var items = kitchenPrinter["items"] as! [[String:Any]]
        var otherSettingItem = items[2]
        
        //初始化其他
        var details = otherSettingItem["details"] as! [[String: Any]]
        details[buzzerRow][valueKey] = volume
        otherSettingItem[detailsKey] = details
        items[KitchPrintSection.settingSection.rawValue] = otherSettingItem
        
        //寫入資料
        kitchenPrinter["items"] = items
        printerDetails.replaceObject(at: replaceRowIndex, with: kitchenPrinter)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    ///寫入樣式設定功能
    func setKitchenPrintDownMenu(detialInfos:[UnitDetail], kitchenPrinterInfo:KitchenPrinterInfo, selectlistIndexPath:IndexPath){
        let defultSetting = "0"
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        var kitchenPrinter = [String:Any]()
        var replaceRowIndex = 0
        let printerDetails = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        for (index, items) in printerDetails.enumerated(){
            let item = items as! [String: Any]
            let id = item["id"] as! String
            if kitchenPrinterInfo.id == id{
                kitchenPrinter = item
                replaceRowIndex = index
            }
        }
        
        var items = kitchenPrinter["items"] as! [[String:Any]]
        var otherSettingItem = items[KitchPrintSection.settingSection.rawValue]
        
        //初始化樣式設定功能
        var details = otherSettingItem[detailsKey] as! [[String: Any]]
        var detailInfos = details[0]["detailInfos"] as! [[String: Any]]
        detailInfos[PrinterType.printerWay.rawValue][valueKey] = detialInfos[PrinterType.printerWay.rawValue].value
        detailInfos[PrinterType.displayItemWay.rawValue][valueKey] = detialInfos[PrinterType.displayItemWay.rawValue].value
        detailInfos[PrinterType.pageSize.rawValue][valueKey] = detialInfos[PrinterType.pageSize.rawValue].value
        detailInfos[PrinterType.spaceHeight.rawValue][valueKey] = detialInfos[PrinterType.spaceHeight.rawValue].value
        detailInfos[PrinterType.sheetQuantity.rawValue][valueKey] = detialInfos[PrinterType.sheetQuantity.rawValue].value
        
        details[0]["detailInfos"] = detailInfos
        details[0][valueKey] = defultSetting
        otherSettingItem[detailsKey] = details
        items[KitchPrintSection.settingSection.rawValue] = otherSettingItem
        
        //寫入資料
        kitchenPrinter["items"] = items
        printerDetails.replaceObject(at: replaceRowIndex, with: kitchenPrinter)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    ///配對內場出單機寫入plist功能(可進行多選出單機功能)
    func setKitchenPrinterTarget(kitchenPrinterInfo:KitchenPrinterInfo, choosePrinterAddress:String, printerSeries:String, printerbrand:String, indexPath:IndexPath){
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        var kitchenPrinter = [String:Any]()
        var replaceRowIndex = 0
        let printerDetails = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        for (index, items) in printerDetails.enumerated(){
            let item = items as! [String: Any]
            let id = item["id"] as! String
            if kitchenPrinterInfo.id == id{
                kitchenPrinter = item
                replaceRowIndex = index
            }
        }
        
        var items = kitchenPrinter["items"] as! [[String:Any]]
        var searchDeviceItem = items[KitchPrintSection.deviceSection.rawValue]
        let deviceLoop = searchDeviceItem[detailsKey] as! [[String: Any]]
        var deviceList = searchDeviceItem[detailsKey] as! [[String: Any]]
        
        let checkDeviceExistArray = deviceLoop.filter{
            let stationIP = $0["stationIP"] as? String ?? ""
            return stationIP == choosePrinterAddress
        }
        if checkDeviceExistArray.count == 0{
            deviceList.append(["id":"", "stationName":printerSeries, "deviceID":kitchenPrinterInfo.deviceID, "stationIP":choosePrinterAddress, "printerSeries":printerSeries, "printerbrand":printerbrand])
        }else{
            for (index, device) in deviceLoop.enumerated(){
                let stationIP = device["stationIP"] as? String ?? ""
                if choosePrinterAddress == stationIP{
                    deviceList.remove(at: index)
                    break
                }
            }
        }
        searchDeviceItem[detailsKey] = deviceList
        items[KitchPrintSection.deviceSection.rawValue] = searchDeviceItem
        
        kitchenPrinter["items"] = items
        printerDetails.replaceObject(at: replaceRowIndex, with: kitchenPrinter)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    func fetchPrinterInfo(kitchenPrinterInfo:KitchenPrinterInfo) -> KitchenPrinter{
        var kitchenPrinter = KitchenPrinter()
        let kitchenPrinters = loadPrinterList()
        
        let kitchenPrinterisExist = kitchenPrinters.filter{$0.id == kitchenPrinterInfo.id}
        if kitchenPrinterisExist.count > 0 {
            kitchenPrinter = kitchenPrinterisExist.first!
        }else{
            addKitchenPrinterDetail(kitchenPrinter: kitchenPrinterInfo)
            let kitchenPrintersAgain = loadPrinterList()
            kitchenPrinter = kitchenPrintersAgain.filter{ $0.id == kitchenPrinterInfo.id}.first!
        }
        return kitchenPrinter
    }
    
    ///新增 出單機設定檔案
    func addKitchenPrinterDetail(kitchenPrinter:KitchenPrinterInfo){
        let defultSetting = "0"
        let defultSettingOne = "1"
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        let printerLists = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        guard printerLists.count > 0 else {
            return
        }
        var printerList = printerLists[0] as! [String:Any]
        printerList["id"] = kitchenPrinter.id
        printerList["title"] = kitchenPrinter.id
        var items = printerList["items"] as! [[String:Any]]
        var printInfoItem = items[KitchPrintSection.infoSection.rawValue]
        var openPrinterItem = items[KitchPrintSection.switchSection.rawValue]
        var otherSettingItem = items[KitchPrintSection.settingSection.rawValue]
        var searchDeviceItem = items[KitchPrintSection.deviceSection.rawValue]
        
        //初始化出單機名稱
        var details = printInfoItem[detailsKey] as! [[String: Any]]
        details[KitchPrintSection.DeviceInfoRows.deviceNameRow.rawValue][valueKey] = kitchenPrinter.stationName
        details[KitchPrintSection.DeviceInfoRows.deviceID.rawValue][valueKey] = kitchenPrinter.deviceID
        printInfoItem[detailsKey] = details
        items[KitchPrintSection.infoSection.rawValue] = printInfoItem
        
        //初始化開啟菜口出單
        details = openPrinterItem[detailsKey] as! [[String: Any]]
        details[KitchPrintSection.SwitchRows.switchRow.rawValue]["title"] = "開啟\(kitchenPrinter.stationName)"
        details[KitchPrintSection.SwitchRows.switchRow.rawValue][valueKey] = defultSetting
        openPrinterItem[detailsKey] = details
        items[KitchPrintSection.switchSection.rawValue] = openPrinterItem
        
        //初始化其他
        details = otherSettingItem[detailsKey] as! [[String: Any]]

        //印單樣式
        var detailInfos = details[0]["detailInfos"] as! [[String: Any]]
        detailInfos[PrinterType.printerWay.rawValue][valueKey] = defultSetting
        detailInfos[PrinterType.displayItemWay.rawValue][valueKey] = defultSetting
        detailInfos[PrinterType.pageSize.rawValue][valueKey] = defultSetting
        detailInfos[PrinterType.spaceHeight.rawValue][valueKey] = defultSetting
        detailInfos[PrinterType.sheetQuantity.rawValue][valueKey] = defultSettingOne
        details[0]["detailInfos"] = detailInfos
        
        details[0][valueKey] = defultSetting
        otherSettingItem[detailsKey] = details
        items[KitchPrintSection.settingSection.rawValue] = otherSettingItem

        //蜂鳴器
        var buzzerDetailInfos = details[1]
        buzzerDetailInfos["value"] = BuzzerVolume.volumeOff.rawValue
        details[1] = buzzerDetailInfos        
        otherSettingItem["details"] = details
        items[2] = otherSettingItem
        
        //初始化出單機
        searchDeviceItem[detailsKey] = [[String:Any]]()
        items[KitchPrintSection.deviceSection.rawValue] = searchDeviceItem
        
        //寫入資料
        printerList["items"] = items
        printerLists.add(printerList)
        printerLists.write(toFile: path, atomically: true)
    }
    
    func changeSwitchEnable(indexPath:IndexPath, switchEnable:Bool, kitchenPrinterInfo:KitchenPrinterInfo){
        let path = plistPath(plistString: PlistName.kitchenPrinterDetail.rawValue)
        let printerLists = getDataFromPlist(plistString: PlistName.kitchenPrinterDetail.rawValue)
        var printerListRow = 0
        var printerSettingDetails = [String: Any]()
        for (index, printer) in printerLists.enumerated(){
            let printerSetting = printer as! [String:Any]
            let id = printerSetting["id"] as? String ?? ""
            if kitchenPrinterInfo.id == id {
                printerSettingDetails = printer as! [String : Any]
                printerListRow = index
            }
        }
    
        var items = printerSettingDetails["items"] as! [[String: Any]]
        var item = items[KitchPrintSection.switchSection.rawValue]
        var details = item[detailsKey] as! [[String: Any]]
        details[0][valueKey] = switchEnable == false ? "0":"1"

        //寫入資料
        item[detailsKey] = details
        items[KitchPrintSection.switchSection.rawValue] = item
        printerSettingDetails["items"] = items
        printerLists.replaceObject(at: printerListRow, with: printerSettingDetails)
        printerLists.write(toFile: path, atomically: true)
        
        //改變出單機清單的開關狀態
        changeKitchenPrinterListEnable(indexPath: indexPath, switchEnable: switchEnable)
    }
    
    func changeKitchenPrinterListEnable(indexPath:IndexPath, switchEnable:Bool){
        let path = plistPath(plistString: PlistName.kitchenPrinterList.rawValue)
        let printerList = getDataFromPlist(plistString: PlistName.kitchenPrinterList.rawValue)
        guard printerList.count > 0 else {
            return
        }
        var items = printerList.object(at: indexPath.section) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var cellDic = cells[indexPath.row]
        cellDic["isOpen"] = switchEnable == false ? 0:1
        
        //寫入資料
        cells[indexPath.row] = cellDic
        items[cellsKey] = cells
        printerList.replaceObject(at: indexPath.section, with: items)
        printerList.write(toFile: path, atomically: true)
    }
    
    func loadPrinterList()->[KitchenPrinter]{
        let styleString = "樣式"
        let selectPrinterString = "選擇出單機器（可多台列印）"
        var kitchenPrinters = [KitchenPrinter]()        
        let kitchenPrinterDetails = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.kitchenPrinterDetail.rawValue) as! [[String: Any]]
        for kitchenPrinterDetail in kitchenPrinterDetails{
            var kitchenPrinterSections = [KitchenPrinter.KitchenPrinterSections]()
            
            let id = kitchenPrinterDetail["id"] as? String ?? ""
            let title = kitchenPrinterDetail["title"] as? String ?? ""
            let subTitle = kitchenPrinterDetail["subTitle"] as? String ?? ""
            let isIndicator = kitchenPrinterDetail["isIndicator"] as? Bool ?? false
            let displayType = kitchenPrinterDetail["displayType"] as? String ?? ""
            let value = kitchenPrinterDetail[valueKey] as? String ?? ""
            let items = kitchenPrinterDetail["items"] as! [[String:Any]]
            for item in items{
                var kitchenPrinterDetails = [Any]()
                let detailSectionName = item["detailSectionName"] as? String ?? ""
                let details = item[detailsKey] as? [[String:Any]] ?? [[String:Any]]()
                for detail in details{
                    var kpd:Any?
                    if detailSectionName == selectPrinterString{
                        let id = detail["id"] as? String ?? ""
                        let stationName = detail["stationName"] as? String ?? ""
                        let deviceID = detail["deviceID"] as? String ?? ""
                        let stationIP = detail["stationIP"] as? String ?? ""
                        let printerSeries = detail["printerSeries"] as? String ?? ""
                        let printerbrand = detail["printerbrand"] as? String ?? ""
                        kpd = KitchenPrinterDevice(id: id, stationName: stationName, deviceID: deviceID, stationIP: stationIP, printerSeries: printerSeries, printerbrand: printerbrand)
                    }else{
                        let id = detail["id"] as? String ?? ""
                        if id == styleString{
                            var kitchenPrinterDetailInfos = [UnitDetail]()
                            let title = detail["title"] as? String ?? ""
                            let subTitle = detail["subTitle"] as? String ?? ""
                            let isIndicator = detail["isIndicator"] as? Bool ?? false
                            let displayType = detail["displayType"] as? String ?? ""
                            let value = detail[valueKey] as? String ?? ""
                            let detailInfos = detail["detailInfos"] as? [[String:Any]] ?? [[String:Any]]()
                            for detailInfo in detailInfos{
                                let id = detailInfo["id"] as? String ?? ""
                                let title = detailInfo["title"] as? String ?? ""
                                let subTitle = detailInfo["subTitle"] as? String ?? ""
                                let isIndicator = detailInfo["isIndicator"] as? Bool ?? false
                                let displayType = detailInfo["displayType"] as? String ?? ""
                                let value = detailInfo[valueKey] as? String ?? ""
                                let kpdInfo = UnitDetail(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value)
                                kitchenPrinterDetailInfos.append(kpdInfo)
                            }
                            kpd = KitchenPrinterDetailInfos(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value,detialInfos:kitchenPrinterDetailInfos)
                        }else{
                            let title = detail["title"] as? String ?? ""
                            let subTitle = detail["subTitle"] as? String ?? ""
                            let isIndicator = detail["isIndicator"] as? Bool ?? false
                            let displayType = detail["displayType"] as? String ?? ""
                            let value = detail[valueKey] as? String ?? ""
                            kpd = UnitDetail(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value)
                        }
                    }
                    kitchenPrinterDetails.append(kpd)
                }
                let kps = KitchenPrinter.KitchenPrinterSections(detailSectionName: detailSectionName, details: kitchenPrinterDetails)
                kitchenPrinterSections.append(kps)
            }
            let kp = KitchenPrinter(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value, items: kitchenPrinterSections)
            kitchenPrinters.append(kp)
        }
        return kitchenPrinters
    }
    
    //MARK: 其他
    fileprivate func plistPath(plistString:String) -> String{        
        return PlistHelper.sharedInstance.getPlistPathString(plistString: plistString)
    }
    
    fileprivate func getDataFromPlist(plistString:String) -> NSMutableArray{        
        return PlistHelper.sharedInstance.getDataFromPlist(plistName:plistString)
    }
}
