//
//  ViewController.swift
//  MSHPlayer
//
//  Created by shao621 on 08/27/2020.
//  Copyright (c) 2020 shao621. All rights reserved.
//

import UIKit

import MSHPlayer


class ViewController: UIViewController {

    var player: MSHPlayer!
    var manager:MSHPlayerRotateManager!
 

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   view.backgroundColor=UIColor.white
        
        self.player = MSHPlayer.init()
        self.player.showAd=true
        self.player.delegate=self
        self.player.adImageURL="http://7xpvo0.com1.z0.glb.clouddn.com//ProjectImages/Images/2015/7/130803853775144209.jpg"
        self.manager=MSHPlayerRotateManager.init(msplayer: self.player)
        self.player.frame=CGRect.init(x: 0, y: 50, width: MSHPlayerConfig.MSSCREENW, height: MSHPlayerConfig.MSSCREENW*(9/16.0))
        self.player.videoURL="https://api-hl.huoshan.com/hotsoon/item/video/_source/?video_id=v0200c970000br9i5debn5v3g11t47lg&line=0&app_id=1112&vquality=normal&watermark=2&long_video=0&sf=1&ts=1591084964&item_id=6832843248894102796"
        view.addSubview(self.player)
        
        
        
        let btn = UIButton()
        btn.setTitle("上一个", for: .normal)
        btn.frame=CGRect.init(x: 20, y: 500, width: 60, height: 40)
        btn.backgroundColor=UIColor.orange
        btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        self.view.addSubview(btn)
        let btn1 = UIButton()
        btn1.setTitle("下一个", for: .normal)
        btn1.frame=CGRect.init(x: self.view.bounds.size.width-80, y: 500, width: 60, height: 40)
        btn1.backgroundColor=UIColor.orange
        btn1.addTarget(self, action: #selector(clickBtn1), for: .touchUpInside)
        self.view.addSubview(btn1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func enterFullScreen(type:Bool) {//true右边 false左边
            self.player.isFullScreen=true
            if type==true {
                let controller = MSHPlayerRightController()
                controller.transitioningDelegate=self.manager
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }else{
                let controller = MSHPlayerLeftController()
                controller.transitioningDelegate=self.manager
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true, completion: nil)
            }
            
            
            
        }
        func exitFullScreen()  {
            self.player.isFullScreen=false
            self.dismiss(animated: true, completion: nil)
        }
        @objc func clickBtn() {
        self.player.videoURL="https://api-hl.huoshan.com/hotsoon/item/video/_source/?video_id=v0200fc60000br767hi0ifksudmv6jp0&line=0&app_id=1112&vquality=normal&watermark=2&long_video=0&sf=1&ts=1591150662&item_id=6831507521010814220"
            self.player.play()
        }
        @objc func clickBtn1() {
//            self.rotaManager=MSHPlayerRotateManager.init()
//            let controller = MSPlayerManagerController()
//            controller.transitioningDelegate=self.rotaManager
//            controller.modalPresentationStyle = .fullScreen
//            self.present(controller, animated: true, completion: nil)
            
    //        let CC=MSDDController()
    //        self.navigationController?.pushViewController(CC, animated: true)
    //        self.player.videoURL="https://api-hl.huoshan.com/hotsoon/item/video/_source/?video_id=v0200cf20000brb5lr5p06vukut5uvsg&line=0&app_id=1112&vquality=normal&watermark=2&long_video=0&sf=1&ts=1591150662&item_id=6833893987007450372"
    //        self.player.play()
        }

        override func prefersHomeIndicatorAutoHidden() -> Bool {
            return false
        }
        override var prefersStatusBarHidden: Bool{
            
            return false
        }
        override var preferredStatusBarStyle: UIStatusBarStyle{
            return UIStatusBarStyle.lightContent
        }
        override var shouldAutorotate: Bool{
                return false
        }
        //返回支持的方向
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
            return.portrait
        }
        //有模态推出的视图控制器优先支持的屏幕方向
        override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
            return .portrait
        }
}
extension ViewController: MSPlayerDelegate,UIViewControllerTransitioningDelegate{
    func MSPlayerFullScreenFunc(play: MSHPlayer, btn: UIButton) {
        if play.isFullScreen == true {
            self.exitFullScreen()
        }else{
            self.enterFullScreen(type: true)
        }
    }
    func MSPlayerBackFunc(play: MSHPlayer) {
        if self.player.isFullScreen==true {
            self.exitFullScreen()
        }else{
            
        }
    }
    func MSPlayerPlayOrPauseFunc(play: MSHPlayer, btn: UIButton) {
        self.player.showAd=true
    }
    
    func MSPlayerPushAdFunc(play: MSHPlayer) {
//        let CC=MSTestController()
//
//        DispatchQueue.global().asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(0.01))) {
//            DispatchQueue.main.async {
//                if self.presentedViewController == nil {
//                    self.navigationController?.pushViewController(CC, animated: true)
//                }else{
//                    guard let preController = self.presentedViewController else { return  }
//                    preController.present(CC, animated: true, completion: nil)
//                }
//            }
//
//        }
        
    }
    
}

