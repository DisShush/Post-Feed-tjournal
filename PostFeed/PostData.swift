//
//  PostData.swift
//  PostFeed
//
//  Created by Владислав Шушпанов on 24.08.2021.
//

import Foundation

// MARK: - PurpleData
struct PostData: Codable {
    var result: Result
}

// MARK: - Result
struct Result: Codable {
    var items: [ResultItem]
    var lastId: Int
    var lastSortingValue: Int
}

// MARK: - ResultItem
struct ResultItem: Codable {
    let data: ItemData
}

// MARK: - ItemData
struct ItemData: Codable {
    let author: Author
    let subsite: Author
    let counters: Counters
    let likes: Likes
    let title: String
    let blocks: [Block]
   
}

// MARK: - Author
struct Author: Codable {
    let name: String
    let avatar: Avatar
}

// MARK: - Avatar
struct Avatar: Codable {
    let data: AvatarData
}

// MARK: - AvatarData
struct AvatarData: Codable {
    let uuid: String
}

// MARK: - Block
struct Block: Codable {
    let type: LinkType
    let data: BlockData
}

// MARK: - BlockData
struct BlockData: Codable {
    let text: String?
    let items: ItemsUnion?

}
struct ItemItem: Codable {
    let image: Avatar
}

enum ItemsUnion: Codable {
    case itemsClass(ItemsClass)
    case unionArray([ItemUnion])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([ItemUnion].self) {
            self = .unionArray(x)
            return
        }
        if let x = try? container.decode(ItemsClass.self) {
            self = .itemsClass(x)
            return
        }
        throw DecodingError.typeMismatch(ItemsUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ItemsUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .itemsClass(let x):
            try container.encode(x)
        case .unionArray(let x):
            try container.encode(x)
        }
    }
}

enum ItemUnion: Codable {
    case itemItem(ItemItem)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(ItemItem.self) {
            self = .itemItem(x)
            return
        }
        throw DecodingError.typeMismatch(ItemUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ItemUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .itemItem(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

struct ItemsClass: Codable {
    let a16298116490, a16298116491, a16298116582, a16298103340: String?
}

enum LinkType: String, Codable {
    case delimiter = "delimiter"
    case header = "header"
    case incut = "incut"
    case link = "link"
    case list = "list"
    case media = "media"
    case quiz = "quiz"
    case quote = "quote"
    case text = "text"
    case tweet = "tweet"
    case video = "video"
    case warning = "warning"
    case telegram = "telegram"

}

// MARK: - Counters
struct Counters: Codable {
    let comments: Int
}

// MARK: - Likes
struct Likes: Codable {
    let summ, counter, isLiked: Int
    let isHidden: Bool
}
