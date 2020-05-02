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
    
    fileprivate func configureCategoryViewController() -> Disposable {
        return categoryesArray.bind(to: categoryTableView) { (dataSource, indexPath, tableView) -> UITableViewCell in
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
            return cell
        }
    }
    
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
    
    fileprivate func downloadCategoriesFromJSON(_ urlString: URL) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
        configureCategoryViewController().dispose(in: dispBag)
        configureSelectedRowTableView().dispose(in: dispBag)
        
        guard let urlString = URL(string: url) else {
            return
        }
        
        downloadCategoriesFromJSON(urlString)
    }
    
}
