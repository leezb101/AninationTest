//
//  BasicAnimationController.swift
//  AnimationTest
//
//  Created by leezb101 on 2018/3/29.
//  Copyright © 2018年 luohe. All rights reserved.
//

import UIKit

class BasicAnimationController: UIViewController, CAAnimationDelegate {

    lazy var aniLayer: CALayer = {[unowned self] in
        let result = CALayer()
        result.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        result.position = self.view.center
        result.backgroundColor = UIColor.red.cgColor
        self.view.layer.addSublayer(result)
        return result
    }()
    
    var displayLink: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink(link:)))
        displayLink.preferredFramesPerSecond = 10
        displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        
    }

    @objc func handleDisplayLink(link: CADisplayLink) {
        print("modelLayer_\(aniLayer.position), presentLayer_\(String(describing: aniLayer.presentation()?.position))")
    }
    
    func basicAnimationMove(to position: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.delegate = self
        animation.toValue = position
        animation.duration = 3
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.speed = 0.4
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.setValue(position, forKey: "positionToEnd")
        animation.setValue("moveToAnimation", forKey: "AnimationIdentifier")
        aniLayer.add(animation, forKey: NSStringFromSelector(#function))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let point = touch.location(in: self.view)
        basicAnimationMove(to: point)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            if anim.value(forKey: "AnimationIdentifier") as! String == "moveToAnimation" {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                aniLayer.position = anim.value(forKey: "positionToEnd") as! CGPoint
                CATransaction.commit()
            }
        }
    }

}
