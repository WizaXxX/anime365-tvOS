//
//  TranslationCollectionViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class TranslationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelView: UILabel!
    
    var translation: Translation?
    
    func configure(from translation: Translation) {
        self.translation = translation
        
        if translation.author.isEmpty {
            self.labelView.text = "Субтитры"
        } else {
            self.labelView.text = translation.author
        }
         
    }
    
}
