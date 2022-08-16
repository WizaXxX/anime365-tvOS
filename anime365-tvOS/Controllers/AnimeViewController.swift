//
//  AnimeViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class AnimeViewController: UIViewController {

    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var anime: Anime?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insetsLayoutMarginsFromSafeArea = false
        labelView.text = anime?.title
        imageView.image = anime?.posterUrl.getImage()
        
        collectionView.register(
            UINib(nibName: "EpisodeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "EpisodeCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    func configure(from anime: Anime) {
        self.anime = anime
    }
}

extension AnimeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EpisodeCollectionViewCell else { return }
        guard let episode = cell.episode else { return }
        guard let currentAnime = anime else { return }
        
        let stb = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = stb.instantiateViewController(withIdentifier: "EpisodeViewController") as? EpisodeViewController else { return }
        vc.configure(from: episode, anime: currentAnime)
        if let control = navigationController {
            control.pushViewController(vc, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let pindex  = context.previouslyFocusedIndexPath, let cell = collectionView.cellForItem(at: pindex) {
            cell.contentView.layer.borderWidth = 0.0
            cell.contentView.layer.shadowRadius = 0.0
            cell.contentView.layer.shadowOpacity = 0.0
        }

        if let index  = context.nextFocusedIndexPath, let cell = collectionView.cellForItem(at: index) {
            cell.contentView.layer.borderWidth = 8.0
            cell.contentView.layer.borderColor = UIColor.white.cgColor
            cell.contentView.layer.shadowColor = UIColor.white.cgColor
            cell.contentView.layer.shadowRadius = 10.0
            cell.contentView.layer.shadowOpacity = 0.9
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
            collectionView.scrollToItem(at: index, at: [.centeredHorizontally, .centeredVertically], animated: true)
        }
    }
}

extension AnimeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return anime?.episodes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EpisodeCollectionViewCell",
            for: indexPath) as! EpisodeCollectionViewCell
        
        guard let episode = anime?.episodes?[indexPath.row] else { return cell }
        
        cell.configure(from: episode)
        return cell
    }
}

extension AnimeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let whiteSpaces: CGFloat = 10
        let cellWidth = width / 4 - whiteSpaces

        return CGSize(width: 250, height: 120)
    }
}
