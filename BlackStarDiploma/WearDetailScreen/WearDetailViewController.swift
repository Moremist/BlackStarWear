import UIKit
import ReactiveKit
import Bond
import Kingfisher

class WearDetailViewController: UIViewController {
    
    var wear : Wear?
    var imagesURLs = MutableObservableArray<String>([])
    var dispBag = DisposeBag()
    var sizeArray = MutableObservableArray<String>([])
    var scrollImpactDid = false
    var defaultImageUrlString: String?
    var categoryName: String?
    
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
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        let offer = sizeArray[sizePickerView.selectedRow(inComponent: 0)]
        Basket.shared.basketArray.append(WearWithOffer(item: wear!, offer: offer))
        
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
        
        imagesCollectView.alpha = 0
        overrideUserInterfaceStyle = .light
        navigationItem.backBarButtonItem?.title = categoryName
        
        purchaseView.layer.cornerRadius = 20
        purchaseView.clipsToBounds = true
        purchseViewTrailing.constant = -200
        
        imagesCollectView.delegate = self
        sizePickerView.delegate = self
        sizePickerView.dataSource = self
        
        imagesCollectView.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        imagesCollectView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imagesCollectView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        wearNameLabel.text = wear?.name.cleanName()
        wearPriceLabel.text = wear?.price.priceInRubles()
        descriptionLabel.text = wear?.description.cleanName()
        height.constant += sizePickerView.bounds.height +  (descriptionLabel.text?.heightWithConstrainedWidth(width: self.view.bounds.width, font: descriptionLabel.font) ?? 0)
        
        buyButtonSettingUp()
        prepareImageArray()
        prepareSizeArray()
        configureImagesCollectionView().dispose(in: dispBag)
        
    }
    
//MARK: - preparing arrays
    fileprivate func prepareImageArray(){
        guard let wearImages = wear?.productImages else { return }
        if !(wear?.productImages.isEmpty)! {
            for image in wearImages {
                imagesURLs.append(image.imageURL)
            }
        } else {
            imagesURLs.append(defaultImageUrlString!)
        }
        
        pageControll.numberOfPages = imagesURLs.count
    }
    
    fileprivate func prepareSizeArray(){
        guard let offers = wear?.offers else {
            return
        }
        for size in offers {
            self.sizeArray.append(size.size)
        }
    }
    
//MARK: - configureImagesCollectionView
    fileprivate func configureImagesCollectionView() -> Disposable {
        return imagesURLs.bind(to: imagesCollectView) { (data, indexPath, colletView) -> UICollectionViewCell in
            let cell = colletView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! WearDetailCollectionViewCell
            let imageUrlString = URL(string: "https://blackstarshop.ru/" + data[indexPath.row])
            cell.imageView.kf.setImage(with: imageUrlString)
            cell.imageView.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
            cell.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
            cell.heightAnchor.constraint(equalTo: cell.widthAnchor, multiplier: 1).isActive = true
            colletView.alpha = 1
            return cell
        }
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

//MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension WearDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sizeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sizeArray[row]
    }
}
