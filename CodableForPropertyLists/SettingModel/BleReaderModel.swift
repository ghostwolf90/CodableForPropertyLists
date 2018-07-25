//
//  BleReaderModel.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/19.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

enum BleReaderIndex:Int {
    //是否啟用藍芽欄
    case indexDeviceEnable = 0
    enum DeviceEnableRows:Int {
        case startSwitchRow = 0
    }
    //已經連接的藍芽欄
    case indexIsExistDevice = 1
    enum IsExistDeviceRows:Int {
        case uuidRow = 0
    }
}

struct BleReaderSection {
    var sectionName = ""
    var cells = [BleReader]()
}

struct BleReader {
    var id = ""
    var title = ""
    var subTitle = ""
    var isIndicator = false
    var displayType = ""
    var value = ""
}

struct BleReaderSetting:Codable {
    var startSwitchStatus = false
    var bleUUID = ""
}

class BleReaderModel: NSObject {
    static var sharedInstance = BleReaderModel()
    
    fileprivate let valueKey = PlistKey.valueKey.rawValue
    fileprivate let cellsKey = PlistKey.cellsKey.rawValue
    //MARK: 傳值給外部使用
    
    ///取得藍牙讀卡機uuid
    func getBleSetting()->BleReaderSetting{
        let bleReaderInfos = self.reloadBleReaderInfo()
        //藍芽啟動開關狀態
        let startSwitchSection = bleReaderInfos[BleReaderIndex.indexDeviceEnable.rawValue].cells
        let startSwitchStatus = startSwitchSection[BleReaderIndex.DeviceEnableRows.startSwitchRow.rawValue].value == "0" ? false:true
        //ble uuid
        let uuidSection = bleReaderInfos[BleReaderIndex.indexIsExistDevice.rawValue].cells
        let uuidString = uuidSection[BleReaderIndex.IsExistDeviceRows.uuidRow.rawValue].value
        
        return BleReaderSetting(startSwitchStatus: startSwitchStatus, bleUUID: uuidString)
    }
    
    //MARK: 讀寫Plist資料
    
    ///後台備份資料回寫其他設定
    func updateBleReaderSetting(backUpBleReaderSetting: [String:Any]){
        updatetartSwitchStatus(backUpBleReaderSetting: backUpBleReaderSetting)
        updateIsExistDevice(backUpBleReaderSetting: backUpBleReaderSetting)
    }
    
    fileprivate func updatetartSwitchStatus(backUpBleReaderSetting: [String:Any]){
        let path = plistPath(plistString: PlistName.bLEPreference.rawValue)
        let bleReaderSetting = getDataFromPlist(plistString: PlistName.bLEPreference.rawValue)
        guard bleReaderSetting.count > 0 else {
            return
        }
        var items = bleReaderSetting.object(at: BleReaderIndex.indexDeviceEnable.rawValue) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var startSwitchCell = cells[BleReaderIndex.DeviceEnableRows.startSwitchRow.rawValue]
        let startSwitchStatus = backUpBleReaderSetting["startSwitchStatus"] as? Bool ?? false
        startSwitchCell[valueKey] = startSwitchStatus == false ? "0":"1"
        cells[BleReaderIndex.DeviceEnableRows.startSwitchRow.rawValue] = startSwitchCell
        
        items[cellsKey] = cells
        bleReaderSetting.replaceObject(at: BleReaderIndex.indexDeviceEnable.rawValue, with: items)
        bleReaderSetting.write(toFile: path, atomically: true)
    }
    
    fileprivate func updateIsExistDevice(backUpBleReaderSetting: [String:Any]){
        let path = plistPath(plistString: PlistName.bLEPreference.rawValue)
        let bleReaderSetting = getDataFromPlist(plistString: PlistName.bLEPreference.rawValue)
        guard bleReaderSetting.count > 0 else {
            return
        }
        var items = bleReaderSetting.object(at: BleReaderIndex.indexIsExistDevice.rawValue) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var isExistDeviceCell = cells[BleReaderIndex.IsExistDeviceRows.uuidRow.rawValue]
        let bleUUID = backUpBleReaderSetting["bleUUID"] as? String ?? ""
        isExistDeviceCell[valueKey] = bleUUID
        cells[BleReaderIndex.IsExistDeviceRows.uuidRow.rawValue] = isExistDeviceCell
        
        items[cellsKey] = cells
        bleReaderSetting.replaceObject(at: BleReaderIndex.indexIsExistDevice.rawValue, with: items)
        bleReaderSetting.write(toFile: path, atomically: true)
    }
    
    func reloadBleReaderInfo() -> [BleReaderSection] {
        var bleReaderSectionArray = [BleReaderSection]()        
        let printerDetails = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.bLEPreference.rawValue) as! [[String: Any]]
        for printerDetail in printerDetails {
            var bleReaderArray = [BleReader]()
            let sectionName = printerDetail["sectionName"] as! String
            let cells = printerDetail[cellsKey] as! [[String:Any]]
            for cellDic in cells {
                let id = cellDic["id"] as? String ?? ""
                let title = cellDic["title"] as? String ?? ""
                let subTitle = cellDic["subTitle"] as? String ?? ""
                let isIndicator = cellDic["isIndicator"] as? Bool ?? false
                let displayType = cellDic["displayType"] as? String ?? ""
                let value = cellDic[valueKey] as? String ?? ""
                let br = BleReader(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value)
                bleReaderArray.append(br)
            }
            let pdetailSection = BleReaderSection(sectionName: sectionName, cells: bleReaderArray)
            bleReaderSectionArray.append(pdetailSection)
        }
        return bleReaderSectionArray
    }
    
    ///選擇藍牙讀卡機
    func setBLEDevice(indexPath:IndexPath, deviceUUID:String?){
        let path = plistPath(plistString: PlistName.bLEPreference.rawValue)
        let printerDetails = getDataFromPlist(plistString: PlistName.bLEPreference.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var items = printerDetails.object(at: BleReaderIndex.indexIsExistDevice.rawValue) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var cellDic = cells[indexPath.row]
        cellDic[valueKey] = deviceUUID
        
        //寫入資料
        cells[indexPath.row] = cellDic
        items[cellsKey] = cells
        printerDetails.replaceObject(at: BleReaderIndex.indexIsExistDevice.rawValue, with: items)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    ///取得已儲存藍牙讀卡機uuid
    func loadBLEDevice() -> String{
        let printerDetails = getDataFromPlist(plistString: PlistName.bLEPreference.rawValue)
        guard printerDetails.count > 0 else {
            return ""
        }
        var items = printerDetails.object(at: BleReaderIndex.indexIsExistDevice.rawValue) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var cellDic = cells[0]
        let deviceUUID = cellDic[valueKey] as? String ?? ""
        return deviceUUID
    }
        
    ///刪除藍牙讀卡機
    func removeBLEDevice(){
        let path = plistPath(plistString: PlistName.bLEPreference.rawValue)
        
        let printerDetails = getDataFromPlist(plistString: PlistName.bLEPreference.rawValue)
        guard printerDetails.count > 0 else {
            return
        }
        var items = printerDetails.object(at: BleReaderIndex.indexIsExistDevice.rawValue) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var cellDic = cells[0]
        cellDic[valueKey] = ""
        
        //寫入資料
        cells[0] = cellDic
        items[cellsKey] = cells
        printerDetails.replaceObject(at: BleReaderIndex.indexIsExistDevice.rawValue, with: items)
        printerDetails.write(toFile: path, atomically: true)
    }
    
    func changeSwitchEnable(indexPath:IndexPath, switchEnable:Bool){
        let path = plistPath(plistString: PlistName.bLEPreference.rawValue)
        
        let printerDetails = getDataFromPlist(plistString: PlistName.bLEPreference.rawValue)
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
    
    //MARK: 其他
    fileprivate func plistPath(plistString:String) -> String{        
        return PlistHelper.sharedInstance.getPlistPathString(plistString: plistString)
    }
    
    fileprivate func getDataFromPlist(plistString:String) -> NSMutableArray{                
        return PlistHelper.sharedInstance.getDataFromPlist(plistName:plistString)
    }

}
