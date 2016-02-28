//
//  GestureController.swift
//  Exifs
//
//  Created by Byunghoon Yoon on 2016-02-28.
//  Copyright © 2016 Byunghoon. All rights reserved.
//

import UIKit

class GestureController: NSObject {
    
    struct Config {
        let minDuration: NSTimeInterval
        let maxDuration: NSTimeInterval
        
        // All of these are absolute values
        let finalTranslation: CGFloat
        let thresholdTranslation: CGFloat
        let thresholdVelocity: CGFloat
    }
    
    private(set) var config: Config
    private(set) var gestureRecognizer: UIPanGestureRecognizer!
    
    var continuousActions: ((percentage: CGFloat) -> Void)?
    var discreteActions: (() -> Void)?
    var finished: (() -> Void)?
    
    init(config: Config) {
        self.config = config
        super.init()
        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleGesture:")
    }
    
    @objc func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view).x
        let velocity = gestureRecognizer.velocityInView(gestureRecognizer.view).x
        
        switch gestureRecognizer.state {
        case .Changed:
            continuousActions?(percentage: translation / config.finalTranslation)
            discreteActions?()
            
        case .Cancelled:
            animate(0, duration: config.maxDuration)
            
        case .Ended:
            if abs(velocity) > config.thresholdVelocity {
                if translation > 0 && velocity > 0 {
                    return complete()
                } else if translation < 0 && velocity < 0 {
                    return complete()
                }
            } else if abs(translation) > config.thresholdTranslation {
                if translation != 0 {
                    return complete()
                }
            }
            
            animate(0, duration: config.maxDuration)
            
        default:
            break
        }
    }
    
    private func complete() {
        let currentTranslation = gestureRecognizer.translationInView(gestureRecognizer.view).x
        let currentVelocity = gestureRecognizer.velocityInView(gestureRecognizer.view).x
        
        let deltaTranslation = config.finalTranslation - abs(currentTranslation)
        
        let suggestedDuration = NSTimeInterval(deltaTranslation / abs(currentVelocity))
        let duration = min(config.maxDuration, max(config.minDuration, suggestedDuration))
        
        let percentage = currentTranslation / self.config.finalTranslation
        animate(percentage > 0 ? 1 : -1, duration: duration)
    }
    
    private func animate(percentage: CGFloat, duration: NSTimeInterval) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: "timerDidFire", userInfo: nil, repeats: true)
        
        gestureRecognizer.view?.setNeedsUpdateConstraints()
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: {
            self.continuousActions?(percentage: percentage)
            
            }, completion: { (finished) in
                timer.invalidate()
                self.finished?()
        })
    }
    
    @objc func timerDidFire() {
        discreteActions?()
    }
}
