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
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var ratingLabelView: UILabel!
    
    var anime: Anime?
    
    let cellName = "EpisodeCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.insetsLayoutMarginsFromSafeArea = false
        labelView.text = anime?.titles["ru"]
        
        imageView.image = anime?.posterUrl.getImage()
        imageView.layer.cornerRadius = 15
        imageView.contentMode = .scaleToFill

        if let score = anime?.score {
            ratingLabelView.text = "Рейтинг: \(score) из 10"
        } else {
            ratingLabelView.text = ""
        }
        anime?.genres?.forEach({genresLabel.text! += "\($0.title)   "})
        
        collectionView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellWithReuseIdentifier: cellName)
        
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
        
        let vc = AllControlles.getEpisodeViewController()
        vc.configure(from: episode, anime: currentAnime)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AnimeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return anime?.episodes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellName,
            for: indexPath) as! EpisodeCollectionViewCell
        
        guard let episode = anime?.episodes?[indexPath.row] else { return cell }
        cell.configure(from: episode)
        return cell
    }
}

extension AnimeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 120)
    }
}
