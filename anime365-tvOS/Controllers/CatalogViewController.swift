//
//  animeToWatchViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import UIKit
import RealmSwift

class CatalogViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var animes: Results<RealmAnime>?
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectTableToRealm()
        getData()
        
        collectionView.register(
            UINib(nibName: "AnimeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "AnimeCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
        
    @IBAction func endEdit() {
        getData()
    }
    
    private func getData() {
        guard let search = searchTextField.text else { return }
        Networker.shared.getAnimeFromSite(searchString: search, completion: {})
    }
    
    private func connectTableToRealm() {
        guard let realm = try? Realm() else { return }
        animes = realm.objects(RealmAnime.self)
        token = animes?.observe( { [weak self] changes in
            switch changes {
            case .initial:
                self?.collectionView.reloadData()
            case .error(let error): print(error)
            case .update(_, _, _, _):
                DispatchQueue.main.async { [weak self] in
                    self?.collectionView.reloadData()
                }
            }
        })
    }
    
    private func getEpisodes(anime: RealmAnime) -> [Episode] {
        
        var episodes: [Episode] = [Episode]()
        
        for realmEpisode in anime.episodes {
            episodes.append(Episode(
                id: realmEpisode.id,
                numerOfEpisode: Int(realmEpisode.numerOfEpisode),
                tittle: realmEpisode.tittle,
                episodeType: realmEpisode.episodeType))
        }
        
        return episodes
    }
}

extension CatalogViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AnimeCollectionViewCell else { return }
        guard let anime = cell.anime else { return }
        
        let stb = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = stb.instantiateViewController(withIdentifier: "AnimeViewController") as? AnimeViewController else { return }
        vc.configure(from: anime)
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

extension CatalogViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AnimeCollectionViewCell",
            for: indexPath) as! AnimeCollectionViewCell
        
        guard let realmAnime = animes?[indexPath.row] else { return cell }
        
        cell.configure(from: Anime(
            id: realmAnime.id,
            title: realmAnime.title,
            posterUrlSmall: ImageFromInternet(url: realmAnime.posterUrlSmall),
            posterUrl: ImageFromInternet(url: realmAnime.posterUrl),
            episodes: getEpisodes(anime: realmAnime)))
        
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
