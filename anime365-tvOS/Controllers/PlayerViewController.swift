//
//  PlayerViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import UIKit
import AVKit
import AVFoundation

class PlayerViewController: AVPlayerViewController {
    
    var episode: EpisodeWithTranslations?
    var anime: Anime?
    var translationData: SiteTranslationData?
    var stream: SiteStreamTranslationData?
    var currentTime: CMTime?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupPlayer()
        setupMenu()
        enablePeriodObserver()
        
    }
    
    func configure(anime: Anime, episode: EpisodeWithTranslations, translationData: SiteTranslationData) {
        self.anime = anime
        self.episode = episode
        self.translationData = translationData
        
        self.translationData?.stream.sort(by: {$0.height > $1.height})
        self.stream = self.translationData?.stream.first
        
        guard let currentStream = self.stream, let animeTitle = anime.titles["ru"] else { return }
        title = "\(currentStream.height)p - \(animeTitle)"
    }
    
    private func setupPlayer() {
        guard let urlToVideo = stream?.urls.first else { return }
        guard let videoUrl = URL(string: urlToVideo) else { return }
        
        let videoAsset = AVURLAsset(url: videoUrl)
        videoAsset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
            if videoAsset.tracks.count == 0 {
                self?.setupPlayer()
                return
            }
            DispatchQueue.main.async {
                self?.setupAsset(videoAsset: videoAsset)
            }
        }
    }
    
    private func setupAsset(videoAsset: AVURLAsset) {
        
        let mixComposition = AVMutableComposition()
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: .max)
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: .max)

        if let urlOfSub = translationData?.subtitlesVttUrl {
            guard let subtitleUrl = URL(string: urlOfSub) else { return }
            guard let subtitleData = try? Data(contentsOf: subtitleUrl) else { return }
            
            guard let dir = try? FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            else { return }
            
            try? subtitleData.write(to: dir.appendingPathComponent("sub.vtt"))
            let pathToFile = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("sub.vtt").absoluteURL
            let subtitleAsset = AVURLAsset(url: pathToFile)
            let subtitleTrack = mixComposition.addMutableTrack(withMediaType: .text, preferredTrackID: .max)
            try? subtitleTrack?.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: subtitleAsset.duration),
                of: subtitleAsset.tracks(withMediaType: .text).first!, at: .zero)
        }

        do {
            try videoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                                            of: videoAsset.tracks(withMediaType: .video).first!,
                                            at: .zero)
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                                            of: videoAsset.tracks(withMediaType: .audio).first!,
                                            at: .zero)
        } catch let err {
            print(err.localizedDescription)
        }
        let item = AVPlayerItem(asset: mixComposition)
        if player?.currentItem ==  nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }
        
        if let currentTime = currentTime {
            player?.seek(to: currentTime)
        }
        
        player?.play()
        title = ""
        
    }
    
    private func setupMenu() {
        guard let translationData = translationData else { return }

        var qualityActions = [UIAction]()
        for item in translationData.stream {
            qualityActions.append(UIAction(
                title: String(item.height),
                state: (item.height == stream?.height ? .on : .off)) { [weak self] action in
                    guard let quality = Int(action.title) else { return }
                    DispatchQueue.main.async {
                        self?.changeQuality(quality: quality)
                    }
            })
        }
        
        let submenu = UIMenu(
            title: "Качество",
            options: [.displayInline, .singleSelection],
            children: qualityActions)
        let menu = UIMenu(title: "Настройки", image: UIImage(systemName: "gearshape"), children: [submenu])
        self.transportBarCustomMenuItems = [menu]
    }
    
    private func enablePeriodObserver() {
        player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 30.0, preferredTimescale: 1),
            queue: DispatchQueue.global(),
            using: { [weak self] time in
                
                guard let durationCM = self?.player?.currentItem?.duration else { return }
                guard let currentTimeCM = self?.player?.currentTime() else { return }
                
                let duration = CMTimeGetSeconds(durationCM)
                let currentTime = CMTimeGetSeconds(currentTimeCM)
                let partOfVideo = (duration - currentTime) / duration * 100
                
                if partOfVideo < 16 {
                    guard let animeId = self?.anime?.id else { return }
                    guard let episodeId = self?.episode?.episodeInt else { return }
                    
                    Networker.shared.episodeWatched(
                        animeId: String(animeId),
                        episodeNumber: episodeId)
                    NotificationCenter.default.post(name: .init(rawValue: "NeedReloadNewEpisodeData"), object: nil)
                }
        })
    }
    
    private func changeQuality(quality: Int) {
        player?.pause()
        currentTime = player?.currentItem?.currentTime()
        stream = translationData?.stream.first(where: {$0.height == quality})
        setupPlayer()
    }
    
}
