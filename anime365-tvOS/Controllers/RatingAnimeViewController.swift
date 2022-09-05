//
//  RatingAnimeViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 30.08.2022.
//

import UIKit

import UIKit

class RatingAnimeViewController: UIViewController, LoadedUIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var spinner = UIActivityIndicatorView(style: .large)
    var animes = [Anime]()
    var pageNumber = 1
    var dataLoading = false
    var needLoadData = false
    var pagesEnded = false
    
    let cellName = "AnimeCollectionViewCell"
    let maxItemCountOnOnePage = 12
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if needLoadData {
            animes = [Anime]()
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
            let data = await Networker.shared.getRatingsAnimeList(pageNumber: pageNumber)
            spinner.stopAnimating()
            if animes.contains(where: {$0.id == data.first?.id}) {
                pagesEnded = true
                return
            }
            if animes.count == 0 {
                animes = data
                collectionView.reloadData()
            } else {
                addAnimesToList(animeList: data)
            }
            dataLoading = false
        }
    }
    
    private func addAnimesToList(animeList: [Anime]) {
        collectionView.performBatchUpdates {
            var items = [IndexPath]()
            animeList.forEach { anime in
                self.animes.append(anime)
                items.append(IndexPath(row: self.animes.count - 1, section: 0))
            }
            self.collectionView.insertItems(at: items)
        }
    }
}

extension RatingAnimeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AnimeCollectionViewCell else { return }
        guard let anime = cell.anime else { return }
        
        let vc = AllControlles.getAnimeViewController()
        vc.configure(from: anime)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension RatingAnimeViewController: UICollectionViewDataSource {
    
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
           pagesEnded == false {
            
            pageNumber += 1
            loadData()
        }
    }
    
}

extension RatingAnimeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width
        let whiteSpaces: CGFloat = 10
        let cellWidth = width / 4 - whiteSpaces

        return CGSize(width: cellWidth, height: cellWidth * 1.5)
    }
}


