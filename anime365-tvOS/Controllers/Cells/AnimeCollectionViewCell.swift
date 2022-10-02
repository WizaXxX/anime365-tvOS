//
//  AnimeCollectionViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class AnimeCollectionViewCell: MainCollectionViewCell {
    
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scoreLabelView: UILabel!
    
    var anime: Anime?
    
    let durationOfAnimationInSecond = 1.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        labelView.text = nil
        
    }
    
    func configure(from anime: Anime) {
        super.configure()
        
        self.anime = anime
        
        self.labelView.text = anime.titles["ru"]
        self.labelView.sizeToFit()
        
        self.scoreLabelView.text = anime.score
        DispatchQueue.global().async {
            let image = anime.posterUrl.getImage()
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        self.imageView.contentMode = .scaleAspectFill
    }
}
