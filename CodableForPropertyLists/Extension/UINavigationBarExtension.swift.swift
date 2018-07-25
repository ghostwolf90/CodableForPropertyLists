//
//  UINavigationBarExtension.swift
//  QLiEERPhoenix
//
//  Created by florachen on 2018/1/3.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    func transparentNavigationBar() {
        setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        shadowImage = UIImage()
        barTintColor = UIColor.clear
        isTranslucent = true
    }
}
