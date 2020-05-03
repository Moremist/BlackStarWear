import Foundation

//MARK: - Main category
struct Category: Codable {
    let name, sortOrder, image, iconImage: String
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
}

//MARK: - TypeEnum
enum TypeEnum: String, Codable {
    case category = "Category"
    case collection = "Collection"
}

//MARK: - Wears
struct Wear: Decodable {
    var name, englishName, sortOrder, article, description, colorName, colorImageURL, mainImage, price : String
    var productImages: [WearImage]
    var offers : [Offers]
}

struct WearImage: Decodable {
    var imageURL, sortOrder: String
}

struct Offers: Decodable {
    var size : String
}
