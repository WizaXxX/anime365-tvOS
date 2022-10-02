//
//  Networker.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper
import SwiftSoup

enum Methods {
    case login, getSerieses
    case getEpisodeWithTranslation(id: String)
    case getTranslationData(id: String)
    case main
    case getAnime(id: String)
    case episodeWatched(id: String)
    case getSubscriptionData
    case getNewEpisodes(page: Int)
    case getRatingsAnimeList
    
    var value: String {
        switch self {
        case .login:
            return "users/login"
        case .getSerieses:
            return "api/series"
        case .getEpisodeWithTranslation(let id):
            return "api/episodes/\(id)"
        case .getTranslationData(let id):
            return "api/translations/embed/\(id)"
        case .main:
            return ""
        case .getAnime(let id):
            return "api/series/\(id)"
        case .episodeWatched(let id):
            return "animelist/edit/\(id)"
        case .getSubscriptionData:
            return "users/profile"
        case .getNewEpisodes(let page):
            return "page/\(String(page))"
        case .getRatingsAnimeList:
            return ""
        }
    }
}

enum ErrorOfRequest: Error {
    case noBody
    case noData
    case noUserId
    case noSessionId
    case noNeededCookie
}

class Networker {
    private init(){}
    
    static let shared = Networker()
    
    let domain = "smotret-anime.com"
    
    func setSessionData() {
        setCookie(name: "PHPSESSID", value: Session.instance.sessionId)
        setCookie(name: Session.instance.sessionDataName, value: Session.instance.sessionDataValue)
    }
    
    func login(email: String, password: String, completion: @escaping (Result<SessionData?, Error>) -> Void) {
        
        guard let url = getUrl(method: .login) else { return }
        let uuid = UUID().uuidString
        setCookie(name: "csrf", value: uuid)
        
        let headers: HTTPHeaders = [
            "User-Agent": "anime-365-tvOS",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters = [
            "LoginForm[username]": email,
            "LoginForm[password]": password,
            "dynpage": "1",
            "csrf": uuid
        ]
        
        AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: .urlEncodedForm,
            headers: headers).response { [weak self] response in
                switch response.result {
                case let .success(dataOfResponse):
                    guard let data = dataOfResponse else {
                        completion(.failure(ErrorOfRequest.noData))
                        return
                    }
                    
                    guard let cookieData = response.response?.allHeaderFields.first(where: {$0.key.description == "Set-Cookie"}) else {
                        completion(.failure(ErrorOfRequest.noNeededCookie))
                        return
                    }
                    guard let cookieValueString = cookieData.value as? String else {
                        completion(.failure(ErrorOfRequest.noNeededCookie))
                        return
                    }
                    
                    guard let sessionCookiedData = self?.getSessionDataFromCookie(cookie: cookieValueString) else {
                        completion(.failure(ErrorOfRequest.noNeededCookie))
                        return
                    }
                    
                    guard let body = String(data: data, encoding: .utf8) else {
                        completion(.failure(ErrorOfRequest.noBody))
                        return
                    }
                    guard let userId = self?.getUserId(from: body) else {
                        completion(.failure(ErrorOfRequest.noUserId))
                        return
                    }
                    guard let sessionId = self?.getSessionId(from: body) else {
                        completion(.failure(ErrorOfRequest.noSessionId))
                        return
                    }
                    
                    completion(.success(SessionData(
                        sessionId: sessionId,
                        userId: userId,
                        sessionDataName: sessionCookiedData.0,
                        sessionDataValue: sessionCookiedData.1)))
                    
                case let .failure(error):
                    completion(.failure(error))
                }
        }
    }
    
    private func sendGetRequestJSON<TypeOfResponse: Decodable>(
        url: String,
        type: TypeOfResponse.Type,
        completion: @escaping (TypeOfResponse?)->()) {
        
        let headers: HTTPHeaders = ["User-Agent": "anime-365-tvOS"]
        AF.request(url, method: .get, headers: headers).responseDecodable(of: TypeOfResponse.self) { [weak self] response in
            if response.error != nil {
                guard let isContain = String(data: response.data!, encoding: .utf8)?.contains("You should login first") else { return }
                if isContain {
                    self?.logout()
                }
            }
            guard let result = response.value else { return }
            completion(result)
        }
    }
    
    private func sendGetRequestJSONAsync<TypeOfResponse: Decodable>(url: String, type: TypeOfResponse.Type) async -> TypeOfResponse? {
        
        let headers: HTTPHeaders = ["User-Agent": "anime-365-tvOS"]
        let response = await AF.request(url, method: .get, headers: headers)
            .serializingDecodable(TypeOfResponse.self)
            .response
        
        if response.error != nil {
           return nil
        }
        guard let result = response.value else { return nil }
        return result
    }
    
    private func sendGetRequest(
        url: String,
        completion: @escaping (String)->()) {
        
        let headers: HTTPHeaders = ["User-Agent": "anime-365-tvOS"]
        AF.request(url, method: .get, headers: headers).response { [weak self] response in
            if response.error != nil {
                guard let data = response.data else { return }
                guard let isContain = String(data: data, encoding: .utf8)?.contains("You should login first") else { return }
                if isContain {
                    self?.logout()
                }
            }
            guard let bodyString = String(data: response.data!, encoding: .utf8) else { return }
            if bodyString.contains("Чтобы им пользоваться, нужно войти на сайт.") {
                self?.logout()
            }
            completion(bodyString)
        }
    }
    
    private func sendGetRequestAsync(url: String) async -> String? {
        
        let headers: HTTPHeaders = ["User-Agent": "anime-365-tvOS"]
        let response = await AF.request(url, method: .get, headers: headers)
            .serializingData()
            .response
        
        if response.error != nil {
           return nil
        }
        guard let responseData = response.data else { return nil }
        guard let body = String(data: responseData, encoding: .utf8) else { return nil }
        
        return body
    }
        
    private func getUrl(method: Methods, params: [String: String] = [String: String]()) -> String? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = domain
        urlComponents.path = "/\(method.value)"
        urlComponents.queryItems = []
        
        for (key, value) in params {
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
                
        return urlComponents.string
    }
    
    private func setCookie(name: String, value: String) {
        let cookieProps = [
            HTTPCookiePropertyKey.domain: domain,
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: name,
            HTTPCookiePropertyKey.value: value
        ]
        guard let cookie = HTTPCookie(properties: cookieProps) else { return }
        AF.session.configuration.httpCookieStorage?.setCookie(cookie)
    }
    
    private func getUserId(from body: String) -> String? {
        
        let userIdData = body.groups(for: "ID аккаунта: ([0-9]*)</p>")
        guard let userId = userIdData.first?.last else { return nil }
        return userId
    }
    
    private func getSessionDataFromCookie(cookie: String) -> (String, String)? {
        var cookieData = cookie.groups(for: "(\\w{32})=([^deleted][^;]+)")
        guard let sessionDataValue = cookieData[0].popLast() else { return nil }
        guard let sessionDataName = cookieData[0].popLast() else { return nil }
        
        return (sessionDataName, sessionDataValue)
        
    }
    
    private func getSessionId(from body: String) -> String? {
        let sessionIdCookie = HTTPCookieStorage.shared.cookies?.first{ [weak self] in
            $0.domain == self?.domain && $0.name == "PHPSESSID"
        }
        
        guard let sessionId = sessionIdCookie?.value else { return nil }
        return sessionId
    }
    
    private func logout() {
        Session.setSessionData(sessionData: SessionData(sessionId: "", userId: "", sessionDataName: "", sessionDataValue: ""))
        exit(1)
    }
}

extension Networker {
    
    func getAnimeFromSite(searchString: String, uuid: UUID? = nil, offset: Int = 0, completion: @escaping ([SiteAnime], UUID?) -> Void) {
        
        var params = ["limit": "20"]
        if !searchString.isEmpty {
            params["query"] = searchString
        }
        if offset != 0 {
            params["offset"] = String(offset)
        }
        
        guard let url = getUrl(method: .getSerieses, params: params) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<[SiteAnime]>.self) { result in
            guard let data = result?.data else { return }
            completion(data, uuid)
        }
    }
}

extension Networker {
    func getEpisodeWithTranslations(episodeId: Int, completion: @escaping (EpisodeWithTranslations) -> Void) {
        
        guard let url = getUrl(method: .getEpisodeWithTranslation(id: String(episodeId))) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<SiteEpisodeWithTranslations>.self) { result in
            guard let data = result?.data else { return }
            var translations = [Translation]()
            data.translations.forEach({ siteTranslation in
                translations.append(Translation(
                    id: siteTranslation.id,
                    type: .init(type: siteTranslation.type),
                    typeKind: siteTranslation.typeKind,
                    typeLang: siteTranslation.typeLang,
                    author: siteTranslation.authorsSummary,
                    width: siteTranslation.width,
                    height: siteTranslation.height))})
            
            completion(EpisodeWithTranslations(
                id: data.id,
                episodeFull: data.episodeFull,
                episodeInt: Int(data.episodeInt) ?? 0,
                episodeType: data.episodeType,
                isActive: data.isActive == 1 ? true : false,
                translations: translations,
                seriesId: data.seriesId))
        }
    }
    
    func getEpisodeWithTranslationsAsync(episodeId: Int, applyUserSettings: Bool = true) async -> EpisodeWithTranslations? {
        guard let url = getUrl(method: .getEpisodeWithTranslation(id: String(episodeId))) else { return nil }
        let result = await sendGetRequestJSONAsync(url: url, type: SiteResponse<SiteEpisodeWithTranslations>.self)
        guard let data = result?.data else { return nil }
        
        
        let episode = EpisodeWithTranslations(
            id: data.id,
            episodeFull: data.episodeFull,
            episodeInt: Int(data.episodeInt) ?? 0,
            episodeType: data.episodeType,
            isActive: data.isActive == 1 ? true : false,
            translations: data.translations.map({Translation(
                id: $0.id,
                type: .init(type: $0.type),
                typeKind: $0.typeKind,
                typeLang: $0.typeLang,
                author: $0.authorsSummary,
                width: $0.width,
                height: $0.height)}),
            seriesId: data.seriesId)
        
        if !applyUserSettings {
            return episode
        }
        
        if Session.instance.settings.showNewEpisodesOnlyWithComfortTypeOfTranslation,
           let typeOfTranslation = Session.instance.settings.comfortTypeOfTranslation  {
            
            let neededTranslation = episode.translations.first(where: {$0.type == typeOfTranslation})
            if neededTranslation == nil {
                return nil
            }
        }
        
        return episode
        
    }
    
}

extension Networker {
    func getTranslationData(translationId: Int, completion: @escaping (SiteTranslationData) -> Void) {
        guard let url = getUrl(method: .getTranslationData(id: String(translationId))) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<SiteTranslationData>.self) { result in
            guard let data = result?.data else { return }
            completion(data)
        }
    }
}

extension Networker {
    func getEpisoodesToWath(completion: @escaping ([[String: String]]) -> Void) {
        guard let url = getUrl(method: .main) else { return }
        sendGetRequest(url: url) { body in
            let doc = try? SwiftSoup.parse(body)
            let allDiv = try? doc?.select("div")
            let animeList = allDiv?.filter({ element in
                let id = try? element.attr("id")
                return id == "m-index-personal-episodes"
            })
            
            var episodesData: [String] = [String]()
            animeList?.forEach({ element in
                let link = try? element.select("h5").select("a")
                link?.forEach({ linkElement in
                    if let url = try? linkElement.attr("href") {
                        episodesData.append(url)
                    }
                })
            })
            var episodes = [[String: String]]()
            for url in episodesData {
                var partOfData = url.groups(for: "-([0-9]*)/.*seriya-([0-9]*)")
                let episodeId = partOfData[0].popLast()
                let animeId = partOfData[0].popLast()
                episodes.append([animeId!: episodeId!])
            }
            completion(episodes)
        }
    }
}

extension Networker {
    func getAnime(id: String, completion: @escaping (Anime) -> Void) {
        guard let url = getUrl(method: .getAnime(id: id)) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<SiteAnime>.self) { result in
            guard let data = result?.data else { return }
            let anime = Anime(from: data)
            completion(anime)
        }
    }
    
    func getAnimeAsync(id: String) async -> Anime? {
        guard let url = getUrl(method: .getAnime(id: id)) else { return nil }
        let result = await sendGetRequestJSONAsync(url: url, type: SiteResponse<SiteAnime>.self)
        guard let data = result?.data else { return nil }
        return Anime(from: data)
    }
}

extension Networker {
    func episodeWatched(animeId: String, episodeNumber: Int) {
        guard let url = getUrl(method: .episodeWatched(id: animeId), params: ["mode": "mini"]) else { return }
        
        let uuid = UUID().uuidString
        setCookie(name: "csrf", value: uuid)
        
        let headers: HTTPHeaders = [
            "User-Agent": "anime-365-tvOS",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters = [
            "UsersRates[episodes]": "\(episodeNumber)",
            "csrf": uuid
        ]
        
        AF.request(
            url,
            method: .post,
            parameters: parameters,
            encoder: .urlEncodedForm,
            headers: headers).response { response in
                switch response.result {
                case let .failure(error):
                    print(error)
                default: return
                }
        }
    }
}

extension Networker {
    func getNewEpisodesData(episodes: [[String: String]]) async -> [(Anime, EpisodeWithTranslations)] {
        
        var newEpisodesData = [(Anime, EpisodeWithTranslations)]()
        
        for item in episodes {
            
            guard let animeId = item.keys.first else { continue }
            guard let episodeId = item.values.first else { continue }
            guard let data = await getNewEpisodeData(episodeId: episodeId, animeId: animeId) else { continue }
            newEpisodesData.append(data)
        }
        
        return newEpisodesData
    }
    
    func getNewEpisodeData(episodeId: String, animeId: String) async -> (Anime, EpisodeWithTranslations)? {
        guard let episodeIdInt = Int(episodeId) else { return nil }
        
        async let episodeData = getEpisodeWithTranslationsAsync(episodeId: episodeIdInt)
        async let animeData = getAnimeAsync(id: animeId)

        let result = await (animeData, episodeData)
        guard let anime = result.0 else { return nil }
        guard let episode = result.1 else { return nil }
        
        return (anime, episode)
    }
}

extension Networker {
    func getSubscriptionData() async -> (String, String)? {
        guard let url = getUrl(method: .getSubscriptionData) else { return nil }
        guard let body = await sendGetRequestAsync(url: url) else { return nil }
        
        guard let doc = try? SwiftSoup.parse(body) else { return nil }
        guard let elementsWithH2 = try? doc.select("h2") else { return nil }
        guard let element = getElementWithSubscriptionData(elements: elementsWithH2) else { return nil }
        guard var regData = try? element.html().groups(for: "<p>(\\w*). ([\\w0-2 \\W]*).<br>") else { return nil }
        
        guard let desc = regData[0].popLast() else { return nil }
        guard let status = regData[0].popLast() else { return nil }
        
        return (status, desc)
    }
    
    private func getElementWithSubscriptionData(elements: Elements) -> Element? {
        
        for item in elements {
            guard let contain = try? item.text().contains("Подписка") else { continue }
            if contain {
                return item.parent()
            }
        }
        
        return nil
    }
}

extension Networker {
    func getNewEpisodesAsync(pageNumber: Int) async -> [NewEpisodesData] {
        
        var episodesData = [NewEpisodesData]()
        var siteEpisodesData: [SiteNewEpisodesData] = [SiteNewEpisodesData]()

        guard let url = getUrl(method: .getNewEpisodes(page: pageNumber)) else { return episodesData }
        guard let body = await sendGetRequestAsync(url: url) else { return episodesData }
        guard let doc = try? SwiftSoup.parse(body) else { return episodesData }
        guard let allEpisodesBlock = try? doc.select("div[id=m-index-recent-episodes]") else { return episodesData }
        if allEpisodesBlock.isEmpty() { return episodesData }
        guard let data = try? allEpisodesBlock.select("div[class=m-new-episodes collection with-header z-depth-1]") else { return episodesData }
        
        for item in data {
            guard let headerName = try? item.select("div.collection-header").select("h3").text() else { continue }
            guard let date = headerName.groups(for: "([0-9]{2}.[0-9]{2}.[0-9]{4})").last?.last else { continue }
            
            var newEpisodesData = SiteNewEpisodesData(date: date, espisodes: [SiteShortEpisodeData]())
            
            guard let episodesBlock = try? item.select("div[class=m-new-episode collection-item avatar]") else { continue }
            for episodeBlock in episodesBlock {
                guard let linkBlock = try? episodeBlock.select("a[href]") else { continue }
                guard let link = try? linkBlock.first()?.attr("href") else { continue }
                var partOfData = link.groups(for: "-([0-9]*)/.*seriya-([0-9]*)")
                guard let episodeId = partOfData[0].popLast() else { continue }
                guard let animeId = partOfData[0].popLast() else { continue }
                newEpisodesData.espisodes.append(SiteShortEpisodeData(animeId: animeId, episodeId: episodeId))
            }
            siteEpisodesData.append(newEpisodesData)
        }
        
        for itemDate in siteEpisodesData {
            var data = NewEpisodesData(date: itemDate.date, episodes: [ShortEpisodeData]())
            guard let episodes = try? await getShortEpisodesData(siteEpisodes: itemDate.espisodes) else { continue }
            let finalEpisodes = itemDate.espisodes.compactMap { episode in
                episodes.first(where: {String($0.episode.id) == episode.episodeId})
            }
            data.episodes = finalEpisodes

            episodesData.append(data)
        }
        return episodesData
    }
    
    func getShortEpisodesData(siteEpisodes: [SiteShortEpisodeData]) async throws -> [ShortEpisodeData] {
        return try await withThrowingTaskGroup(of: ShortEpisodeData.self) { group in
            var episodes = [ShortEpisodeData]()
            
            for item in siteEpisodes {
                group.addTask{
                    return try await self.getShortEpisodeData(animeId: item.animeId, episodeId: item.episodeId)
                }
            }
            for try await episode in group {
                episodes.append(episode)
            }
            return episodes
        }
    }
    
    private func getShortEpisodeData(animeId: String, episodeId: String) async throws -> ShortEpisodeData {
        guard let animeData = await getAnimeAsync(id: animeId) else { throw ErrorOfRequest.noData }
        guard let episode = animeData.episodes?.first(where: {String($0.id) == episodeId}) else { throw ErrorOfRequest.noData }
        return ShortEpisodeData(anime: animeData, episode: episode)
    }
    
}

extension Networker {
    func getRatingsAnimeList(pageNumber: Int) async -> [Anime] {
        
        var animes = [Anime]()
        var animeIds: [String] = [String]()
        
        guard let url = getUrl(method: .getRatingsAnimeList, params: ["pageT": String(pageNumber)]) else { return animes }
        guard let body = await sendGetRequestAsync(url: url) else { return animes }
        guard let doc = try? SwiftSoup.parse(body) else { return animes }
        guard let allEpisodesBlock = try? doc.select("div[id=m-index-top-airing]") else { return animes }
        if allEpisodesBlock.isEmpty() { return animes }
        guard let data = try? allEpisodesBlock.select("h5[class=line-1]") else { return animes }
        
        for item in data {
            guard let linkBlock = try? item.select("a[href]").attr("href") else { continue }
            var partOfData = linkBlock.groups(for: "-([0-9]*)$")
            guard let animeId = partOfData[0].popLast() else { continue }
            animeIds.append(animeId)
        }
        guard let notSortedAnimes = try? await getListOfAnime(siteAnimes: animeIds) else { return animes }
        
        animeIds.forEach { id in
            guard let anime = notSortedAnimes.first(where: {String($0.id) == id}) else { return }
            animes.append(anime)
        }
        
        return animes
    }
    
    func getListOfAnime(siteAnimes: [String]) async throws -> [Anime] {
        return try await withThrowingTaskGroup(of: Anime.self) { group in
            var animes = [Anime]()
            
            for item in siteAnimes {
                group.addTask{
                    guard let anime = await self.getAnimeAsync(id: item) else { throw ErrorOfRequest.noData }
                    return anime
                }
            }
            
            for try await anime in group {
                animes.append(anime)
            }
            return animes
        }
    }
    
}
