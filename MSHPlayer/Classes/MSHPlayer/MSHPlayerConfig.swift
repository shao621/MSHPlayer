//
//  MSHPlayerConfig.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

class MSHPlayerConfig: NSObject {
    static let MSSCREENW =  UIScreen.main.bounds.size.width
    static let MSSCREENH =  UIScreen.main.bounds.size.height
    static let MSStatusH = UIApplication.shared.statusBarFrame.size.height
    static let MSNavAndTop = MSStatusH+44.0
    
    static let IS_IPHONE = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    
    static let IPHONE_X = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize.init(width: 1125.0, height: 2436.0), (UIScreen.main.currentMode?.size)!) : false
        
    static let IPHONE_XR = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize.init(width: 828.0, height: 1792.0), (UIScreen.main.currentMode?.size)! ) : false
    
    static let IPHONE_MAX = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize.init(width: 1242.0, height: 2688.0), (UIScreen.main.currentMode?.size)!) : false

    static let IPHONE_XX = (IPHONE_X||IPHONE_XR||IPHONE_MAX)
    static let MSBottomSafeH = IPHONE_XX==true ? (24.0):0.0
}
