//
//  MSHPlayerRotateManager.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit

public class MSHPlayerRotateManager: NSObject {
    var msplayer: MSHPlayer!
    var playFrame:CGRect!
    var playCenter:CGPoint=CGPoint.init(x: 0, y: 0)
    
    public convenience init(msplayer:MSHPlayer) {
        self.init()
        self.msplayer=msplayer
    }
}

extension MSHPlayerRotateManager: UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate{
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let contrainerView = transitionContext.containerView
         let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        var toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
     
        let isPresent = (fromController?.presentedViewController == toController)
        if isPresent==true {//from 导航
            self.playFrame=self.msplayer.frame
            self.playCenter=self.msplayer.center
            
            toController?.view.frame=contrainerView.bounds
            contrainerView.addSubview(toController?.view ?? UIView.init())
            toController?.view?.addSubview(self.msplayer)
            self.msplayer.snp.remakeConstraints { (make) in
                make.bottom.top.left.right.equalToSuperview()
            }
            
            
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                //--
                toController?.view.backgroundColor=UIColor.init(white: 1, alpha: 0)
                if toController?.isKind(of: MSHPlayerLeftController.self) == true {
                    toController?.view.transform=CGAffineTransform.init(rotationAngle: CGFloat(Double.pi/2.0))
                }else{
                    toController?.view.transform=CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi/2.0))
                }
                //--
                toController?.view.transform=CGAffineTransform.identity
                toController?.view.bounds=contrainerView.bounds
                toController?.view.center=contrainerView.center
            }) { (finish) in
                transitionContext.completeTransition(true)
            }
        }else{//to 是导航
            fromController?.view?.backgroundColor=UIColor.init(white: 1, alpha: 0)
            contrainerView.insertSubview(toController?.view ?? UIView(), belowSubview: fromController?.view ?? UIView())
            
            toController?.view.transform=CGAffineTransform.identity
            toController?.view.bounds=contrainerView.bounds
            toController?.view.center=contrainerView.center
            self.msplayer.snp.remakeConstraints { (make) in
                make.left.right.top.bottom.equalToSuperview().offset(0)
            }
            
            if toController?.isKind(of: UINavigationController.self) == true {
                let navController = toController as! UINavigationController
                toController=navController.topViewController
            }
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                fromController?.view.bounds.size=self.playFrame.size
                fromController?.view.transform=CGAffineTransform.identity
                fromController?.view.center=self.playCenter
            }) { (finish) in
                toController?.view.addSubview(self.msplayer)
                fromController?.view.removeFromSuperview()
                
                //原来的位置
                self.msplayer.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(self.playFrame.origin.y)
                     make.left.equalToSuperview().offset(self.playFrame.origin.x)
                    make.size.equalTo(self.playFrame.size)
                }
                 transitionContext.completeTransition(true)
            }
        }
   
    }
    
    
}
