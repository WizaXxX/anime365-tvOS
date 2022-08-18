//
//  animeToWatchViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import UIKit

class CatalogViewController: UIViewController {
    
    weak var delegate: CatalogViewControllerDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var animes: [Anime] = [Anime]()
    var spinner = UIActivityIndicatorView(style: .large)
    
    let cellName = "AnimeCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        collectionView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellWithReuseIdentifier: cellName)

        collectionView.dataSource = self
        collectionView.delegate = self
    }
        
    
    func loadData(searchString: String) {
        
        animes.removeAll()
        spinner.startAnimating()
        collectionView.reloadData()
        
        Networker.shared.getAnimeFromSite(searchString: searchString) { [weak self] siteAnimes in
            siteAnimes.forEach { anime in
                self?.animes.append(Anime(
                    id: anime.id,
                    title: anime.title,
                    posterUrlSmall: ImageFromInternet(url: anime.posterUrlSmall),
                    posterUrl: ImageFromInternet(url: anime.posterUrl),
                    titles: anime.titles,
                    episodes: self?.getEpisodes(from: anime)))
            }
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.spinner.stopAnimating()
            }
        }
    }
        
    private func getEpisodes(from anime: SiteAnime) -> [Episode] {
        
        var episodes: [Episode] = [Episode]()
        guard let siteEpisodes = anime.episodes else { return episodes }
        for siteEpisode in siteEpisodes {
            episodes.append(Episode(
                id: siteEpisode.id,
                numerOfEpisode: Int(siteEpisode.numerOfEpisode) ?? 0,
                tittle: siteEpisode.tittle,
                episodeType: siteEpisode.episodeType))
        }
        return episodes
    }
}

extension CatalogViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AnimeCollectionViewCell else { return }
        guard let anime = cell.anime else { return }
        
        let vc = AllControlles.getAnimeViewController()
        vc.configure(from: anime)
        delegate?.showChildView(viewController: vc)
    }
}

extension CatalogViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellName,
            for: indexPath) as! AnimeCollectionViewCell
        
        let anime = animes[indexPath.row]
        cell.configure(from: anime)
        
        return cell
    }
}

extension CatalogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let whiteSpaces: CGFloat = 10
        let cellWidth = width / 4 - whiteSpaces

        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
}
