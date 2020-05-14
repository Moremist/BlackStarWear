import UIKit
import Kingfisher

class WearDetailViewController: UIViewController {
    
    //MARK: - variables
    var wear : Wear?
    var imagesURLs = Array<WearImage>([])
    var offers = Array<Offers>([])
    var defaultImageUrlString: String!
    var categoryName: String?
    var basketVC: BasketViewController?
    
    //MARK: - outlets
    @IBOutlet weak var imagesCollectView: UICollectionView!
    @IBOutlet weak var wearPriceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var wearNameLabel: UILabel!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sizePickerView: UIPickerView!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var purchseViewTrailing: NSLayoutConstraint!
    
    //MARK: - buyButtonPressed
    @IBAction func buyButtonPressed(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        let offer = offers[sizePickerView.selectedRow(inComponent: 0)]
        Basket.shared.basketArray.append(WearWithOffer(item: wear!, offer: offer.size))
        
        buyButton.layer.removeAllAnimations()
        purchaseView.layer.removeAllAnimations()
        
        UIView.animate(withDuration: 0.2,
        animations: {
            self.buyButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
        completion: { _ in
            self.purchseViewTrailing.constant = -100
            UIView.animate(withDuration: 0.2) {
                self.buyButton.transform = CGAffineTransform.identity
                self.view.layoutIfNeeded()
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.purchseViewTrailing.constant = -200
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        navigationItem.backBarButtonItem?.title = categoryName
        
        pageControll.numberOfPages = imagesURLs.count
        if imagesURLs.isEmpty {
            imagesURLs.append(WearImage(imageURL: defaultImageUrlString, sortOrder: "1"))
        }
        
        purchaseView.layer.cornerRadius = 20
        purchaseView.clipsToBounds = true
        purchseViewTrailing.constant = -200
        
        imagesCollectView.delegate = self
        imagesCollectView.dataSource = self
        sizePickerView.delegate = self
        sizePickerView.dataSource = self
        if offers.count == 1 {
            self.sizePickerView.alpha = 0.5
        }
        
        wearNameLabel.text = wear?.name.cleanName()
        wearPriceLabel.text = wear?.price.priceInRubles()
        descriptionLabel.text = wear?.description.cleanName()
        height.constant +=  (descriptionLabel.text?.heightWithConstrainedWidth(width: self.view.bounds.width, font: descriptionLabel.font) ?? 0)
        
        buyButtonSettingUp()
         
    }
    
    //MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        basketVC?.basketIsEmptyCheck()
    }
    
//MARK: - buyButtonSettingUp
    fileprivate func buyButtonSettingUp() {
        buyButton.layer.cornerRadius = 10
        buyButton.clipsToBounds = true
    }
}

//MARK: - UICollectionViewDelegate
extension WearDetailViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControll.currentPage = Int(pageNumber)
    }

}

//MARK: - UICollectionViewDataSource
extension WearDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! WearDetailCollectionViewCell
        let imageUrlString = imagesURLs[indexPath.row].imageURL
        let imageURL = BlackStarURLs().getImageURL(imageUrlString: imageUrlString)
        cell.imageView.kf.setImage(with: imageURL)
        cell.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        return cell
    }
    
}

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension WearDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return offers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return offers[row].size
    }
}
