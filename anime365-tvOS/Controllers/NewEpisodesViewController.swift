//
//  NewEpisodesViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 15.08.2022.
//

import UIKit

class NewEpisodesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var episodeIds = [[String: String]]()
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needLoadData {
            loadData()
        }
    }
    
    func loadData() {
        
        spinner.startAnimating()
        needLoadData = false
        episodeIds = [[String: String]]()
        collectionView.reloadData()
        
        Networker.shared.getEpisoodesToWath { [weak self] data in
            self?.episodeIds = data
            self?.spinner.stopAnimating()
            self?.collectionView.reloadData()
        }
    }
}

extension NewEpisodesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EpisodeToWatchCollectionViewCell else { return }
        guard let episode = cell.episode else { return }
        guard let currentAnime = cell.anime else { return }

        let vc = AllControlles.getEpisodeViewController()
        vc.configure(from: episode, anime: currentAnime)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        collectionView.updateFocus(context: context)
    }
}

extension NewEpisodesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodeIds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellName,
            for: indexPath) as! EpisodeToWatchCollectionViewCell
        
        let episodeId = episodeIds[indexPath.row]
        cell.configure(from: episodeId)
        
        return cell
    }
}

extension NewEpisodesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let whiteSpaces: CGFloat = 10
        let cellWidth = width / 4 - whiteSpaces

        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
}
