import UIKit
import Bond
import Alamofire
import Kingfisher
import ReactiveKit

class CategoryViewController: UIViewController {

    var categoryesArray = MutableObservableArray<Category>([])
    let url = "https://blackstarshop.ru/index.php?route=api/v1/categories"
    let dispBag = DisposeBag()
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTableView.delegate = self
        
        
        
        overrideUserInterfaceStyle = .light
        activityIndicator.alpha = 1
        categoryTableView.alpha = 0
        
        activityIndicator.startAnimating()
        
        configureCategoryViewController().dispose(in: dispBag)
        configureSelectedRowTableView().dispose(in: dispBag)
        downloadCategoriesFromJSON(url)
        addNavBarImage()
    }
    
    //MARK: - configureCategoryViewController
    fileprivate func configureCategoryViewController() -> Disposable {
        return categoryesArray.bind(to: categoryTableView, animated: false) { (dataSource, indexPath, tableView) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "catCell") as! CategoryTableViewCell
            cell.categoryCellName.text = dataSource[indexPath.row].name
            let imageString = dataSource[indexPath.row].image
            let imageURL = URL(string: "https://blackstarshop.ru/" + imageString)
            cell.categoryImageView.kf.setImage(with: imageURL)
            cell.categoryImageView.layer.cornerRadius = cell.categoryImageView.frame.width / 2
            cell.categoryImageView.clipsToBounds = true
            cell.categoryImageView.contentMode = .scaleAspectFit
            self.activityIndicator.stopAnimating()
            self.activityIndicator.alpha = 0
            self.categoryTableView.alpha = 1
            return cell
        }
    }
    
    //MARK: - configureSelectedRowTableView
    fileprivate func configureSelectedRowTableView() -> Disposable {
        return categoryTableView.reactive.selectedRowIndexPath.observeNext { (indexPath) in
            self.categoryTableView.deselectRow(at: indexPath, animated: true)
            self.performSegueWithIdentifier(identifier: "toSubCat", sender: nil) { (segue) in
                if let vc = segue.destination as? SubCategoryViewController {
                    vc.subcategories = self.categoryesArray[indexPath.row].subcategories
                }
            }
        }
    }
    
    //MARK: - downloadCategoriesFromJSON
    fileprivate func downloadCategoriesFromJSON(_ urlString: String) {
        guard let urlString = URL(string: url) else {
            return
        }
        AF.request(urlString).validate().responseJSON { (response) in
            guard let cats = try? JSONDecoder().decode([String: Category].self, from: response.data!) else {
                print("Error while decode")
                return
            }
            for cat in cats.sorted(by: { (c1, c2) -> Bool in
                return Int(c1.value.sortOrder)! < Int(c2.value.sortOrder)!
            }).filter({ (c1) -> Bool in
                return !(c1.value.subcategories.isEmpty )
            }) {
                self.categoryesArray.append(cat.value)
            }
        }
    }
    
    //MARK: - addNavBarImage
    fileprivate func addNavBarImage() {
        let navController = navigationController!
        let image = UIImage(named: "Black_Star_Wear_Guidelines_wear")
        let imageView = UIImageView(image: image)
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
}

//MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
}
