//
//  FocusableUIView.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 23.08.2022.
//

import UIKit
import ParallaxView

class FocusableUIView: UIView {

    override var canBecomeFocused: Bool {
        return true
    }
    
    let scale = 0.95
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 15
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
