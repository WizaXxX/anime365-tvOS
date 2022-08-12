//
//  Session.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 12.08.2022.
//

import Foundation

class Session {
    private init() {}
    
    static let instance = Session()
    
    var sessionId: String = ""
    var userId: String = ""
    
}
