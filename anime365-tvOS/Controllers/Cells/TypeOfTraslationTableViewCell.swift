//
//  TypeOfTraslationTableViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class TypeOfTraslationTableViewCell: UITableViewCell {

    @IBOutlet weak var labelView: UILabel!
    
    var typeOfTranslation: TypeOfTranslation = .some
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        labelView.text = nil
    }
    
    func configure(typeOfTranslation: TypeOfTranslation) {
        self.typeOfTranslation = typeOfTranslation
        self.labelView.text = typeOfTranslation.rawValue
    }
}
