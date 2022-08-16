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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        loadData()
        collectionView.register(
            UINib(nibName: "EpisodeToWatchCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "EpisodeToWatchCollectionViewCell")
        
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

        let stb = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = stb.instantiateViewController(withIdentifier: "EpisodeViewController") as? EpisodeViewController else { return }
        vc.configure(from: episode)
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

extension NewEpisodesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodeIds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "EpisodeToWatchCollectionViewCell",
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
