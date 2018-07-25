//
//  PrinterDetailModel.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/15.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

enum BuzzerVolume:String {
    case volumeOff = "9"
    case volumeSmall = "0"
    case volumeMedium = "2"
    case volumeLoud = "4"
}

enum Printerbrand:String{
    case none = "none"
    case epson = "EPSON"
    case star = "STAR"
}

enum TablePrinterSections:Int {
    ///桌邊出單機資訊欄
    case printerInfoSection = 0
    enum PrinterInfoRows:Int {
        case tablePrinterName = 0
        case tablePrinterDeviceID = 1
    }
    ///開啟桌邊出單機欄
    case cashBoxSection = 1
    enum CashBoxRows:Int {
        case cashBoxRow = 0
    }
    ///列印設定欄
    case printerSettingSection = 2
    enum PrinterSettingRows:Int {
        case menuSheetRow = 0
        enum menuSheetDatailRows:Int {
            case menuSheetSwitchRow = 0
            case menuSheetQuantityRow = 1
        }
        case saleSheetRow = 1
        enum SaleSheetDatailRows:Int {
            case saleSheetSwitchRow = 0
        }
    }
    
    ///連線出單機欄
    case printerDeviceSection = 3
    enum PrinterDeviceRows:Int {
        case deviceRow = 0
    }
}

enum SaleSheetQuantitySection:Int {
    case saleSheetQuantity = 1
}

enum SaleSheetQuantityRows:Int {
    case saleSheetQuantityRow = 0
}

struct MenuOrderInfo{
    var menuOrderSwitchStatus = false
    var quantity = 0
}

struct SaleOrderInfo{
    var saleOrderSwitchStatus = false
    var caseBoxSwitchStatus = false
    var quantity = 0
}

enum ChangeQuantity {
    case minus
    case plus
}



//出單機結構
struct PrinterDetailSection{
    var sectionName = ""
    var cells = [Any]()
}

struct PrinterDetail {
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
    var detailSettings = [DetailSection]()
}

struct DetailSection {
    var detailSectionName = ""
    var details = [DetailSetting]()
}

struct DetailSetting {
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
}

struct TablePrinterInfo{
    var id = ""
    var stationName = ""
    var deviceID = ""
    var stationIP = ""
    var printerSeries = ""
    var printerbrand = ""
}

//用來備份用途
struct TablePrinterSetting:Codable{
    var tablePrinterName = ""
    var tablePrinterDeviceID = ""
    var cashBoxEnable = false
    
    var menuSheetSwitchStatus = false
    var menuSheetQuantity = 0
    var saleSheetSwitchStatus = false
    var saleSheetQuantity = 0

    var printerID = ""
    var printerName = ""
    var tablePrinterIP = ""
    var printerSeries = ""
    var printerbrand = ""
}

class PrinterDetailModel: NSObject {
    static var sharedInstance = PrinterDetailModel()
    
    fileprivate let cellsKey = PlistKey.cellsKey.rawValue
    fileprivate let detailsKey = PlistKey.detailsKey.rawValue
    fileprivate let detailSettingsKey = PlistKey.detailSettingsKey.rawValue
    fileprivate let valueKey = PlistKey.valueKey.rawValue
    
    let openOrderStatusIndex = 0
    let quantityIndex = 1
    
    //MARK: 傳值給外部使用
    
    ///取得桌邊出單機所有資訊
    func getTablePrint() -> TablePrinterSetting{
        let menuSheetSection = 0 //訂單明細位址
        let menuOrderOpenRow = 0
        let menuOrderQuantityRow = 1
        let saleSheetSection = 1 //交易明細index
        let saleSheetSwitchRow = 0
        let saleSheetCashBoxRow = 1
        let saleSheetQuantityRow = 0
        let saleSheetDetialSwitchSection = 0
        let saleSheetDetialQuantitySection = 1
        
        let tablePrinterInfos = self.reloadPrinterDetail()
        //出單機基本資訊
        let info = tablePrinterInfos[TablePrinterSections.printerInfoSection.rawValue].cells as! [UnitDetail]
        let tablePrinterName = info[TablePrinterSections.PrinterInfoRows.tablePrinterName.rawValue].value
        let tablePrinterDeviceID = info[TablePrinterSections.PrinterInfoRows.tablePrinterDeviceID.rawValue].value
        //錢箱啟動開關
        let cashBoxSwitch = tablePrinterInfos[TablePrinterSections.cashBoxSection.rawValue].cells as! [UnitDetail]
        let cashBoxEnable = cashBoxSwitch[TablePrinterSections.CashBoxRows.cashBoxRow.rawValue].value == "0" ? false:true
        //出單機列印規則
        let menuSheetSetting = tablePrinterInfos[TablePrinterSections.printerSettingSection.rawValue].cells[menuSheetSection] as! PrinterDetail
        let menuSheetswitchStatus = menuSheetSetting.detailSettings[menuOrderOpenRow].details[menuSheetSection].value == "0" ? false:true
        let menuSheetQuantity = Int(menuSheetSetting.detailSettings[menuOrderQuantityRow].details[menuSheetSection].value)!
        
        let saleSheetSetting = tablePrinterInfos[TablePrinterSections.printerSettingSection.rawValue].cells[saleSheetSection] as! PrinterDetail
        let saleSheetSwitchStatus = saleSheetSetting.detailSettings[saleSheetDetialSwitchSection].details[saleSheetSwitchRow].value == "0" ? false:true
        let saleSheetQuantity = Int(saleSheetSetting.detailSettings[saleSheetDetialQuantitySection].details[saleSheetQuantityRow].value)!
        //連線出單機訊息
        let printerDevice = tablePrinterInfos[TablePrinterSections.printerDeviceSection.rawValue].cells[TablePrinterSections.PrinterDeviceRows.deviceRow.rawValue] as! TablePrinterInfo
        let printerID = printerDevice.id
        let printerName = printerDevice.stationName
        let tablePrinterIP = printerDevice.stationIP
        let printerSeries = printerDevice.printerSeries
        let printerbrand = printerDevice.printerbrand
        
        return TablePrinterSetting(tablePrinterName: tablePrinterName, tablePrinterDeviceID: tablePrinterDeviceID, cashBoxEnable: cashBoxEnable, menuSheetSwitchStatus: menuSheetswitchStatus, menuSheetQuantity: menuSheetQuantity, saleSheetSwitchStatus: saleSheetSwitchStatus, saleSheetQuantity: saleSheetQuantity, printerID: printerID, printerName: printerName, tablePrinterIP: tablePrinterIP, printerSeries: printerSeries, printerbrand: printerbrand)
    }
    
    ///取得錢箱
    func getCashBoxStatus() -> Bool{
        let printerInfo = self.reloadPrinterDetail()
        let printerSwitchSection = printerInfo[TablePrinterSections.cashBoxSection.rawValue].cells[0] as! UnitDetail
        return printerSwitchSection.value == "0" ? false : true
    }
    
    ///取得桌邊出單機資訊
    func getTablePrinterInfo() -> TablePrinterInfo{
        let printerInfo = self.reloadPrinterDetail()
        let tablePrinterInfo = printerInfo[TablePrinterSections.printerDeviceSection.rawValue].cells[TablePrinterSections.PrinterDeviceRows.deviceRow.rawValue] as! TablePrinterInfo
        return tablePrinterInfo
    }
    
    ///訂單明細設定(開關 數量)
    func getMenuOrderInfo()->MenuOrderInfo{
        let menuSheetSection = 0 //訂單明細位址
        let menuOrderOpenRow = 0
        let menuOrderQuantityRow = 1
        let printerInfo = self.reloadPrinterDetail()
        let printerSettingInfo = printerInfo[TablePrinterSections.printerSettingSection.rawValue].cells[menuSheetSection] as! PrinterDetail
        let switchStatus = printerSettingInfo.detailSettings[menuOrderOpenRow].details[menuSheetSection].value == "0" ? false:true
        let quantity = Int(printerSettingInfo.detailSettings[menuOrderQuantityRow].details[menuSheetSection].value)!
        let menuOrderInfo = MenuOrderInfo(menuOrderSwitchStatus: switchStatus, quantity: quantity)
        return menuOrderInfo
    }
    
    ///交易明細設定(開關 數量 結帳後開啟錢箱)
    func getSaleOrderInfo() -> SaleOrderInfo{
        let saleSheetSection = 1 //交易明細index
        let saleSheetSwitchRow = 0, saleSheetCashBoxRow = 0
        let saleSheetQuantityRow = 0
        let saleSheetDetialSwitchSection = 0
        let saleSheetDetialQuantitySection = 1
        let printerInfo = self.reloadPrinterDetail()
        
        let printerSettingInfo = printerInfo[TablePrinterSections.printerSettingSection.rawValue].cells[saleSheetSection] as! PrinterDetail
        let switchStatus = printerSettingInfo.detailSettings[saleSheetDetialSwitchSection].details[saleSheetSwitchRow].value == "0" ? false:true
        let quantity = Int(printerSettingInfo.detailSettings[saleSheetDetialQuantitySection].details[saleSheetQuantityRow].value)!
        
        let cashBoxStatus = getCashBoxStatus()
        
        let saleOrderInfo = SaleOrderInfo(saleOrderSwitchStatus: switchStatus, caseBoxSwitchStatus: cashBoxStatus, quantity: quantity)
        return saleOrderInfo
    }
    
    //MARK: 讀寫Plist資料
    
    ///後台備份資料回寫桌邊出單機設定
    func updateTablePrinter(backUpTablePrinter: [String:Any]){
        let tablePrinterBackUpObject = generateTablePrinterObject(backUpTablePrinter: backUpTablePrinter)
        
        let path = plistPath(plistString: PlistName.printerDetail.rawValue)
        var printerDetails = getDataFromPlist(plistString: PlistName.printerDetail.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var printerInfo = printerDetails[TablePrinterSections.printerInfoSection.rawValue] as! [String: Any]
        var cashBoxSettingInfo = printerDetails[TablePrinterSections.cashBoxSection.rawValue] as! [String: Any]
        var printerSettingInfo = printerDetails[TablePrinterSections.printerSettingSection.rawValue] as! [String: Any]
        var connectPrinterInfo = printerDetails[TablePrinterSections.printerDeviceSection.rawValue] as! [String: Any]
        
        //開啟錢箱
        var cashBoxSwitch = cashBoxSettingInfo[cellsKey] as! [[String: Any]]
        cashBoxSwitch[TablePrinterSections.CashBoxRows.cashBoxRow.rawValue][valueKey] = tablePrinterBackUpObject.cashBoxEnable == false ? "0":"1"
        cashBoxSettingInfo[cellsKey] = cashBoxSwitch
        printerDetails[TablePrinterSections.cashBoxSection.rawValue] = cashBoxSettingInfo
        
        ///列印設定欄
        //訂單明細設定
        var printerSettings = printerSettingInfo[cellsKey] as! [[String: Any]]
        var menuSheetSettings = printerSettings[TablePrinterSections.PrinterSettingRows.menuSheetRow.rawValue][detailSettingsKey] as! [[String: Any]]
        
        var menuSheetSwitc = menuSheetSettings[TablePrinterSections.PrinterSettingRows.menuSheetDatailRows.menuSheetSwitchRow.rawValue]
        var menuSheetSwitcDetails = menuSheetSwitc[detailsKey] as! [[String: Any]]
        menuSheetSwitcDetails[TablePrinterSections.PrinterSettingRows.menuSheetDatailRows.menuSheetSwitchRow.rawValue][valueKey] = tablePrinterBackUpObject.menuSheetSwitchStatus == false ? "0":"1"
        menuSheetSwitc[detailsKey] = menuSheetSwitcDetails
        menuSheetSettings[TablePrinterSections.PrinterSettingRows.menuSheetDatailRows.menuSheetSwitchRow.rawValue] = menuSheetSwitc
        
        var menuSheetQuantity = menuSheetSettings[TablePrinterSections.PrinterSettingRows.menuSheetDatailRows.menuSheetQuantityRow.rawValue]
        var menuSheetQuantityDetails = menuSheetQuantity[detailsKey] as! [[String: Any]]
        menuSheetQuantityDetails[TablePrinterSections.PrinterSettingRows.menuSheetDatailRows.menuSheetSwitchRow.rawValue][valueKey] = "\(tablePrinterBackUpObject.menuSheetQuantity)"
        menuSheetQuantity[detailsKey] = menuSheetQuantityDetails
        menuSheetSettings[TablePrinterSections.PrinterSettingRows.menuSheetDatailRows.menuSheetQuantityRow.rawValue] = menuSheetQuantity
        printerSettings[TablePrinterSections.PrinterSettingRows.menuSheetRow.rawValue][detailSettingsKey] = menuSheetSettings
        
        //交易明細設定
        var saleSheetSettings = printerSettings[TablePrinterSections.PrinterSettingRows.saleSheetRow.rawValue][detailSettingsKey] as! [[String: Any]]
        
        var saleSheetSwitc = saleSheetSettings[TablePrinterSections.PrinterSettingRows.SaleSheetDatailRows.saleSheetSwitchRow.rawValue]
        var saleSheetSwitcDetails = saleSheetSwitc[detailsKey] as! [[String: Any]]
        saleSheetSwitcDetails[TablePrinterSections.PrinterSettingRows.SaleSheetDatailRows.saleSheetSwitchRow.rawValue][valueKey] = tablePrinterBackUpObject.saleSheetSwitchStatus == false ? "0":"1"
        saleSheetSwitc[detailsKey] = saleSheetSwitcDetails
        saleSheetSettings[TablePrinterSections.PrinterSettingRows.SaleSheetDatailRows.saleSheetSwitchRow.rawValue] = saleSheetSwitc
        
        var saleSheetQuantity = saleSheetSettings[SaleSheetQuantitySection.saleSheetQuantity.rawValue]
        var saleSheetQuantityDetails = saleSheetQuantity[detailsKey] as! [[String: Any]]
        saleSheetQuantityDetails[SaleSheetQuantityRows.saleSheetQuantityRow.rawValue][valueKey] = "\(tablePrinterBackUpObject.saleSheetQuantity)"
        saleSheetQuantity[detailsKey] = saleSheetQuantityDetails
        saleSheetSettings[SaleSheetQuantitySection.saleSheetQuantity.rawValue] = saleSheetQuantity
        printerSettings[TablePrinterSections.PrinterSettingRows.saleSheetRow.rawValue][detailSettingsKey] = saleSheetSettings
        
        printerSettingInfo[cellsKey] = printerSettings
        printerDetails[TablePrinterSections.printerSettingSection.rawValue] = printerSettingInfo
        
        ///連線出單機欄
        let onlyOnePrinterIndex = 0
        var connectPrinter = connectPrinterInfo[cellsKey] as! [[String:Any]]
        connectPrinter[onlyOnePrinterIndex]["printerbrand"] = tablePrinterBackUpObject.printerbrand
        connectPrinter[onlyOnePrinterIndex]["printerSeries"] = tablePrinterBackUpObject.tablePrinterDeviceID
        connectPrinter[onlyOnePrinterIndex]["deviceID"] = tablePrinterBackUpObject.tablePrinterDeviceID
        connectPrinter[onlyOnePrinterIndex]["stationName"] = tablePrinterBackUpObject.printerName
        connectPrinter[onlyOnePrinterIndex]["id"] = tablePrinterBackUpObject.tablePrinterDeviceID
        connectPrinter[onlyOnePrinterIndex]["stationIP"] = tablePrinterBackUpObject.tablePrinterIP
        connectPrinterInfo[cellsKey] = connectPrinter
        printerDetails[TablePrinterSections.printerDeviceSection.rawValue] = connectPrinterInfo
        
        printerDetails.write(toFile: path, atomically: true)
    }
    
    fileprivate func generateTablePrinterObject(backUpTablePrinter: [String:Any])->TablePrinterSetting{
        let tablePrinterName = backUpTablePrinter["tablePrinterName"] as? String ?? ""
        let tablePrinterDeviceID = backUpTablePrinter["tablePrinterDeviceID"] as? String ?? ""
        let cashBoxEnable = backUpTablePrinter["cashBoxEnable"] as? Bool ?? false
        let menuSheetSwitchStatus = backUpTablePrinter["menuSheetSwitchStatus"] as? Bool ?? false
        let menuSheetQuantity = backUpTablePrinter["menuSheetQuantity"] as? Int ?? 0
        let saleSheetSwitchStatus = backUpTablePrinter["saleSheetSwitchStatus"] as? Bool ?? false
        let saleSheetQuantity = backUpTablePrinter["saleSheetQuantity"] as? Int ?? 0        
        let tablePrinterIP = backUpTablePrinter["tablePrinterIP"] as? String ?? ""
        
        let printerID = backUpTablePrinter["printerID"] as? String ?? ""
        let printerName = backUpTablePrinter["printerName"] as? String ?? ""
        let printerSeries = backUpTablePrinter["printerSeries"] as? String ?? ""
        let printerbrand = backUpTablePrinter["printerbrand"] as? String ?? ""
        
        return TablePrinterSetting(tablePrinterName: tablePrinterName, tablePrinterDeviceID: tablePrinterDeviceID, cashBoxEnable: cashBoxEnable, menuSheetSwitchStatus: menuSheetSwitchStatus, menuSheetQuantity: menuSheetQuantity, saleSheetSwitchStatus: saleSheetSwitchStatus, saleSheetQuantity: saleSheetQuantity, printerID: printerID, printerName: printerName, tablePrinterIP: tablePrinterIP, printerSeries: printerSeries, printerbrand: printerbrand)
    }
    
    ///取出桌邊出單設定資料
    func reloadPrinterDetail() -> [PrinterDetailSection] {
        var printerDetailSectionArray = [PrinterDetailSection]()
        let printerDetails = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.printerDetail.rawValue) as! [[String: Any]]
        for printerDetail in printerDetails {
            var printerDetailArray = [Any]()
            let cells = printerDetail[cellsKey] as! [[String:Any]]
            let sectionName = printerDetail["sectionName"] as! String
            if sectionName == "選擇作為桌邊的印單機（唯一）"{
                for cellDic in cells {
                    let pd = greneratePrinterInfo(cellDic: cellDic)
                    printerDetailArray.append(pd)
                }
            }else{
                
            }
            let pdetailSection = PrinterDetailSection(sectionName: sectionName, cells: printerDetailArray)
            printerDetailSectionArray.append(pdetailSection)
        }
        return printerDetailSectionArray
    }
    
    ///配對桌邊出單機
    func setTablePrinterTarget(printerAddress:String, printerSeries:String, printerbrand:String, indexPath:IndexPath){
        let path = plistPath(plistString: PlistName.printerDetail.rawValue)
        let printerDetails = getDataFromPlist(plistString: PlistName.printerDetail.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var items = printerDetails.object(at: indexPath.section) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var cellDic = cells[0]
        cellDic["id"] = ""
        cellDic["stationName"] = printerSeries
        cellDic["deviceID"] = ""
        cellDic["stationIP"] = printerAddress
        cellDic["printerSeries"] = printerSeries
        cellDic["printerbrand"] = printerbrand
        
        //寫入資料
        cells[0] = cellDic
        items[cellsKey] = cells
        printerDetails.replaceObject(at: indexPath.section, with: items)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    ///改變桌邊出單Switch狀態
    func changeSwitchEnable(indexPath:IndexPath, switchEnable:Bool){
        let path = plistPath(plistString: PlistName.printerDetail.rawValue)
        let printerDetails = getDataFromPlist(plistString: PlistName.printerDetail.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var items = printerDetails.object(at: indexPath.section) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var cellDic = cells[indexPath.row]
        cellDic[valueKey] = switchEnable == false ? "0":"1"
        
        //寫入資料
        cells[indexPath.row] = cellDic
        items[cellsKey] = cells
        printerDetails.replaceObject(at: indexPath.section, with: items)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    ///改變桌邊列印設定裡各種明細的設定
    func changeOrderSettingSwitchEnable(indexPath:IndexPath, selectIndexPath:IndexPath, switchEnable:Bool){
        let path = plistPath(plistString: PlistName.printerDetail.rawValue)
        let printerDetails = getDataFromPlist(plistString: PlistName.printerDetail.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var items = printerDetails.object(at: indexPath.section) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var orderSettings = cells[indexPath.row]
        var detailSettings = orderSettings[detailSettingsKey] as! [[String: Any]]
        var detailSetting = detailSettings[openOrderStatusIndex]
        var detailSettingDetails = detailSetting[detailsKey] as! [[String: Any]]
        var cellDic = detailSettingDetails[selectIndexPath.row]
        cellDic[valueKey] = switchEnable == false ? "0":"1"
        
        //寫入資料
        detailSettingDetails[selectIndexPath.row] = cellDic
        detailSetting[detailsKey] = detailSettingDetails
        detailSettings[openOrderStatusIndex] = detailSetting
        orderSettings[detailSettingsKey] = detailSettings
        cells[indexPath.row] = orderSettings
        items[cellsKey] = cells
        printerDetails.replaceObject(at: indexPath.section, with: items)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    func changeOrderSettingQuantity(indexPath:IndexPath, selectIndex: IndexPath, detailSection:[DetailSection], changeType:ChangeQuantity) -> String{
        var quantity = Int(detailSection[indexPath.section].details[indexPath.row].value)!
        switch changeType {
        case .minus:
            if quantity > 1{
                quantity = quantity - 1
                setOrderSettingQuantity(indexPath: selectIndex, quantity: quantity)
            }
            break
        case .plus:
            quantity = quantity + 1
            setOrderSettingQuantity(indexPath: selectIndex, quantity: quantity)
            break
        }
        return "\(quantity)"
    }
    
    func setOrderSettingQuantity(indexPath:IndexPath, quantity:Int){
        
        let path = plistPath(plistString: PlistName.printerDetail.rawValue)
        let printerDetails = getDataFromPlist(plistString: PlistName.printerDetail.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var items = printerDetails.object(at: indexPath.section) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var orderSettings = cells[indexPath.row]
        var detailSettings = orderSettings[detailSettingsKey] as! [[String: Any]]
        var detailSetting = detailSettings[quantityIndex]
        var detailSettingDetails = detailSetting[detailsKey] as! [[String: Any]]
        var cellDic = detailSettingDetails[0]
        cellDic[valueKey] = "\(quantity)"
        
        //寫入資料
        detailSettingDetails[0] = cellDic
        detailSetting[detailsKey] = detailSettingDetails
        detailSettings[quantityIndex] = detailSetting
        orderSettings[detailSettingsKey] = detailSettings
        cells[indexPath.row] = orderSettings
        items[cellsKey] = cells
        printerDetails.replaceObject(at: indexPath.section, with: items)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    fileprivate func greneratePrinterInfo(cellDic:[String:Any]) -> Any{
        var pd:Any?
        let id = cellDic["id"] as? String ?? ""
        let stationName = cellDic["stationName"] as? String ?? ""
        let deviceID = cellDic["deviceID"] as? String ?? ""
        let stationIP = cellDic["stationIP"] as? String ?? ""
        let printerSeries = cellDic["printerSeries"] as? String ?? ""
        let printerbrand = cellDic["printerbrand"] as? String ?? ""
        
        pd = TablePrinterInfo(id: id, stationName: stationName, deviceID: deviceID, stationIP: stationIP, printerSeries: printerSeries, printerbrand: printerbrand)
        return pd
    }
    
    

    
    //MARK: 其他
    fileprivate func plistPath(plistString:String) -> String{
        return PlistHelper.sharedInstance.getPlistPathString(plistString: plistString)
    }
    
    func getDataFromPlist(plistString:String) -> NSMutableArray{
        return PlistHelper.sharedInstance.getDataFromPlist(plistName:plistString)
    }

}
