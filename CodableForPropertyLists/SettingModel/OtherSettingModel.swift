//
//  OtherSettingModel.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/19.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

struct OtherSettingSection {
    var sectionName = ""
    var cells = [UnitDetail]()
}

struct OtherSettingInfo:Codable {
    var closeOrderEnable = false
}

enum OtherSettingSections:Int {
    //關帳列印開關
    case closeOrderSection = 0
    enum CloseOrderRows:Int {
        case closeOrderRow = 0
    }
}


class OtherSettingModel: NSObject {
    static var sharedInstance = OtherSettingModel()
    fileprivate let defaultIndex = 0
    
    fileprivate let valueKey = PlistKey.valueKey.rawValue
    fileprivate let cellsKey = PlistKey.cellsKey.rawValue
    
    //MARK: 傳值給外部使用
    
    ///取得關帳列印開關設定
    func getOtherSettingInfo()->OtherSettingInfo{
        let index = 0 
        let closeOrderSection = 0
        let otherSetting = self.reloadOtherSettingInfo()
        
        let closeOrderEnable = otherSetting[closeOrderSection].cells[index].value == "0" ? false:true
        let otherSettingInfo = OtherSettingInfo(closeOrderEnable: closeOrderEnable)
        return otherSettingInfo
    }
    
    //MARK: 讀寫Plist資料
    
    ///後台備份資料回寫其他設定
    func updateOtherSetting(backUpOtherSetting: [String:Bool]){
        updateCloseOrderEnable(backUpOtherSetting: backUpOtherSetting)
    }
    
    fileprivate func updateCloseOrderEnable(backUpOtherSetting: [String:Bool]){
        let path = plistPath(plistString: PlistName.otherSetting.rawValue)
        let otherSettingDetails = getDataFromPlist(plistString: PlistName.otherSetting.rawValue)
        
        var items = otherSettingDetails.object(at: OtherSettingSections.closeOrderSection.rawValue) as! [String: Any]
        var cells = items[cellsKey] as! [[String: Any]]
        var servicFreeCell = cells[OtherSettingSections.CloseOrderRows.closeOrderRow.rawValue]
        servicFreeCell[valueKey] = backUpOtherSetting["closeOrderEnable"] == false ? "0":"1"
        cells[OtherSettingSections.CloseOrderRows.closeOrderRow.rawValue] = servicFreeCell
        
        items[cellsKey] = cells
        otherSettingDetails.replaceObject(at: OtherSettingSections.closeOrderSection.rawValue, with: items)
        otherSettingDetails.write(toFile: path, atomically: true)
    }
    
    func reloadOtherSettingInfo() -> [OtherSettingSection] {
        var printerDetailSectionArray = [OtherSettingSection]()
        let printerDetails = PlistHelper.sharedInstance.getDataFromPlist(plistName: PlistName.otherSetting.rawValue) as! [[String: Any]]
        for printerDetail in printerDetails {
            var printerDetailArray = [UnitDetail]()
            let sectionName = printerDetail["sectionName"] as! String
            let cells = printerDetail[cellsKey] as! [[String:Any]]
            for cellDic in cells {
                let pd = grenerateOtherSettingDetail(cellDic: cellDic)
                printerDetailArray.append(pd)
            }
            let pdetailSection = OtherSettingSection(sectionName: sectionName, cells: printerDetailArray)
            printerDetailSectionArray.append(pdetailSection)
        }
        return printerDetailSectionArray
    }
    
    func changeSwitchEnable(indexPath:IndexPath, switchEnable:Bool){
        let path = plistPath(plistString: PlistName.otherSetting.rawValue)
        let printerDetails = getDataFromPlist(plistString: PlistName.otherSetting.rawValue)
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
    
    fileprivate func grenerateOtherSettingDetail(cellDic:[String:Any]) -> UnitDetail{
        let id = cellDic["id"] as? String ?? ""
        let title = cellDic["title"] as? String ?? ""
        let subTitle = cellDic["subTitle"] as? String ?? ""
        let isIndicator = cellDic["isIndicator"] as? Bool ?? false
        let displayType = cellDic["displayType"] as? String ?? ""
        let value = cellDic[valueKey] as? String ?? ""
        return UnitDetail(id: id, title:title , subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value)
    }
    
    fileprivate func grenerateDetailSetting(detailDic:[String:Any])->UnitDetail{
        let id = detailDic["id"] as? String ?? ""
        let title = detailDic["title"] as? String ?? ""
        let subTitle = detailDic["subTitle"] as? String ?? ""
        let isIndicator = detailDic["isIndicator"] as? Bool ?? false
        let displayType = detailDic["displayType"] as? String ?? ""
        let value = detailDic[valueKey] as? String ?? ""
        return UnitDetail(id: id, title: title, subTitle: subTitle, isIndicator: isIndicator, displayType: displayType, value: value)
    }
    
    //MARK: 其他
    fileprivate func plistPath(plistString:String) -> String{        
        return PlistHelper.sharedInstance.getPlistPathString(plistString: plistString)
    }
    
    fileprivate func getDataFromPlist(plistString:String) -> NSMutableArray{        
        return PlistHelper.sharedInstance.getDataFromPlist(plistName:plistString)
    }

}
