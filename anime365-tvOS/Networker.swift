//
//  Networker.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import Foundation
import Alamofire

enum Method: String {
    case login = "users/login"
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
    
    private func getUrl(method: Method) -> String? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = domain
        urlComponents.path = "/\(method.rawValue)"
                
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
