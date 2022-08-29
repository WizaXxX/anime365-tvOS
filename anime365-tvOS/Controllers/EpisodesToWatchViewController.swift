//
//  NewEpisodesViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 15.08.2022.
//

import UIKit

class EpisodesToWatchViewController: UIViewController, LoadedUIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var episodes = [(Anime, EpisodeWithTranslations)]()
    var needLoadData = false
    var spinner = UIActivityIndicatorView(style: .large)
    
    let cellName = "EpisodeToWatchCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        loadData()
        collectionView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellWithReuseIdentifier: cellName)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(needReloadData),
            name: .init(rawValue: "NeedReloadNewEpisodeData"),
            object: nil)
        
    }
    
    @objc func needReloadData() {
        needLoadData = true
        DispatchQueue.main.async { [weak self] in
            self?.loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needLoadData {
            loadData()
        }
    }
    
    func loadData() {
        
        spinner.startAnimating()
        needLoadData = false
        episodes = [(Anime, EpisodeWithTranslations)]()
        collectionView.reloadData()
        
        Networker.shared.getEpisoodesToWath { [weak self] data in
            
            Task {
                self?.episodes = await Networker.shared.getNewEpisodesData(episodes: data)
                DispatchQueue.main.async { [weak self] in
                    self?.spinner.stopAnimating()
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}

extension EpisodesToWatchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EpisodeToWatchCollectionViewCell else { return }
        guard let episode = cell.episode else { return }
        guard let currentAnime = cell.anime else { return }

        let vc = AllControlles.getEpisodeViewController()
        vc.configure(from: episode, anime: currentAnime)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension EpisodesToWatchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellName,
            for: indexPath) as! EpisodeToWatchCollectionViewCell
        
        let episodeData = episodes[indexPath.row]
        cell.configure(episode: episodeData.1, anime: episodeData.0)
        return cell
    }
}

extension EpisodesToWatchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let whiteSpaces: CGFloat = 8
        let cellWidth = width / 4 - whiteSpaces

        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
}
