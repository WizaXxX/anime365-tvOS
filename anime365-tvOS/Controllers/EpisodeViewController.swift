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
    
    let cellNameTypeOfTraslationTableViewCell = "TypeOfTraslationTableViewCell"
    let cellNameTranslationCollectionViewCell = "TranslationCollectionViewCell"
    
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
            UINib(nibName: cellNameTypeOfTraslationTableViewCell, bundle: nil),
            forCellReuseIdentifier: cellNameTypeOfTraslationTableViewCell)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.register(
            UINib(nibName: cellNameTranslationCollectionViewCell, bundle: nil),
            forCellWithReuseIdentifier: cellNameTranslationCollectionViewCell)
        
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
            withIdentifier: cellNameTypeOfTraslationTableViewCell,
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
                    guard let currentAnime = self?.anime else { return }
                    guard let numberOfEpisode = self?.episodeWithTranslations?.episodeInt else { return }
                    
                    let vc = AllControlles.getPlayerViewController()
                    vc.configure(
                        url: stream.urls[0],
                        subUrl: result.subtitlesVttUrl,
                        anime: currentAnime,
                        episodeNumber: numberOfEpisode)
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.cancel, handler: nil))
            DispatchQueue.main.async { [weak self] in
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        collectionView.updateFocus(context: context)
    }
}

extension EpisodeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return translations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellNameTranslationCollectionViewCell,
            for: indexPath) as! TranslationCollectionViewCell
        
        let translation = translations[indexPath.row]
        cell.configure(from: translation)
        return cell
    }
}

extension EpisodeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: 120)
    }
}
