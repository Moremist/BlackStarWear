import UIKit
import Alamofire
import Kingfisher

class CategoryViewController: UIViewController {

    var categoriesArray = Array<Category>([])
    
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        downloadCategories()
    
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.alpha = 0
        
        tabBarController?.delegate = self
        
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()

        addNavBarImage()
    }
    
    //MARK: - downloadCategories
    fileprivate func downloadCategories() {
        Network().fetchArrayFromUrl(url: BlackStarURLs().getCatURL()!, type: Category.self) { (data) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.categoriesArray = data
                self.categoryTableView.reloadData()
            }
        }
    }

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

    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCell") as! CategoryTableViewCell
        cell.categoryCellName.text = categoriesArray[indexPath.row].name

        let imageString = categoriesArray[indexPath.row].image
        let imageURL = BlackStarURLs().getImageURL(imageUrlString: imageString)
        cell.categoryImageView.kf.setImage(with: imageURL)
        cell.categoryImageView.layer.cornerRadius = cell.categoryImageView.frame.width / 2
        cell.categoryImageView.clipsToBounds = true
        cell.categoryImageView.contentMode = .scaleAspectFit

        self.activityIndicator.stopAnimating()
        self.activityIndicator.alpha = 0
        self.categoryTableView.alpha = 1

        return cell
    }
    
    //MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.categoryTableView.deselectRow(at: indexPath, animated: true)
        self.performSegueWithIdentifier(identifier: "toSubCat", sender: nil) { (segue) in
            if let vc = segue.destination as? SubCategoryViewController {
                vc.subcategories = self.categoriesArray[indexPath.row].subcategories.filter({ (s1) -> Bool in
                    return s1.type == .category
                })
                vc.categoryName = self.categoriesArray[indexPath.row].name
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}

extension CategoryViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let vc = viewController as? BasketViewController else { return }
        vc.basketIsEmptyCheck()
    }
}
