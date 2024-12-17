//
//  WikiData.swift
//  FlowerPicker
//
//  Created by Jessica Parsons on 12/16/24.
//

import Foundation

struct WikiData: Codable {
    let query: Query
}

struct Query: Codable {
    let pageids: [String]
    let pages: [String: Details]
}

struct Details: Codable {
    let pageid: Int
    let title: String
    let extract: String
}
