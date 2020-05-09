import Foundation

//MARK: - BlackStarURLs class
class BlackStarURLs {
    let defaultBSString: String = "https://blackstarshop.ru/"
    let categoriesBSString: String = "https://blackstarshop.ru/index.php?route=api/v1/categories"
    let productBSString: String = "https://blackstarshop.ru/index.php?route=api/v1/products&cat_id="
    
    func getCatURL() -> URL? {
        guard let url = URL(string: categoriesBSString) else { return nil}
        return url
    }
    
    func getImageURL(imageUrlString: String) -> URL? {
        guard let url = URL(string: defaultBSString + imageUrlString) else { return nil }
        return url
    }
    
    func getProductURLFromID(subcategoryID: ID) -> URL? {
        guard let url = URL(string: productBSString + subcategoryID.valueString()) else {
            return nil
        }
        return url
    }
}
