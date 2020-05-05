import UIKit
import Alamofire
//import Bond
import Kingfisher
//import ReactiveKit

class WearListViewController: UIViewController {
    
    var subcategoryID: ID?
    var wearListArray = Array<Wear>([])
    @IBOutlet weak var wearListCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWearList()
        configureWearListController()
        
//        wearCollectionViewBinding()
//        wearCollectionViewSelectedRowBinding()
        
        wearListCollectionView.delegate = self
        wearListCollectionView.dataSource = self
        

    }

//MARK: - configureWearListController
    fileprivate func configureWearListController() {
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
        overrideUserInterfaceStyle = .light
    }
    
//MARK: - wearCollectionViewBinding
//    fileprivate func wearCollectionViewBinding() {
//        wearListArray.bind(to: wearListCollectionView) { (data, index, collectView) -> UICollectionViewCell in
//
//            let cell = collectView.dequeueReusableCell(withReuseIdentifier: "wearCell", for: index) as! WearCollectionViewCell
//            cell.wearNameLabel.text = data[index.row].name
//            cell.wearPriceLabel.text = String(data[index.row].price.split(separator: ".")[0]) + "₽"
//            let urlImage = URL(string: "https://blackstarshop.ru/" + data[index.row].mainImage)
//            cell.wearImageView.kf.setImage(with: urlImage)
//            cell.wearImageView.contentMode = .scaleAspectFit
//            cell.wearImageView.layer.cornerRadius = 20
//            cell.wearImageView.clipsToBounds = true
//            self.activityIndicator.alpha = 0
//            self.activityIndicator.stopAnimating()
//            return cell
//        }.dispose(in: disposedBag)
//    }
    
//MARK: - wearCollectionViewSelectedRowBinding
//    fileprivate func wearCollectionViewSelectedRowBinding() {
//        wearListCollectionView.reactive.selectedItemIndexPath.observeNext { (indexPath) in
//            self.performSegueWithIdentifier(identifier: "toWearDetail", sender: nil) { (segue) in
//                if let vc = segue.destination as? WearDetailViewController {
//                    vc.wear = self.wearListArray[indexPath.row]
//                }
//            }
//        }.dispose(in: disposedBag)
//    }
    
}

//MARK: - loadWearList
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
            DispatchQueue.main.async {
                self.wearListCollectionView.reloadData()
            }
        }
    }
}

extension WearListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wearListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "wearCell", for: indexPath) as! WearCollectionViewCell
        cell.wearNameLabel.text = wearListArray[indexPath.row].name
        cell.wearPriceLabel.text = String(wearListArray[indexPath.row].price.split(separator: ".")[0]) + "₽"
        let urlImage = URL(string: "https://blackstarshop.ru/" + (wearListArray[indexPath.row].mainImage))
        cell.wearImageView.kf.setImage(with: urlImage)
        cell.wearImageView.contentMode = .scaleAspectFit
        cell.wearImageView.layer.cornerRadius = 20
        cell.wearImageView.clipsToBounds = true
        self.activityIndicator.alpha = 0
        self.activityIndicator.stopAnimating()
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegueWithIdentifier(identifier: "toWearDetail", sender: nil) { (segue) in
            if let vc = segue.destination as? WearDetailViewController {
                vc.wear = self.wearListArray[indexPath.row]
            }
        }
    }
    
    
}
