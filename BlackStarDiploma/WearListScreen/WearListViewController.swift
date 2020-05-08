import UIKit
import Alamofire
import Kingfisher

class WearListViewController: UIViewController {
    
    var subcategoryID: ID?
    var wearListArray = Array<Wear>([])
    var subCatName : String?
    @IBOutlet weak var wearListCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        navigationItem.title = subCatName
        
        loadWearList()
        configureWearListController()

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

}

//MARK: - loadWearList
extension WearListViewController {
    func loadWearList(){
        let url = BlackStarURLs().getProductURLFromID(subcategoryID: subcategoryID!)!
        Network().fetchArrayFromUrl(url: url, type: Wear.self) { (data) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.wearListArray = data
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
        cell.wearNameLabel.text = wearListArray[indexPath.row].name.replacingOccurrences(of: "&amp;", with: " ")
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
                vc.defaultImageUrlString = self.wearListArray[indexPath.row].mainImage
                vc.categoryName = self.subCatName
                vc.imagesURLs = self.wearListArray[indexPath.row].productImages
                vc.offers = self.wearListArray[indexPath.row].offers
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}
