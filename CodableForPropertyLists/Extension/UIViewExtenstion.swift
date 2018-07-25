//
//  UIViewExtenstion.swift
//  QLiEERPhoenix
//
//  Created by PocaChen on 2018/4/18.
//  Copyright © 2018年 QLIEER. All rights reserved.
//

import UIKit

extension UIView{

    // 左右晃動
    func shakeAnimation(duration: TimeInterval = 0.08, shakeCount: Float = 2, xValue: CGFloat = 12, yValue: CGFloat = 0){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.repeatCount = shakeCount
        animation.autoreverses = true
        //左幅度
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - xValue, y: center.y - yValue))
        //右幅度
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + xValue, y: center.y - yValue))
        layer.add(animation, forKey: "shake")
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }}
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }}
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    //漸層方法
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.1, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func removeGradientlayer(){
        self.layer.removeFromSuperlayer()
    }
}
