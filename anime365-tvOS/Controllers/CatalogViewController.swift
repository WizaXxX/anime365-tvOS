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
    
    var pageNumber = 1
    var newPageDownloading = false
    var pagesEnded = false
    let maxItemCountOnOnePage = 20
    
    var searchString: String = ""
    
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
        self.searchString = searchString
        
        pageNumber = 1
        animes.removeAll()
        spinner.startAnimating()
        collectionView.reloadData()
        
        Networker.shared.getAnimeFromSite(searchString: searchString) { [weak self] siteAnimes in
            DispatchQueue.main.async {
                self?.animes.removeAll()
                self?.addAnimesToList(siteAnimes: siteAnimes)
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
    
    private func addAnimesToList(siteAnimes: [SiteAnime]) {
        var items = [IndexPath]()
        siteAnimes.forEach { anime in
            animes.append(Anime(
                id: anime.id,
                title: anime.title,
                posterUrlSmall: ImageFromInternet(url: anime.posterUrlSmall),
                posterUrl: ImageFromInternet(url: anime.posterUrl),
                titles: anime.titles,
                episodes: getEpisodes(from: anime),
                genres: anime.genres?.map({Genre(id: $0.id, title: $0.title, url: $0.url)}),
                desc: anime.descriptions?.map({AnimeDescription(source: $0.source, value: $0.value)})))
            items.append(IndexPath(row: animes.count - 1, section: 0))
        }
        
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: items)
        }
        
    }
    
    private func loadNewPageData() {
        if newPageDownloading { return }
        newPageDownloading = true
        
        Networker.shared.getAnimeFromSite(
            searchString: searchString,
            offset: (maxItemCountOnOnePage * pageNumber)) { [weak self] siteAnimes in
                if siteAnimes.isEmpty {
                    self?.pagesEnded = true
                    return
                }
                self?.pageNumber += 1
                self?.addAnimesToList(siteAnimes: siteAnimes)
                self?.newPageDownloading = false
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let numberOfNextElement = context.nextFocusedIndexPath?.last else { return }
        if numberOfNextElement >= (animes.count * 70 / 100),
           animes.count == maxItemCountOnOnePage * pageNumber,
           pagesEnded == false{
            loadNewPageData()
        }
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
