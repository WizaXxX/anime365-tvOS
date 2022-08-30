//
//  AnimeCollectionViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class AnimeCollectionViewCell: MainCollectionViewCell {
    
    @IBOutlet weak var labelView: UILabelViewWithTextLoopAnimation!
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
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if let view = context.nextFocusedView {
            if view == self {
                labelView.startLoopAnimation()
            }
        }

        if let view = context.previouslyFocusedView as? AnimeCollectionViewCell {
            view.labelView.layer.removeAllAnimations()
            view.labelView.transform = .identity
        }
    }
}
