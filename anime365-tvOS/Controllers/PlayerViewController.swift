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
    
    var episodeWithTranslation: EpisodeWithTranslations?
    var episodeWithoutTranslation: Episode?
    var anime: Anime?
    var translationData: SiteTranslationData?
    var translation: Translation?
    var stream: SiteStreamTranslationData?
    var nextEpisode: EpisodeWithTranslations?
    var episodeHistoryData: CloudUserEpisodeHistory?
    
    var currentTime: CMTime?
    var episodeWatched = false
    var nextEpisodeButtonShow = false
    var timeObserverToken: Any?
    var closeView = true
    var needLoadHistory = true

    let extendedLanguageTag = "und"
    let notificationName = "NeedReloadNewEpisodeData"
    
    private lazy var skipAction = UIAction(title: "Следующая серия") { [weak self] _ in
        self?.goToNextEpisode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        closeView = true
        
        if let episode = episodeWithoutTranslation {
            Task {
                guard let episodeWithTranslation = await Networker.shared.getEpisodeWithTranslationsAsync(
                    episodeId: episode.id, applyUserSettings: false) else { return }
                self.episodeWithTranslation = episodeWithTranslation
                translation = episodeWithTranslation.getTranslation()
                DispatchQueue.main.async {
                    self.loadTranslationData()
                }
            }
            return
        }
        
        if translation != nil && translationData == nil {
            loadTranslationData()
        }
        else {
            setupView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearView()
        player = nil
    }
    
    func clearView() {
        
        if !closeView {
            return
        }
        
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
        }
        episodeWithoutTranslation = nil
        episodeWithTranslation = nil
        anime = nil
        translationData = nil
        translation = nil
        stream = nil
        nextEpisode = nil
        episodeHistoryData = nil
    }
    
    func loadTranslationData(saveCurrentTime: Bool = true) {
        guard let translation = translation else { return }
        
        if saveCurrentTime {
            currentTime = player?.currentItem?.currentTime()
        }
        
        Networker.shared.getTranslationData(translationId: translation.id) { [weak self] result in
            self?.translationData = result
            self?.translationData?.stream.sort(by: {$0.height > $1.height})
            self?.stream = self?.translationData?.stream.first
            DispatchQueue.main.async {
                self?.setupView()
            }
        }
    }
    
    private func setupView() {
        setupPlayer()
        setupMenu()
    }
    
    func goToNextEpisode() {
        
        guard let currentTranslation = translation else { return }
        guard let episodeWithTranslation = nextEpisode else { return }
        guard let currentAnime = anime else { return }
        
        var translation: Translation?
        if let nextTranslation = episodeWithTranslation.translations.first(where: {$0.type == currentTranslation.type && $0.author == currentTranslation.author}) {
            translation = nextTranslation
        } else {
            if let typeOfTranslation = Session.instance.settings.comfortTypeOfTranslation {
                translation = episodeWithTranslation.translations.first(where: {$0.type == typeOfTranslation})
            } else {
                translation = episodeWithTranslation.translations.first
            }
        }
        guard let nextEpisodeTranslation = translation else { return }
        player?.pause()
        DispatchQueue.main.async { [weak self] in
            self?.clearView()
            self?.configure(anime: currentAnime, episode: episodeWithTranslation, translation: nextEpisodeTranslation)
            self?.loadTranslationData(saveCurrentTime: false)
        }
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
        
        let qualitySubmenu = UIMenu(
            title: "Качество",
            options: [.displayInline, .singleSelection],
            children: qualityActions)
        
        guard let streamHeight = stream?.height else { return }
        var image: UIImage?
        if streamHeight == 1080 {
            image = UIImage(named: "1080p")
        } else if streamHeight == 720 {
            image = UIImage(named: "720p")
        } else if streamHeight == 480 {
            image = UIImage(named: "480p")
        } else if streamHeight == 360 {
            image = UIImage(named: "360p")
        } else {
            image = UIImage(named: "?p")
        }
        
        let menu = UIMenu(title: "Настройки", image: image, children: [qualitySubmenu])
        
        getAnimeStatus()
        transportBarCustomMenuItems = [menu]
    }
    
    private func setAnimeStatus(status: AnimeStatus?) {
        var statusActions = [
            UIAction(
                title: "Запланировано",
                state: (status?.rawValue == 0 ? .on : .off),
                handler: { self.changeAnimeStatus(action: $0) }),
            UIAction(
                title: "Смотрю",
                state: (status?.rawValue == 1 ? .on : .off),
                handler: { self.changeAnimeStatus(action: $0) }),
            UIAction(
                title: "Просмотрено",
                state: (status?.rawValue == 2 ? .on : .off),
                handler: { self.changeAnimeStatus(action: $0) }),
            UIAction(
                title: "Отложено",
                state: (status?.rawValue == 3 ? .on : .off),
                handler: { self.changeAnimeStatus(action: $0) }),
            UIAction(
                title: "Брошено",
                state: (status?.rawValue == 4 ? .on : .off),
                handler: { self.changeAnimeStatus(action: $0) })
        ]
        
        if status != nil && status != .delete {
            statusActions.append(UIAction(
                title: "Удалить из списка",
                state: .off,
                handler: { self.changeAnimeStatus(action: $0) }))
        }
        
        let statusSubmenu = UIMenu(
            title: "Статус",
            options: [.displayInline, .singleSelection],
            children: statusActions)
        
        var image = UIImage(systemName: "checklist.unchecked")
        if status == .viewed {
            image = UIImage(systemName: "checklist.checked")
        } else if status == .look {
            image = UIImage(systemName: "checklist")
        }
        
        let menuStatus = UIMenu(title: "Статус", image: image, children: [statusSubmenu])
        if transportBarCustomMenuItems.count == 2 {
            transportBarCustomMenuItems.remove(at: 0)
        }
        transportBarCustomMenuItems.insert(menuStatus, at: 0)
    }
    
    private func getAnimeStatus() {
        Task {
            let status = await anime?.getStatus()
            setAnimeStatus(status: status)
        }
    }
    
    private func changeAnimeStatus(action: UIAction) {
        var status = AnimeStatus.delete
        
        switch action.title {
        case "Запланировано":
            status = .scheduled
        case "Смотрю":
            status = .look
        case "Просмотрено":
            status = .viewed
        case "Отложено":
            status = .postponed
        case "Брошено":
            status = .thrown
        case "Удалить из списка":
            status = .delete
        default:
            return
        }
        
        Task {
            guard let id = self.anime?.id else { return }
            Networker.shared.sendAnimeStatusAsync(animeId: String(id), animeStatus: status)
            NotificationCenter.default.post(name: .init(rawValue: notificationName), object: nil)
        }
        
        setAnimeStatus(status: status)
        
    }
            
    private func tryToLoadNextEpisode() {
        guard let episodeNumber = episodeWithTranslation?.episodeInt else { return }
        guard let nextEpisode = anime?.episodes?.first(where: {$0.numerOfEpisode == episodeNumber + 1}) else { return }
        
        Task {
            guard let episodeWithTranslation = await Networker.shared.getEpisodeWithTranslationsAsync(
                episodeId: nextEpisode.id) else { return }
            contextualActions = [skipAction]
            self.nextEpisode = episodeWithTranslation
        }
    }
    
    private func changeQuality(quality: Int) {
        currentTime = player?.currentItem?.currentTime()
        stream = translationData?.stream.first(where: {$0.height == quality})
        needLoadHistory = false
        setupView()
    }
    
    private func checkTime() {
        guard let durationCM = player?.currentItem?.duration else { return }
        guard let currentTimeCM = player?.currentTime() else { return }
        
        let duration = CMTimeGetSeconds(durationCM)
        let currentTime = CMTimeGetSeconds(currentTimeCM)
        let partOfVideo = (duration - currentTime) / duration * 100
        
        saveEpisodeHistory(Int64(currentTime))
        
        if partOfVideo < 16, !episodeWatched {

            guard let animeId = anime?.id else { return }
            guard let episodeId = episodeWithTranslation?.episodeInt else { return }

            Networker.shared.episodeWatched(animeId: String(animeId), episodeNumber: episodeId)
            NotificationCenter.default.post(name: .init(rawValue: notificationName), object: nil)
            episodeWatched = true
        }
        
        if partOfVideo < 10, !nextEpisodeButtonShow {
            tryToLoadNextEpisode()
            nextEpisodeButtonShow = true
        }
    }
    
    private func goToAnimeVC() {
        guard let currentAnime = self.anime else { return }
        
        player?.pause()
        currentTime = player?.currentItem?.currentTime()
        closeView = false
        
        let vc = AllControlles.getAnimeViewController()
        vc.configure(from: currentAnime)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func saveEpisodeHistory(_ currentTime: Int64) {
        guard let episodeId = episodeWithTranslation?.id,
              let animeTitle = anime?.titles["ru"],
              let episodeTitle = episodeWithTranslation?.episodeFull,
              let currentTranslationId = translation?.id else { return }
        
        let title = "\(animeTitle) (\(episodeTitle))"
        DispatchQueue.main.async {
            CloudHelper.shared.saveEpisodeHistory(
                id: episodeId,
                time: currentTime,
                title: title,
                translationId: currentTranslationId)
        }
    }
    
}

// MARK: Assets opearations
extension PlayerViewController {
    
    private func setupAsset(videoAsset: AVURLAsset) {
        
        var mixComposition = AVMutableComposition()
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: .max)
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: .max)

        setSubtitles(mixComposition: &mixComposition)

        do {
            try videoTrack?.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                of: videoAsset.tracks(withMediaType: .video).first!,
                at: .zero)
            try audioTrack?.insertTimeRange(
                CMTimeRangeMake(start: .zero, duration: videoAsset.duration),
                of: videoAsset.tracks(withMediaType: .audio).first!,
                at: .zero)
        } catch let err {
            print(err.localizedDescription)
        }
        
        contextualActions.removeAll()
        
        infoViewActions.removeAll()
        let watchLater = UIAction(
            title: "Перейти к аниме",
            image: UIImage(systemName: "arrowshape.turn.up.right.circle.fill")) { [weak self] _ in
                self?.goToAnimeVC()
                
            }
        infoViewActions.append(watchLater)
        
        setCustomInfoViewControllers()
        
        let item = AVPlayerItem(asset: mixComposition)
        item.externalMetadata = getMetadata()
        
        if player?.currentItem ==  nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }
        
        if let currentTime = currentTime {
            player?.seek(to: currentTime)
        }
        
        player?.play()
        addBoundaryTimeObserver()
        checkEpisodeInHistory()
        
        player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 60),
            queue: .global()) { time in
//                CMTimeGetSeconds(time)
                print(time)
            }
        
    }
    
    private func addBoundaryTimeObserver() {
        guard let duration = player?.currentItem?.duration else { return }
        var times = [NSValue]()
        var currentTime = CMTime.zero
        
        let interval = CMTimeMultiplyByFloat64(duration, multiplier: 0.01)
        while currentTime < duration {
            currentTime = currentTime + interval
            times.append(NSValue(time: currentTime))
        }
        
        timeObserverToken = player?.addBoundaryTimeObserver(
            forTimes: times,
            queue: .global(),
            using: {self.checkTime()})
        
    }
    
    private func checkEpisodeInHistory() {
        
        if !needLoadHistory {
            needLoadHistory = true
            return
        }
        
        if self.episodeHistoryData != nil {
            continueWatch()
            return
        }
        
        guard let episodeId = episodeWithTranslation?.id,
              let episodeHistoryData = Session.instance.settings.episodeHistory.first(where: {$0.id == episodeId})
        else { return }
        
        self.episodeHistoryData = episodeHistoryData
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad

        let timeString = formatter.string(from: TimeInterval(episodeHistoryData.time))
        guard let time = timeString else { return }
        
        let alert = UIAlertController(
            title: "Продолжить просмотр с \(time) ?",
            message: nil,
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default,
            handler: { [weak self] _ in
                self?.continueWatch()
            }))
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .cancel,
            handler: { [weak self] _ in
                self?.episodeHistoryData = nil
            }))
                        
        present(alert, animated: true)
        
    }
    
    private func continueWatch() {
        guard let time = episodeHistoryData?.time,
              let translationId = episodeHistoryData?.translationId else { return }
        
        if translationId != translation?.id {
            translation = episodeWithTranslation?.translations.first(where: {$0.id == translationId})
            loadTranslationData(saveCurrentTime: false)
        } else {
            player?.seek(to: CMTime(seconds: Double(time), preferredTimescale: 1))
            episodeHistoryData = nil
        }
    }
    
    private func getMetadata() -> [AVMutableMetadataItem] {
        
        var extMetadata = [AVMutableMetadataItem]()
        
        let metadataTitle = AVMutableMetadataItem()
        metadataTitle.identifier = .commonIdentifierTitle
        metadataTitle.value = anime?.titles["ru"] as? NSCopying & NSObjectProtocol
        metadataTitle.extendedLanguageTag = "und"
        extMetadata.append(metadataTitle)
        
        
        var episodeTitle = ""
        if let translation = translation,
           let episodeFullName = episodeWithTranslation?.episodeFull,
           let numberOfEpisodes = anime?.numberOfEpisodes {
            episodeTitle = "\(episodeFullName) из \(numberOfEpisodes) (\(translation.type.rawValue) \(translation.author))"
        } else {
            episodeTitle = episodeWithTranslation?.episodeFull ?? ""
        }
        let metadataSubTitle = AVMutableMetadataItem()
        metadataSubTitle.identifier = .iTunesMetadataTrackSubTitle
        metadataSubTitle.value = episodeTitle as NSCopying & NSObjectProtocol
        metadataSubTitle.extendedLanguageTag = extendedLanguageTag
        extMetadata.append(metadataSubTitle)
        
        let metadataDesc = AVMutableMetadataItem()
        metadataDesc.identifier = .commonIdentifierDescription
        if let desc = anime?.desc?.first {
            metadataDesc.value = desc.value as NSCopying & NSObjectProtocol
        } else {
            metadataDesc.value = "" as NSCopying & NSObjectProtocol
        }
        metadataDesc.extendedLanguageTag = extendedLanguageTag
        extMetadata.append(metadataDesc)
        
        let metadataRating = AVMutableMetadataItem()
        metadataRating.identifier = .iTunesMetadataContentRating
        metadataRating.value = anime?.score as? NSCopying & NSObjectProtocol
        metadataRating.extendedLanguageTag = extendedLanguageTag
        extMetadata.append(metadataRating)
        
        let metadataArtwork = AVMutableMetadataItem()
        metadataArtwork.identifier = .commonIdentifierArtwork
        metadataArtwork.value = anime?.posterUrl.getImage().pngData() as? NSCopying & NSObjectProtocol
        metadataArtwork.extendedLanguageTag = extendedLanguageTag
        extMetadata.append(metadataArtwork)
        
        return extMetadata
    }
    
    private func setSubtitles(mixComposition: inout AVMutableComposition) {
        guard let urlOfSub = translationData?.subtitlesVttUrl else { return }
        guard let subtitleUrl = URL(string: urlOfSub) else { return }
        guard let subtitleData = try? Data(contentsOf: subtitleUrl) else { return }
        guard let subText = String(data: subtitleData, encoding: .utf8) else { return }
        
        let subTextFinal = subText.replacingOccurrences(of: "00:00.000 --> 00:00.000", with: "00:00.000 --> 00:00.001")
        guard let subDataFinal = subTextFinal.data(using: .utf8) else { return }
        
        guard let dir = try? FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        else { return }
        
        
        try? subDataFinal.write(to: dir.appendingPathComponent("sub.vtt"))
        
        let pathToFile = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("sub.vtt").absoluteURL
        let subtitleAsset = AVURLAsset(url: pathToFile)
        let subtitleTrack = mixComposition.addMutableTrack(withMediaType: .text, preferredTrackID: .max)
        try? subtitleTrack?.insertTimeRange(
            CMTimeRangeMake(start: .zero, duration: subtitleAsset.duration),
            of: subtitleAsset.tracks(withMediaType: .text).first!, at: .zero)
    }
            
    private func setCustomInfoViewControllers() {
        
        let vc = AllControlles.getEpisodeViewController()
        vc.configure(from: episodeWithTranslation!, anime: anime!)
        vc.playerVC = self
        
        customInfoViewControllers = [vc]
        
    }
}

// MARK: Configuration
extension PlayerViewController {
    func configure(anime: Anime, episode: EpisodeWithTranslations, translation: Translation) {
        self.anime = anime
        self.episodeWithTranslation = episode
        self.translation = translation
        self.currentTime = .zero
        self.nextEpisodeButtonShow = false
        self.episodeWatched = false
    }
    
    func configure(anime: Anime, episodeWithoutTranslation: Episode) {
        self.anime = anime
        self.episodeWithoutTranslation = episodeWithoutTranslation
        self.currentTime = .zero
        self.nextEpisodeButtonShow = false
        self.episodeWatched = false
    }
}
