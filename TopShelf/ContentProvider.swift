//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Илья Козырев on 21.08.2022.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        
        guard let sessionData = Session.getSessionData() else { return }
        Session.setSessionData(sessionData: sessionData)
        Networker.shared.setSessionData()
        
        Networker.shared.getEpisoodesToWath { data in
            Task {
                let episodes = await Networker.shared.getNewEpisodesData(episodes: data)
                let items: [TVTopShelfSectionedItem] = episodes.map { data in
                    let item = TVTopShelfSectionedItem(identifier: String(data.1.id))
                    item.imageShape = .poster
                    item.title = data.1.episodeFull
                    
                    let url = URL(string: data.0.posterUrl.url)
                    item.setImageURL(url, for: .screenScale1x)
                    item.setImageURL(url, for: .screenScale2x)
                    item.displayAction = URL(string: "anime365-episode-watch://episode?episodeId=\(data.1.id)&animeId=\(data.0.id)").map { TVTopShelfAction(url: $0) }
                    return item
                }
               
                let collection = TVTopShelfItemCollection(items: items)
                collection.title = "Новые серии"
                let content = TVTopShelfSectionedContent(sections: [collection])
                completionHandler(content);
                
            }
        }
    }
}

