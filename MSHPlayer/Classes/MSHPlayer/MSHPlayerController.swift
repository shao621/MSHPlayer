//
//  MSHPlayerController.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

class MSHPlayerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor=UIColor.init(red: 1, green: 1, blue: 1, alpha: 0)
    }
    //是否支持自动旋转
    override var shouldAutorotate: Bool{
        return true
    }
    
    //支持的方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.landscape
    }
    //模态推出的视图控制器，优先支持的屏幕方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UIInterfaceOrientation.portrait
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.default
    }

    override func setNeedsStatusBarAppearanceUpdate() {
        
    }
    

}
