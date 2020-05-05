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
    
    @IBOutlet weak var purchasedImage: UIImageView!
    @IBOutlet weak var imagesCollectView: UICollectionView!
    @IBOutlet weak var wearPriceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var wearNameLabel: UILabel!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sizePickerView: UIPickerView!
    
    
//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        purchasedImage.alpha = 0
        imagesCollectView.alpha = 0
        overrideUserInterfaceStyle = .light
        
        imagesCollectView.delegate = self
        sizePickerView.delegate = self
        sizePickerView.dataSource = self
        
        imagesCollectView.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
        imagesCollectView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        imagesCollectView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        wearNameLabel.text = wear?.name
        wearPriceLabel.text = (wear?.price.split(separator: ".")[0])! + "₽"
        descriptionLabel.text = wear?.description.replacingOccurrences(of: "&nbsp;", with: " ")
        height.constant += sizePickerView.bounds.height +  (descriptionLabel.text?.heightWithConstrainedWidth(width: self.view.bounds.width, font: descriptionLabel.font) ?? 0)
        
        buyButtonSettingUp()
        prepareImageArray()
        prepareSizeArray()
        configureImagesCollectionView().dispose(in: dispBag)
        
    }
    
//MARK: - preparing arrays
    fileprivate func prepareImageArray(){
        guard let wearImages = wear?.productImages else { return }
        for image in wearImages {
            imagesURLs.append(image.imageURL)
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
            cell.contentMode = .center
            colletView.alpha = 1
            return cell
        }
    }
//MARK: - buyButtonSettingUp
    fileprivate func buyButtonSettingUp() {
        buyButton.layer.cornerRadius = 10
        buyButton.clipsToBounds = true
        buyButton.addTarget(nil, action: #selector(buyButtonPressed), for: .touchUpInside)
    }
    

//MARK: - buyButtonPressed
    @objc func buyButtonPressed(){
        print(sizeArray[sizePickerView.selectedRow(inComponent: 0)], wear?.article ?? "error")
        buyButton.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2,
        animations: {
            self.buyButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
        completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.buyButton.transform = CGAffineTransform.identity
                self.purchasedImage.alpha = 1
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.2) {
                self.purchasedImage.alpha = 0
            }
        }
    }

}


extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
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
