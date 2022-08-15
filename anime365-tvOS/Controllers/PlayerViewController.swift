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
    
    var url: String?
    var subUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let urlToVideo = url else { return }
        guard let videoUrl = URL(string: urlToVideo) else { return }
        
        let videoAsset = AVURLAsset(url: videoUrl)

        let mixComposition = AVMutableComposition()

        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: .max)
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: .max)

        if subUrl != nil {
            guard let subtitleUrl = URL(string: subUrl!) else { return }
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
            try? subtitleTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: subtitleAsset.duration),
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
        
        self.player = AVPlayer(playerItem: AVPlayerItem(asset: mixComposition))
        player?.play()
    }
    
    func configure(url: String, subUrl: String?) {
        self.url = url
        self.subUrl = subUrl
    }
    
}
