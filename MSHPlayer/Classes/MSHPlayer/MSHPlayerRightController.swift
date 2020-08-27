//
//  MSHPlayerRightController.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

public class MSHPlayerRightController: MSHPlayerController {

    override public func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor=UIColor.white
     }
     
    override public var shouldAutorotate: Bool{
        return true
    }
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return UIInterfaceOrientation.landscapeRight
    }
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask{
         return UIInterfaceOrientationMask.landscapeRight
     }

}
