//
//  EpisodeViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit

class EpisodeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var episodeWithTranslations: EpisodeWithTranslations?
    var episode: Episode?
    var anime: Anime?
    var typesOfTranslations: [TypeOfTranslation] = [TypeOfTranslation]()
    var translations: [Translation] = [Translation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if episodeWithTranslations != nil {
            loadData()
        } else {
            Networker.shared.getEpisodeWithTranslations(
                episodeId: episode!.id) { [weak self] data in
                    self?.episodeWithTranslations = data
                    self?.loadData()
                }
        }
        
        tableView.register(
            UINib(nibName: "TypeOfTraslationTableViewCell", bundle: nil),
            forCellReuseIdentifier: "TypeOfTraslationTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.register(
            UINib(nibName: "TranslationCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "TranslationCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configure(from episode: Episode, anime: Anime) {
        self.episode = episode
        self.anime = anime
    }
    
    func configure(from episode: EpisodeWithTranslations, anime: Anime) {
        self.episodeWithTranslations = episode
        self.anime = anime
    }
    
    func loadData() {
        
        var setOfTypes = Set<TypeOfTranslation>()
        episodeWithTranslations?.translations.forEach({setOfTypes.insert($0.type)})
        setOfTypes.forEach({typesOfTranslations.append($0)})
        typesOfTranslations.sort(by: {$0.getIndex() < $1.getIndex()})
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
    
}

extension EpisodeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typesOfTranslations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TypeOfTraslationTableViewCell",
            for: indexPath) as! TypeOfTraslationTableViewCell
        
        let type = typesOfTranslations[indexPath.row]
        cell.configure(typeOfTranslation: type)
        
        return cell
    }
}

extension EpisodeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TypeOfTraslationTableViewCell else { return }
        
        translations = [Translation]()
        episodeWithTranslations?.translations.filter({$0.type == cell.typeOfTranslation}).forEach({
            translations.append($0)
        })
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if let pindex  = context.previouslyFocusedIndexPath, let cell = tableView.cellForRow(at: pindex) {
            (cell as! TypeOfTraslationTableViewCell).labelView.textColor = .white
        }

        if let index  = context.nextFocusedIndexPath, let cell = tableView.cellForRow(at: index) {
            (cell as! TypeOfTraslationTableViewCell).labelView.textColor = .black
        }
    }
}

extension EpisodeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TranslationCollectionViewCell else { return }
        Networker.shared.getTranslationData(translationId: cell.translation!.id) { [weak self] result in
            
            let alert = UIAlertController(
                title: "Запуск видео", message: "Выберите качество",
                preferredStyle: UIAlertController.Style.actionSheet)
            
            for data in result.stream {
                alert.addAction(UIAlertAction(title: String(data.height), style: UIAlertAction.Style.default, handler: { action in
                    guard let stream = result.stream.first(where: {$0.height == Int(action.title!)!}) else { return }
                    
                    let stb = UIStoryboard(name: "Main", bundle: .main)
                    guard let vc = stb.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController else { return }
                    
                    guard let currentAnime = self?.anime else { return }
                    guard let numberOfEpisode = self?.episodeWithTranslations?.episodeInt else { return }
                    
                    vc.configure(
                        url: stream.urls[0],
                        subUrl: result.subtitlesVttUrl,
                        anime: currentAnime,
                        episodeNumber: numberOfEpisode)
                    
                    if let control = self?.navigationController {
                        control.pushViewController(vc, animated: true)
                    }
                    
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.cancel, handler: nil))
            DispatchQueue.main.async { [weak self] in
                
                self?.present(alert, animated: true, completion: nil)
            }
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

extension EpisodeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return translations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TranslationCollectionViewCell",
            for: indexPath) as! TranslationCollectionViewCell
        
        let translation = translations[indexPath.row]
        cell.configure(from: translation)
        return cell
    }
}

extension EpisodeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let whiteSpaces: CGFloat = 10
        let cellWidth = width / 3 - whiteSpaces

        return CGSize(width: 350, height: 120)
    }
}
