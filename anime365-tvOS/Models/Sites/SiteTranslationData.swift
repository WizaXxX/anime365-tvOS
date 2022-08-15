//
//  SiteTranslationData.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct SiteTranslationData: Decodable {
    var embedUrl: String
    var download: [SiteDownloadTranslationData]
    var stream: [SiteStreamTranslationData]
    var subtitlesUrl: String?
    var subtitlesVttUrl: String?
}
