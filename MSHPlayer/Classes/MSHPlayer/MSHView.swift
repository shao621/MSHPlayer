//
//  MSHView.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//

import UIKit
import AVFoundation
class MSHView: UIView {
    override class var layerClass: AnyClass{
        return AVPlayerLayer.self
    }
}
extension UIView{
    var MSH_x:CGFloat{
        get{
            return self.frame.origin.x
        } set{
            self.frame.origin.x = newValue
        }
    }
    
    var MSH_y:CGFloat{
        get{
            return self.frame.origin.y
        }set{
            self.frame.origin.y = newValue
        }
    }
    
    var MSH_centerX:CGFloat{
        get{
            return self.center.x
        }
        set{
            self.center=CGPoint.init(x: newValue, y: self.center.y)
        }
    }
    
    var MSH_centerY:CGFloat{
        get{
            return self.center.y
        }
        set{
            self.center=CGPoint.init(x: self.center.x, y:newValue )
        }
    }
    
    var MSH_width:CGFloat{
        get{
            return self.frame.size.width
        }set{
            self.frame.size.width = newValue
        }
    }
    
    var MSH_height:CGFloat{
        get{
            return self.frame.size.height
        }set{
            self.frame.size.height = newValue
        }
    }
    var MSH_size:CGSize{
        get{
            return self.frame.size
        }set{
            self.frame.size = newValue
        }
    }
    
    var MSH_center:CGPoint{
        get{
            return self.center
        }set{
            self.center = newValue
        }
    }
    var MSH_origin:CGPoint{
        get{
            return self.frame.origin
        }set{
            self.frame.origin = newValue
        }
    }
}

