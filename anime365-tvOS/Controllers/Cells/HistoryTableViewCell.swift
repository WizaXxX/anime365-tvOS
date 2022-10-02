//
//  HistoryTableViewCell.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 02.10.2022.
//

import UIKit
import ParallaxView

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var historyData: CloudUserEpisodeHistory?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        timeLabel.text = nil
        historyData = nil
    }
    
    func configure(from episodeHistoryData: CloudUserEpisodeHistory) {
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        timeLabel.text = formatter.string(from: TimeInterval(episodeHistoryData.time))
        titleLabel.text = episodeHistoryData.title
        historyData = episodeHistoryData
        
    }
}
