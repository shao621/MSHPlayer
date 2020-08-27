//
//  MSHPlayerRightController.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

class MSHPlayerRightController: MSHPlayerController {

    override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor=UIColor.white
     }
     
    override var shouldAutorotate: Bool{
        return true
    }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UIInterfaceOrientation.landscapeRight
    }
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
         return UIInterfaceOrientationMask.landscapeRight
     }

}
