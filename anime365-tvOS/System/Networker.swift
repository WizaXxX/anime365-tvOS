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
        }
    }
}

enum ErrorOfRequest: Error {
    case noBody
    case noData
    case noUserId
    case noSessionId
}

class Networker {
    private init(){}
    
    static let shared = Networker()
    
    let domain = "smotret-anime.com"
    
    func setSessionId() {
        setCookie(name: "PHPSESSID", value: Session.instance.sessionId)
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
                    
                    completion(.success(SessionData(sessionId: sessionId, userId: userId)))
                    
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
                guard let isContain = String(data: response.data!, encoding: .utf8)?.contains("You should login first") else { return }
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
    
    private func getSessionId(from body: String) -> String? {
        let sessionIdCookie = HTTPCookieStorage.shared.cookies?.first{ [weak self] in
            $0.domain == self?.domain && $0.name == "PHPSESSID"
        }
        
        guard let sessionId = sessionIdCookie?.value else { return nil }
        return sessionId
    }
    
    private func logout() {
        let wrapper = Session.instance.getKeyChainWrapper()
        wrapper.set("", forKey: "sessionId")
        exit(1)
    }
}

extension Networker {
    
    func getAnimeFromSite(searchString: String, completion: @escaping ([SiteAnime]) -> Void) {
        
        var params = ["limit": "20"]
        if !searchString.isEmpty {
            params["query"] = searchString
        }
        
        guard let url = getUrl(method: .getSerieses, params: params) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<[SiteAnime]>.self) { result in
            guard let data = result?.data else { return }
            completion(data)
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
                translations: translations))
        }
    }
    
    func getEpisodeWithTranslationsAsync(episodeId: Int) async -> EpisodeWithTranslations? {
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
                height: $0.height)}))
        
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
            completion(Anime(
                id: data.id,
                title: data.title,
                posterUrlSmall: ImageFromInternet(url: data.posterUrlSmall),
                posterUrl: ImageFromInternet(url: data.posterUrl),
                titles: data.titles))
        }
    }
    
    func getAnimeAsync(id: String) async -> Anime? {
        guard let url = getUrl(method: .getAnime(id: id)) else { return nil }
        let result = await sendGetRequestJSONAsync(url: url, type: SiteResponse<SiteAnime>.self)
        guard let data = result?.data else { return nil }
        return Anime(
            id: data.id,
            title: data.title,
            posterUrlSmall: ImageFromInternet(url: data.posterUrlSmall),
            posterUrl: ImageFromInternet(url: data.posterUrl),
            titles: data.titles)
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
