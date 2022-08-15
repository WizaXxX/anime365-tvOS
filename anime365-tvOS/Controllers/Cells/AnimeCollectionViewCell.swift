//
//  AnimeCollectionViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class AnimeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var anime: Anime?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        labelView.text = nil
        
    }
    
    func configure(from anime: Anime) {
        self.anime = anime
        self.labelView.text = anime.title
        DispatchQueue.global().async {
            let image = anime.posterUrl.getImage()
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        self.imageView.contentMode = .scaleAspectFill
        
    }
}
