//
//  FocusableUIView.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 23.08.2022.
//

import UIKit
import ParallaxView

class FocusableUIView: ParallaxView {

    override var canBecomeFocused: Bool {
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cornerRadius = 15
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cornerRadius = 15
    }
}
