//
//  HistoryViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 02.10.2022.
//

import UIKit

class HistoryViewController: UIViewController, LoadedUIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let cellName = "HistoryTableViewCell"
    
    var historyData: [CloudUserEpisodeHistory]?
    var needLoadData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: cellName, bundle: nil),
            forCellReuseIdentifier: cellName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needLoadData {
            historyData = Session.instance.settings.episodeHistory.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
            tableView.reloadData()
        }
    }
}

extension HistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellName,
            for: indexPath) as! HistoryTableViewCell
        
        guard let data = historyData?[indexPath.row] else { return UITableViewCell() }
        cell.configure(from: data)
        cell.selectionStyle = .none
        return cell
        
    }
    
}

extension HistoryViewController: UITableViewDelegate {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if let view = context.nextFocusedView as? HistoryTableViewCell {
            coordinator.addCoordinatedAnimations {
                view.backgroundColor = .white
                view.titleLabel.textColor = .darkGray
                view.timeLabel.textColor = .gray
            }
        }
        
        if let view = context.previouslyFocusedView as? HistoryTableViewCell {
            coordinator.addCoordinatedAnimations {
                view.backgroundColor = .clear
                view.titleLabel.textColor = .secondaryLabel
                view.timeLabel.textColor = .quaternaryLabel
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? HistoryTableViewCell else { return }
        guard let episodeId = cell.historyData?.id,
              let translationId = cell.historyData?.translationId else { return }
        
        Task {
            guard let episode = await Networker.shared.getEpisodeWithTranslationsAsync(episodeId: episodeId, applyUserSettings: false) else { return }
            guard let translation = episode.translations.first(where: {$0.id == translationId}) else { return }
            guard let anime = await Networker.shared.getAnimeAsync(id: String(episode.seriesId)) else { return }
            
            DispatchQueue.main.async { [weak self] in
                let vc = AllControlles.getPlayerViewController()
                vc.configure(anime: anime, episode: episode, translation: translation)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
