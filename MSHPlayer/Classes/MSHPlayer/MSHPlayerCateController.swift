//
//  MSHPlayerCateController.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

class MSHPlayerCateController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension UITabBarController {
    
}

//extension UIViewController {
//
//}

extension UINavigationController {
    open override var shouldAutorotate: Bool{
        return self.topViewController?.shouldAutorotate ?? false
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return self.topViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
    }
    //默认屏幕方向（当前controller是通过模态出来的controller方式展示才会调用这个方法）
    open override var childViewControllerForStatusBarStyle: UIViewController?{
        return  self.topViewController
    }
    open override var childViewControllerForStatusBarHidden: UIViewController?{
        return self.topViewController
    }
}
extension UIAlertController {
    
}
 
