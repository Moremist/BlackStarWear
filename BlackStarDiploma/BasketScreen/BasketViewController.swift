import UIKit
import ReactiveKit
import Bond
import Kingfisher

class BasketViewController: UIViewController {


    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var basketTableView: UITableView!
    @IBOutlet weak var emptyStack: UIStackView!
    
    var basketItems = MutableObservableArray<WearWithOffer>([])

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        buyButtonConfigure()
        basketIsEmptyCheck()
        
        basketItems.bind(to: basketTableView) { (data, indexPath, tableView) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "basketCell") as! BasketTableViewCell
            let imageUrl = URL(string: "https://blackstarshop.ru/" + data[indexPath.row].item.mainImage)
            cell.itemNameLabel.text = data[indexPath.row].item.name
            cell.itemOfferLabel.text = data[indexPath.row].offer
            cell.itemPriceLabel.text = data[indexPath.row].item.price
            cell.itemImage.kf.setImage(with: imageUrl)
            return cell
        }
    }
    
    func add(item: WearWithOffer) {
        basketItems.append(item)
        basketIsEmptyCheck()
        print("qwe")
    }
    
    fileprivate func buyButtonConfigure() {
        buyButton.layer.cornerRadius = 10
        buyButton.clipsToBounds = true
    }
    
    fileprivate func basketIsEmptyCheck() {
        if basketItems.isEmpty {
            buyButton.isEnabled = false
            buyButton.backgroundColor = .gray
            basketTableView.alpha = 0
        } else {
            buyButton.isEnabled = true
            buyButton.backgroundColor = .black
            basketTableView.alpha = 1
        }
    }
}
