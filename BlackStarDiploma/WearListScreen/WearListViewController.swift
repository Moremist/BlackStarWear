import UIKit
import Alamofire
import Bond
import Kingfisher
import ReactiveKit

class WearListViewController: UIViewController {
    
    var subcategoryID: ID?
    var wearListArray = MutableObservableArray<Wear>([])
    @IBOutlet weak var wearListCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWearList()
        configureWearListController()
        wearCollectionViewBinding().dispose(in: disposedBag)
        wearListCollectionView.reactive.selectedItemIndexPath.observeNext { (indexPath) in
            self.performSegueWithIdentifier(identifier: "toWearDetail", sender: nil) { (segue) in
                if let vc = segue.destination as? WearDetailViewController {
                    vc.wear = self.wearListArray[indexPath.row]
                }
            }
        }.dispose(in: disposedBag)
    }
    
    fileprivate func configureWearListController() {
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
        overrideUserInterfaceStyle = .light
    }
    
    fileprivate func wearCollectionViewBinding() -> Disposable {
        return wearListArray.bind(to: wearListCollectionView) { (data, index, collectView) -> UICollectionViewCell in

            let cell = collectView.dequeueReusableCell(withReuseIdentifier: "wearCell", for: index) as! WearCollectionViewCell
            cell.wearNameLabel.text = data[index.row].name
            cell.wearPriceLabel.text = String(data[index.row].price.split(separator: ".")[0]) + "₽"
            let urlImage = URL(string: "https://blackstarshop.ru/" + data[index.row].mainImage)
            cell.wearImageView.kf.setImage(with: urlImage)
            cell.wearImageView.contentMode = .scaleAspectFit
            cell.wearImageView.layer.cornerRadius = 20
            cell.wearImageView.clipsToBounds = true
            self.activityIndicator.alpha = 0
            self.activityIndicator.stopAnimating()
            return cell
        }
    }
}


extension WearListViewController {
    func loadWearList(){
        guard let catID = subcategoryID?.valueString() else { return }
        AF.request("https://blackstarshop.ru/index.php?route=api/v1/products&cat_id=" + catID ).validate().responseJSON { (response) in
            guard let wears = try? JSONDecoder().decode([String: Wear].self, from: response.data!) else {
                print("Error while decode")
                return
            }
            for wear in wears {
                self.wearListArray.append(wear.value)
            }
        }
    }
}

