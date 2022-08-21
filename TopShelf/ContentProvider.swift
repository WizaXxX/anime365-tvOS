//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Илья Козырев on 21.08.2022.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        
        let wrapper = Session.instance.getKeyChainWrapper()
        guard let sessionId = wrapper.string(forKey: "sessionId") else { return }
        Session.instance.sessionId = sessionId
        Networker.shared.setSessionId()
        
        Networker.shared.getEpisoodesToWath { data in
            Task {
                let episodes = await Networker.shared.getNewEpisodesData(episodes: data)
                let items: [TVTopShelfSectionedItem] = episodes.map { data in
                    let item = TVTopShelfSectionedItem(identifier: String(data.1.id))
                    item.imageShape = .poster
                    item.title = data.1.episodeFull
                    
                    let localUrl = data.0.posterUrl.getLocalUrl()
                    item.setImageURL(localUrl, for: .screenScale1x)
                    item.setImageURL(localUrl, for: .screenScale2x)
                    item.displayAction = URL(string: "anime365-episode-watch://episode?episodeId=\(data.1.id)&animeId=\(data.0.id)").map { TVTopShelfAction(url: $0) }
                    return item
                }
                
                let collection = TVTopShelfItemCollection(items: items)
                let content = TVTopShelfSectionedContent(sections: [collection])
                completionHandler(content);
                
            }
        }
    }
}

