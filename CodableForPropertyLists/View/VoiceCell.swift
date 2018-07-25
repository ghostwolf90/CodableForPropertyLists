//
//  VoiceCell.swift
//  QLiEERPhoenix
//
//  Created by Laibit on 2018/3/19.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

class VoiceCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var voicetitleLabel: UILabel!
    @IBOutlet weak var voiceSlider: UISlider!
    
    var selectIndexPath = IndexPath()
    var kitchenPrinterInfo = KitchenPrinterInfo()
    var pressSwitchHandler: ((String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUISlider()
    }
    
    func initUISlider(){
        voiceSlider.minimumTrackTintColor = UIColor.QlieerStyleGuide.qlrLightQlieer
        voiceSlider.minimumValue = 0
        voiceSlider.maximumValue = 3
        voiceSlider.value = 0
        voiceSlider.isContinuous = true
        voiceSlider.addTarget(self, action:#selector(onSliderChange), for: .valueChanged)
    }
    
    @objc func onSliderChange(sender: UISlider) {
        let voiceSliderValue = Int(sender.value)
        var responeVoice = BuzzerVolume.volumeOff.rawValue
        switch voiceSliderValue {
        case 0..<1:
            voicetitleLabel.text = "無音量"
            voiceSlider.value = 0.0
            responeVoice = BuzzerVolume.volumeOff.rawValue
        case 1..<2:
            voicetitleLabel.text = "小音量"
            voiceSlider.value = 1.0
            responeVoice = BuzzerVolume.volumeSmall.rawValue
        case 2..<3:
            voicetitleLabel.text = "中音量"
            voiceSlider.value = 2.0
            responeVoice = BuzzerVolume.volumeMedium.rawValue
        case 3:
            voicetitleLabel.text = "大音量"
            voiceSlider.value = 3.0
            responeVoice = BuzzerVolume.volumeLoud.rawValue
        default:
            break
        }
        pressSwitchHandler?(responeVoice)
    }
    
    func setCornerRadius(isFirst:Bool = false, isLast:Bool = false){
        // 設定cell圓角
        var coners = UIRectCorner()
        if isFirst{
            coners.insert(UIRectCorner.topLeft)
            coners.insert(UIRectCorner.topRight)
        }
        
        if isLast{
            coners.insert(UIRectCorner.bottomLeft)
            coners.insert(UIRectCorner.bottomRight)
        }
        
        layer.roundCorners(coners, radius: 4)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
