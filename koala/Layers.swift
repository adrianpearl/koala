//
//  colors.swift
//  Happiness
//
//  Created by Adrian Pearl on 12/3/15.
//  Copyright © 2015 Adrian Pearl. All rights reserved.
//

import Foundation
import UIKit

public let workoutGreen = UIColor(red: 66 / 255.0, green: 206 / 255.0, blue: 84 / 255.0, alpha: 1.0)
public let koalaMainNavColor = UIColor(red: 65 / 255, green: 131 / 255, blue: 215 / 255, alpha: 1.0)

class Layers {
    
    var glView: UIView
    var rlView: UIView
    
    var colorTop = UIColor(red: 69/255.0, green: 191/255.0, blue: 217/255.0, alpha: 1.0).CGColor
    var colorBottom = UIColor(red: 45/255.0, green: 100/255.0, blue: 170/255.0, alpha: 1.0).CGColor
    
    let gl: CAGradientLayer
    let rl: CAReplicatorLayer
    
    let instanceLayer: CALayer
    let fadeAnimation: CABasicAnimation
    
    init(viewForGradient: UIView?, viewForReplicator: UIView?) {
        glView = viewForGradient ?? UIView()
        rlView = viewForReplicator ?? UIView()
        
        gl = CAGradientLayer()
        gl.frame = glView.frame
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [0.0, 1.0]
        gl.contentsGravity = kCAGravityCenter
        
        rl = CAReplicatorLayer()
        rl.frame = rlView.frame
        rl.backgroundColor = UIColor.clearColor().CGColor
        
        // 2
        rl.instanceCount = 50
        rl.instanceDelay = CFTimeInterval(1 / Float(rl.instanceCount))
        rl.preservesDepth = true
        // rl.instanceColor = UIColor(red: 66 / 255.0, green: 206 / 255.0, blue: 84 / 255.0, alpha: 1.0).CGColor
        
        let angle = Float(M_PI * 2.0) / Float(rl.instanceCount)
        rl.instanceTransform = CATransform3DMakeRotation(CGFloat(angle), 0.0, 0.0, 1.0)
        
        // 5
        instanceLayer = CALayer()
        let layerWidth: CGFloat = 6.0
        let midX = CGRectGetMidX(rlView.bounds) - layerWidth / 1.5
        instanceLayer.frame = CGRect(x: midX, y: 0.0, width: layerWidth, height: layerWidth * 2.0)
        instanceLayer.backgroundColor = UIColor.whiteColor().CGColor
        rl.addSublayer(instanceLayer)
        
        let toColor = UIColor.whiteColor().CGColor
        let fromColor = workoutGreen.CGColor
        
        // 6
        fadeAnimation = CABasicAnimation(keyPath: "backgroundColor")
        fadeAnimation.fromValue = fromColor
        fadeAnimation.toValue = toColor
        fadeAnimation.duration = 1.0
        fadeAnimation.repeatCount = Float(Int.max)
        
        
        // 7
        // instanceLayer.opacity = 0.5
        instanceLayer.allowsEdgeAntialiasing = true
    }
    
    func animateRotation() {
        instanceLayer.addAnimation(fadeAnimation, forKey: "FadeAnimation")
    }
    
    func deAnimateRotation() {
        instanceLayer.removeAnimationForKey("FadeAnimation")
    }
    
    func animateGradient(){
        
        let fromColors = gl.colors
        // let toColors: [AnyObject] = [ colorBottom, colorTop]
        let toColors: [AnyObject] = [ UIColor.redColor().CGColor, UIColor.redColor().CGColor]
        
        gl.colors = toColors // You missed this line
        
        let animation : CABasicAnimation = CABasicAnimation(keyPath: "colors")
        
        animation.fromValue = fromColors
        animation.toValue = toColors
        animation.duration = 3.00
        animation.removedOnCompletion = true
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.delegate = self
        
        gl.addAnimation(animation, forKey:"animateGradient")
    }
}

class StatusView: UIView {
    
    var textView = StatusLabel()
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        textView = StatusLabel(frame: CGRect(center: CGPointZero, size: CGSizeZero))
        // textView.frame = CGRect(center: CGPointMake(self.frame.size.width  / 2, self.frame.size.height / 2), size: CGSize(width: self.bounds.width * 0.75, height: self.bounds.height * 0.75))
        //textView.center = CGPointMake(self.frame.size.width  / 2, self.frame.size.height / 2);
        // self.addSubview(textView)
    }
    
    override func drawRect(rect: CGRect) {
        textView.frame = CGRect(center: CGPointMake(self.frame.size.width  / 2, self.frame.size.height / 2), size: CGSize(width: self.bounds.width * 0.75, height: self.bounds.height * 0.75))
        self.addSubview(textView)
    }
    
}


class StatusLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textAlignment = .Center
        self.font = UIFont(name: "Lato-Light", size: 38)
        self.lineBreakMode = .ByWordWrapping
        self.numberOfLines = 0
        self.textColor = UIColor.whiteColor()
        // self.backgroundColor = UIColor.redColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class KoalaButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.titleLabel?.font = UIFont(name: "CenturyGothic", size: 24)
        self.layer.borderWidth = 2
    }
    
    func configure(cornerRadius: CGFloat?, textColor: UIColor?, borderColor: UIColor?) {
        self.layer.cornerRadius = cornerRadius ?? 0
        // self.titleLabel?.textColor = textColor ?? UIColor.blackColor()
        self.setTitleColor(textColor, forState: .Normal)
        self.layer.borderColor = borderColor?.CGColor ?? UIColor.blackColor().CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let initX: CGFloat = center.x - (size.width / 2.0)
        let initY: CGFloat = center.y - (size.height / 2.0)
        self.init(x: initX, y: initY, width: size.width, height: size.height)
    }
    
    func center() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}



