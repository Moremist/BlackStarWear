import Foundation
import Alamofire


class Network {
    func fetchArrayFromUrl<T: Decodable>(url: URL, type: T.Type,completion: @escaping ([T]?) -> Void){
 
        AF.request(url).validate().responseJSON { (response) in
            guard let data = try? JSONDecoder().decode([String: T].self, from: response.data!) else {
                print("Error while decode")
                return
            }
            switch type {
            case is Category.Type:
                let array = Array(data.values) as! [Category]
                let sortedAndFilteredArray = array.sorted { (c1, c2) -> Bool in
                    return c1.sortOrder < c2.sortOrder
                }.filter { !$0.subcategories.isEmpty}
                completion(sortedAndFilteredArray as? [T])
            case is Wear.Type:
                let array = Array(data.values) as! [Wear]
                let sortedAndFilteredArray = array.sorted { (w1, w2) -> Bool in
                    return w1.sortOrder < w2.sortOrder
                }
                completion(sortedAndFilteredArray as? [T])
            default:
                print("Decoding type is incorrect")
                completion(nil)
            }
            completion(nil)
        }
    }
}
