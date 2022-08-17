//
//  UICollectionView+.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 17.08.2022.
//

import Foundation
import UIKit

extension UICollectionView {
    func updateFocus(context: UICollectionViewFocusUpdateContext) {
        if let pindex  = context.previouslyFocusedIndexPath, let cell = self.cellForItem(at: pindex) {
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.shadowRadius = 0.0
            cell.contentView.layer.shadowOpacity = 0.0
        }

        if let index  = context.nextFocusedIndexPath, let cell = self.cellForItem(at: index) {
            cell.contentView.layer.borderWidth = 8.0
            cell.contentView.layer.borderColor = UIColor.white.cgColor
            cell.contentView.layer.shadowColor = UIColor.white.cgColor
            cell.contentView.layer.shadowRadius = 10.0
            cell.contentView.layer.shadowOpacity = 0.9
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.scrollToItem(at: index, at: [.centeredHorizontally, .centeredVertically], animated: true)
        }
    }
}
