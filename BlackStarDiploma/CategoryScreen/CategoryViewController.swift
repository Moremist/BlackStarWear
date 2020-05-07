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
        tabBarController?.delegate = self
        
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
            cell.categoryImageView.contentMode = .scaleAspectFill
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
                    vc.categoryName = self.categoryesArray[indexPath.row].name
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
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
    @IBOutlet weak var barView: UIView!
    
    //MARK: - addNavBarImage
    fileprivate func addNavBarImage() {
        let image = UIImage(named: "Black_Star_Wear_Guidelines_wear")
        let imageView = UIImageView(image: image)
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

extension CategoryViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let vc = viewController as? BasketViewController else { return }
        vc.basketIsEmptyCheck()
    }
}
