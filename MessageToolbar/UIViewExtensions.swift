//
//  UIViewExtensions.swift
//  MessageToolbar
//
//  Created by Vortex on 1/18/19.
//  Copyright © 2019 Vortex. All rights reserved.
//

import Foundation

extension UIView {
    func fadeIn(duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    func fadeOut(duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
    
    func fadeOutAndIn(duration: TimeInterval = 1.0) {
        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: { completed in
            self.fadeIn(duration: duration)
        })
    }
}
