//
//  AnimationsViewController.swift
//  AnimationTest
//
//  Created by leezb101 on 2018/3/29.
//  Copyright © 2018年 luohe. All rights reserved.
//

import UIKit

class AnimationsViewController: UIViewController {

    enum AniButtonType: Int {
        case move = 0
        case scale
        case translucent
        case rotate
        case corner
        case spring
        case keyShake
        case keyMovePath
        case groupAni
    }
    
    lazy var aniLayer: CALayer = {[unowned self] in
        let result = CALayer()
        result.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        result.position = self.view.center
        result.backgroundColor = UIColor.red.cgColor
        self.view.layer.addSublayer(result)
        return result
    }()
    
    @objc func handleDisplayLink(link: CADisplayLink) {
        print("modelLayer_\(aniLayer.position), presentLayer_\(String(describing: aniLayer.presentation()?.position))")
    }
    
    let buttonsName = ["位移", "缩放", "透明度", "旋转", "圆角", "弹性动画", "key晃动", "key位移", "动画组"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createButtonWith(titles: buttonsName)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createButtonWith(titles list: [String]) {
        for (index, item) in list.enumerated() {
            let info = (AniButtonType(rawValue: index), item)
            let button = createButtonWith(info: info as! (type: AnimationsViewController.AniButtonType, title: String))
            self.view.addSubview(button)
        }
    }
    
    func createButtonWith(info: (type: AniButtonType, title: String)) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = info.type.rawValue
        button.setTitle(info.title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.isExclusiveTouch = true
        button.frame = CGRect(x: 10, y: 50 + 60 * info.type.rawValue, width: 100, height: 50)
        button.backgroundColor = .yellow
        button.addTarget(self, action: #selector(tapAction(from:)), for: .touchUpInside)
        return button
    }
    
    @objc func tapAction(from sender: UIButton) {
        animationWith(type: AniButtonType(rawValue: sender.tag)!)
    }
    
    func animationWith(type: AniButtonType) {
        var animation: CABasicAnimation!
        var keyAnimation: CAKeyframeAnimation!
        switch type {
        case .move:
            animation = CABasicAnimation(keyPath: "position")
            animation.toValue = CGPoint(x: 100, y: 100)
            break
        case .scale:
            animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = 0.1
            break
        case .translucent:
            animation = CABasicAnimation(keyPath: "opacity")
            animation.toValue = 0.1
            break
        case .rotate:
            animation = CABasicAnimation(keyPath: "transform")
            animation.toValue = CATransform3DMakeRotation(.pi/2 + .pi/4, 1, 1, 0)
            break
        case .corner:
            animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.toValue = 50
            break
        case .spring:
            let springAni = CASpringAnimation(keyPath: "position")
            springAni.damping = 2
            springAni.stiffness = 50
            springAni.mass = 1
            springAni.initialVelocity = 10
            springAni.toValue = CGPoint(x: 200, y: 200)
            animation = springAni
        case .keyShake:
            let keyAni = CAKeyframeAnimation(keyPath: "transform.rotation")
            keyAni.duration = 0.3
            keyAni.values = [-4 / 180.0 * .pi, 4 / 180.0 * .pi, -4 / 180.0 * .pi]
            keyAni.repeatCount = MAXFLOAT
            keyAnimation = keyAni
        case .keyMovePath:
            let keyAni = CAKeyframeAnimation(keyPath: "position")
            let path = UIBezierPath()
            path.move(to: aniLayer.position)
            path.addCurve(to: CGPoint(x: 300, y: 500), controlPoint1: CGPoint(x: 100, y: 400), controlPoint2: CGPoint(x: 300, y: 450))
            keyAni.path = path.cgPath
            keyAni.duration = 1
            keyAni.calculationMode = kCAAnimationCubic
            keyAnimation = keyAni
        case .groupAni:
            animationGroup()
        }
        
        switch type {
        case .groupAni:
            break
        case .keyMovePath, .keyShake:
            aniLayer.add(keyAnimation, forKey: NSStringFromSelector(#function))
            break
        default:
            animation.delegate = self
            animation.beginTime = CACurrentMediaTime() + 1
            animation.duration = 1.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.autoreverses = true
            aniLayer.add(animation, forKey: NSStringFromSelector(#function))
        }

    }
    
    func animationGroup() {
        // 这里我们生成一个动画，晃动&位移1s到指定位置。接下来原地晃动2s，最后回到原位重新开始
        
        /// 晃动动画
        let shakeKeyAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        shakeKeyAnimation.values = [-4 / 180.0 * .pi, 4 / 180.0 * .pi, -4 / 180.0 * .pi]
        shakeKeyAnimation.duration = 0.3
        shakeKeyAnimation.repeatCount = MAXFLOAT
        shakeKeyAnimation.delegate = self
        
        /// 位移动画
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.toValue = CGPoint(x: 100, y: 100)
        moveAnimation.duration = 1
        moveAnimation.repeatCount = 1
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.fillMode = kCAFillModeForwards
        moveAnimation.delegate = self
        moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let group = CAAnimationGroup()
        group.animations = [shakeKeyAnimation, moveAnimation]
        group.autoreverses = true
        group.duration = 3
        group.repeatCount = 1
        group.delegate = LYQCAAnimationDelegate.animationDelegateDidStart(didStart: {
            print("动画组开始执行了")
        }, didStop: { (finished) in
            print("结束——\(finished)")
            print("动画组结束执行了")
        })
        aniLayer.add(group, forKey: "groupAnimation")
    }

}

extension AnimationsViewController: CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
    
    func animationPause() {
        let interval = aniLayer.convertTime(CACurrentMediaTime(), to: nil)
        aniLayer.timeOffset = interval
        aniLayer.speed = 0
    }
    
    func animationResume() {
        let beginTime = CACurrentMediaTime() + aniLayer.timeOffset
        aniLayer.timeOffset = 0
        aniLayer.beginTime = beginTime
        aniLayer.speed = 1
    }
    
    func animationStop() {
        aniLayer.removeAllAnimations()
    }
}
