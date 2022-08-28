//
//  NewEpisodesCollectionReusableView.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 28.08.2022.
//

import UIKit

class NewEpisodesCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var mainLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainLabel.text = nil
    }
    
    func configure(label: String) {
        self.mainLabel.text = label
    }
}
