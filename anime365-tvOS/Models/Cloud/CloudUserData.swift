//
//  CloudUserData.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 06.09.2022.
//

import Foundation

struct CloudUserData: Codable {
    var id: String
    var settings: CloudUserSettings
}

extension CloudUserData {
    init() {
        self.id = Session.instance.userId
        self.settings = CloudUserSettings()
    }
}
