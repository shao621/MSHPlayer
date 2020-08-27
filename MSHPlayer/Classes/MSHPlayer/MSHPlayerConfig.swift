//
//  MSHPlayerConfig.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

public class MSHPlayerConfig: NSObject {
    public static let MSSCREENW =  UIScreen.main.bounds.size.width
    public static let MSSCREENH =  UIScreen.main.bounds.size.height
    public static let MSStatusH = UIApplication.shared.statusBarFrame.size.height
    public static let MSNavAndTop = MSStatusH+44.0
    
    public static let IS_IPHONE = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone)
    
    public static let IPHONE_X = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize.init(width: 1125.0, height: 2436.0), (UIScreen.main.currentMode?.size)!) : false
        
    public static let IPHONE_XR = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize.init(width: 828.0, height: 1792.0), (UIScreen.main.currentMode?.size)! ) : false
    
    public static let IPHONE_MAX = UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize.init(width: 1242.0, height: 2688.0), (UIScreen.main.currentMode?.size)!) : false

    public static let IPHONE_XX = (IPHONE_X||IPHONE_XR||IPHONE_MAX)
    public static let MSBottomSafeH = IPHONE_XX==true ? (24.0):0.0
}
