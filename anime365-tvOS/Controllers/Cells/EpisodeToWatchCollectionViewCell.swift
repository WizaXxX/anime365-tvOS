//
//  EpisodeToWatchCollectionViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 15.08.2022.
//

import UIKit

class EpisodeToWatchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var episodeLabelView: UILabel!
    
    var episode: EpisodeWithTranslations?
    var anime: Anime?
    var episodeId: String?
    var animeId: String?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        labelView.text = nil
        episodeLabelView.text = nil
        
    }
    
    func configure(from data: [String: String]) {
        self.imageView.contentMode = .scaleAspectFill
        
        self.animeId = data.first?.key
        self.episodeId = data.first?.value
        
        DispatchQueue.global().async { [weak self] in
            guard let id = Int((self?.episodeId!)!) else { return }
            Networker.shared.getEpisodeWithTranslations(episodeId: id) { result in
                self?.episode = result
                self?.episodeLabelView.text = result.episodeFull
            }
        }
        DispatchQueue.global().async { [weak self] in
            guard let id = self?.animeId else { return }
            Networker.shared.getAnime(id: id) { result in
                self?.anime = result
                DispatchQueue.main.async {
                    self?.labelView.text = result.title
                    self?.imageView.image = result.posterUrl.getImage()
                }
            }
        }
    }
}
