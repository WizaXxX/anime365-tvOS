//
//  BottomAlignedLabel.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 19.10.2022.
//

import Foundation
import UIKit

class BottomAlignedLabel: UILabel {

    override func drawText(in rect: CGRect) {

        guard text != nil else {
            return super.drawText(in: rect)
        }

        let height = self.sizeThatFits(rect.size).height
        let y = rect.origin.y + rect.height - height
        super.drawText(in: CGRect(x: 0, y: y, width: rect.width, height: height))
    }
}
