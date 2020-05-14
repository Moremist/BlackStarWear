import Foundation
import UIKit

//MARK: - Main category
struct Category: Codable {
    let name, image, iconImage: String
    let sortOrder: ID
    let iconImageActive: String
    let subcategories: [Subcategory]
}

// MARK: - Subcategory
struct Subcategory: Codable {
    let id: ID
    let iconImage: String
    let sortOrder: ID
    let name: String
    let type: TypeEnum
}

//MARK: - ID
enum ID: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(ID.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ID"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
    func valueString() -> String {
        switch self {
        case .string(let value) :
            return value
        case .integer(let value) :
            return String(value)
        }
    }
    func valueInt() -> Int {
        switch self {
        case .integer(let value):
            return value
        case .string(let value):
            return Int(value)!
        }
    }
}


//MARK: - TypeEnum
enum TypeEnum: String, Codable {
    case category = "Category"
    case collection = "Collection"
}

//MARK: - Wears
struct Wear: Decodable {
    var name, englishName, article, description, colorName, colorImageURL, mainImage, price : String
    var sortOrder: ID
    var productImages: [WearImage]
    var offers : [Offers]
}

struct WearImage: Decodable {
    var imageURL, sortOrder: String
}

struct Offers: Decodable {
    var size : String
}

struct WearWithOffer {
    var item: Wear
    var offer: String
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func priceInRubles() -> String {
        return self.split(separator: ".")[0] + "₽"
    }
    
    func cleanName() -> String {
        return self.replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&amp;", with: " ")
    }
}
