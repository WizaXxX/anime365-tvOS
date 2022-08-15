//
//  SiteResult.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 14.08.2022.
//

import Foundation

struct SiteResponse<T: Decodable>: Decodable {
    let data: T
}
