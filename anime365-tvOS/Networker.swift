//
//  Networker.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import Foundation
import Alamofire
import RealmSwift
import SwiftKeychainWrapper

enum Methods {
    case login, getSerieses
    case getEpisodeWithTranslation(id: String)
    case getTranslationData(id: String)
    
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
        AF.request(url, method: .get, headers: headers).responseDecodable(of: TypeOfResponse.self) { response in
            if response.error != nil {
                guard let isContain = String(data: response.data!, encoding: .utf8)?.contains("You should login first") else { return }
                if isContain {
                    KeychainWrapper.standard.set("", forKey: "sessionId")
                    exit(1)
                }
            }
            guard let result = response.value else { return }
            completion(result)
        }
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
}

extension Networker {
    
    func getAnimeFromSite(searchString: String, completion: @escaping () -> Void) {
        
        var params = ["limit": "100"]
        if !searchString.isEmpty {
            params["query"] = searchString
        }
        
        guard let url = getUrl(method: .getSerieses, params: params) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<[SiteAnime]>.self) { [weak self] result in
            guard let data = result?.data else { return }
            self?.writeAnimeToDB(animes: data)
            completion()
        }
    }
    
    private func writeAnimeToDB(animes: [SiteAnime]) {
        guard let realm = try? Realm(configuration: .init(deleteRealmIfMigrationNeeded: true)) else { return }
        
        try? realm.write({
            realm.deleteAll()
            animes.forEach({ anime in
                let realmAnime = RealmAnime()
                realmAnime.id = anime.id
                realmAnime.title = anime.title
                realmAnime.season = anime.season
                realmAnime.year = anime.year
                realmAnime.type = anime.type
                realmAnime.posterUrl = anime.posterUrl
                realmAnime.posterUrlSmall = anime.posterUrlSmall

                anime.episodes?.forEach({ episode in
                    let realmEpisode = RealmEpisode()
                    realmEpisode.id = episode.id
                    if let number = Int(episode.numerOfEpisode) {
                        realmEpisode.numerOfEpisode = number
                    } else {
                        realmEpisode.numerOfEpisode = 0
                    }
                    realmEpisode.tittle = episode.tittle
                    realmAnime.episodes.append(realmEpisode)
                })

                anime.genres?.forEach({ genre in
                    let realmGenre = RealmGenre()
                    realmGenre.id = genre.id
                    realmGenre.tittle = genre.title
                    realmGenre.url = genre.url
                    realmAnime.genres.append(realmGenre)
                })

                realm.add(realmAnime, update: .all)
            })
        })
    }
}

extension Networker {
    
    func getEpisodeWithTranslations(episodeId: Int, completion: @escaping (EpisodeWithTranslations) -> Void) {
        
        guard let url = getUrl(method: .getEpisodeWithTranslation(id: String(episodeId))) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<SiteEpisodeWithTranslations>.self) { [weak self] result in
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
}

extension Networker {
    func getTranslationData(translationId: Int, completion: @escaping (SiteTranslationData) -> Void) {
        guard let url = getUrl(method: .getTranslationData(id: String(translationId))) else { return }
        sendGetRequestJSON(url: url, type: SiteResponse<SiteTranslationData>.self) { [weak self] result in
            guard let data = result?.data else { return }
            completion(data)
        }
    }
}
