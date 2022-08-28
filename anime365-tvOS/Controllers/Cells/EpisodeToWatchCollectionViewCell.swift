//
//  EpisodeToWatchCollectionViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 15.08.2022.
//

import UIKit

class EpisodeToWatchCollectionViewCell: MainCollectionViewCell {
    
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var episodeLabelView: UILabel!
    
    var episode: EpisodeWithTranslations?
    var anime: Anime?
    var episodeWithoutTranslations: Episode?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        labelView.text = nil
        episodeLabelView.text = nil
    
    }
    
    func configure(episode: EpisodeWithTranslations, anime: Anime) {
        super.configure()
        
        self.anime = anime
        self.episode = episode
        
        self.imageView.contentMode = .scaleAspectFill
        self.episodeLabelView.text = episode.episodeFull
        
        self.labelView.text = anime.titles["ru"]
        DispatchQueue.global().async {
            let image = anime.posterUrl.getImage()
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    func configure(episode: Episode, anime: Anime) {
        super.configure()
        
        self.anime = anime
        self.episodeWithoutTranslations = episode
        
        self.imageView.contentMode = .scaleAspectFill
        self.episodeLabelView.text = episode.tittle
        
        self.labelView.text = anime.titles["ru"]
        DispatchQueue.global().async {
            let image = anime.posterUrl.getImage()
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
}
