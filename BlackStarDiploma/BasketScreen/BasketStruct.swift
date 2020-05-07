import Foundation
import RealmSwift

class Basket : Object {
    static let shared = Basket()
    var basketArray = Array<WearWithOffer>([])
}
