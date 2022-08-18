//
//  TypeOfTraslationTableViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit
import ParallaxView

class TypeOfTraslationCollectionViewCell: MainCollectionViewCell {

    @IBOutlet weak var labelView: UILabel!
    
    var typeOfTranslation: TypeOfTranslation = .some
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        labelView.text = nil
    }
    
    func configure(typeOfTranslation: TypeOfTranslation) {
        super.configure()
        
        self.typeOfTranslation = typeOfTranslation
        self.labelView.text = typeOfTranslation.rawValue
                
    }
}
