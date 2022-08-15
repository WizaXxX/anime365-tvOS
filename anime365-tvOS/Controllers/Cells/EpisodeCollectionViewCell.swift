//
//  EpisodeCollectionViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelView: UILabel!
    
    var episode: Episode?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        labelView.text = nil
    }
    
    func configure(from episode: Episode) {
        self.episode = episode
        self.labelView.text = episode.tittle
    }
    
}
