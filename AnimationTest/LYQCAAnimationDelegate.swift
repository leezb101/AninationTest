//
//  LYQCAAnimationDelegate.swift
//  AnimationTest
//
//  Created by leezb101 on 2018/3/29.
//  Copyright © 2018年 luohe. All rights reserved.
//

import Foundation
import UIKit

class LYQCAAnimationDelegate: NSObject, CAAnimationDelegate {
    
    
    var didStartClosure: (() -> Void)?
    var didStopClosure: ((Bool) -> Void)?
    
    class func animationDelegateDidStart(didStart: @escaping () -> Void, didStop: @escaping (Bool) -> Void) -> LYQCAAnimationDelegate {
        
        let aniDelegate = LYQCAAnimationDelegate()
        aniDelegate.didStartClosure = didStart
        aniDelegate.didStopClosure = didStop
        
        return aniDelegate
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        if let didStart = didStartClosure {
            didStart()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let didStop = didStopClosure {
            didStop(flag)
        }
    }
    
}
