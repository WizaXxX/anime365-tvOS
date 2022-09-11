//
//  NewEpisodesViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 28.08.2022.
//

import UIKit

class NewEpisodesViewController: UIViewController, LoadedUIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var spinner = UIActivityIndicatorView(style: .large)
    var newEpisodes = [NewEpisodesData]()
    var pageNumber = 1
    var dataLoading = false
    var needLoadData = false
    
    let cellName = "EpisodeToWatchCollectionViewCell"
    let cellHeaderName = "NewEpisodesCollectionReusableView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinner.startAnimating()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellWithReuseIdentifier: cellName)
        
        collectionView.register(
            UINib(nibName: cellHeaderName, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: cellHeaderName)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needLoadData {
            newEpisodes = [NewEpisodesData]()
            collectionView.reloadData()
            pageNumber = 1
            needLoadData = false
            loadData()
        }
    }
    
    func loadData() {
        dataLoading = true
        spinner.startAnimating()
        Task {
            let data = await Networker.shared.getNewEpisodesAsync(pageNumber: pageNumber)
            spinner.stopAnimating()
            DispatchQueue.main.async { [weak self] in
                if self?.newEpisodes.count == 0 {
                    self?.newEpisodes = data
                    self?.collectionView.reloadData()
                } else {
                    self?.addDataToList(data: data)
                }
                self?.dataLoading = false
            }
        }
    }
    
    func addDataToList(data: [NewEpisodesData]) {
        var items = [IndexPath]()
        var newSections = [IndexSet]()
        data.forEach { newEpisodeData in
            var foundIndex = 0
            let dateIndex = self.newEpisodes.firstIndex(where: {$0.date == newEpisodeData.date})
            if dateIndex == nil {
                let dateSection = NewEpisodesData(date: newEpisodeData.date, episodes: [ShortEpisodeData]())
                self.newEpisodes.append(dateSection)
                foundIndex = self.newEpisodes.count - 1
                newSections.append(IndexSet(integer: foundIndex))
            } else {
                foundIndex = dateIndex!
            }

            for episodeData in newEpisodeData.episodes {
                self.newEpisodes[foundIndex].episodes.append(episodeData)
                items.append(IndexPath(row: self.newEpisodes[foundIndex].episodes.count - 1, section: foundIndex))
            }
        }
        
        collectionView.performBatchUpdates {
            for section in newSections {
                collectionView.insertSections(section)
            }
            collectionView.insertItems(at: items)
        }
    }
}

extension NewEpisodesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section > newEpisodes.count - 1 { return 0 }
        return newEpisodes[section].episodes.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return newEpisodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellName,
            for: indexPath) as! EpisodeToWatchCollectionViewCell
        
        let data = newEpisodes[indexPath.section].episodes[indexPath.row]
        cell.configure(episode: data.episode, anime: data.anime)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: cellHeaderName, for: indexPath) as! NewEpisodesCollectionReusableView
        header.mainLabel.text = "Новые серии \(newEpisodes[indexPath.section].date)"
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let numberOfNextElement = context.nextFocusedIndexPath?.last else { return }
        guard let numberOfSection = context.nextFocusedIndexPath?.first else { return }
        
        if numberOfNextElement >= (newEpisodes[numberOfSection].episodes.count * 24 / 100),
           newEpisodes.count - 1 == numberOfSection,
           !dataLoading {
            pageNumber += 1
            loadData()
        }
    }
}

extension NewEpisodesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EpisodeToWatchCollectionViewCell else { return }
        guard let episode = cell.episodeWithoutTranslations else { return }
        guard let currentAnime = cell.anime else { return }

        let vc = AllControlles.getPlayerViewController()
        vc.configure(anime: currentAnime, episodeWithoutTranslation: episode)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension NewEpisodesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let whiteSpaces: CGFloat = 8
        let cellWidth = width / 4 - whiteSpaces

        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
}
