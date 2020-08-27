//
//  MSHPlayerController.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

public class MSHPlayerController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor=UIColor.init(red: 1, green: 1, blue: 1, alpha: 0)
    }
    //是否支持自动旋转
    override public var shouldAutorotate: Bool{
        return true
    }
    
    //支持的方向
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.landscape
    }
    //模态推出的视图控制器，优先支持的屏幕方向
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UIInterfaceOrientation.portrait
    }
    override public var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.default
    }

    override public func setNeedsStatusBarAppearanceUpdate() {
        
    }
    

}
