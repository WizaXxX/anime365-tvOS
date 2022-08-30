//
//  UILabelViewWithTextLoopAnimation.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 30.08.2022.
//

import Foundation
import UIKit

class UILabelViewWithTextLoopAnimation: UILabel {
    func startLoopAnimation() {
        
        guard let superView = self.superview else { return }
        if self.bounds.width + 10 <= superView.bounds.width { return }
        
        let combinedAnimationOptions: UIView.AnimationOptions = [.repeat, .curveLinear, .autoreverse]
        
        let defaultXMovement: CGFloat = (self.bounds.width - (self.bounds.width * 0.2))
        UIView.animate(withDuration: 6, delay: 1.4, options: combinedAnimationOptions, animations: {
            self.transform = CGAffineTransform.identity.translatedBy(x: -defaultXMovement, y: 0)
        }, completion: nil)
    }
}
