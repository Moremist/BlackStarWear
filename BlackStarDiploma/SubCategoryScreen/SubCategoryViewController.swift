import UIKit
import Kingfisher

class SubCategoryViewController: UIViewController {

    @IBOutlet weak var subTableView: UITableView!
    var subcategories: [Subcategory] = []
    var categoryName : String?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        navigationItem.title = categoryName
        navigationItem.backBarButtonItem?.title = "Категории"
        
        subTableView.delegate = self
        subTableView.dataSource = self
        subTableView.reloadData()
        
    }
    
}

//MARK: - UITableViewDelegate
extension SubCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
}

//MARK: - UITableViewDataSource
extension SubCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subcategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subcatCell") as! SubCategoryTableViewCell
        cell.subCatNameLabel.text = subcategories[indexPath.row].name
        if subcategories[indexPath.row].iconImage == "" {
            switch subcategories[indexPath.row].name {
            case "Скидки":
                cell.subCatImageView.image = UIImage(named: "commerce-and-shopping")
            default:
                cell.subCatImageView.image = UIImage(named: "signaling")
            }
        } else {
            let imageUrl = subcategories[indexPath.row].iconImage
            let url = BlackStarURLs().getImageURL(imageUrlString: imageUrl)
            cell.subCatImageView.kf.setImage(with: url)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegueWithIdentifier(identifier: "toWearList", sender: nil) { (segue) in
            if let vc = segue.destination as? WearListViewController {
                vc.subcategoryID = self.subcategories[indexPath.row].id
                vc.subCatName = self.subcategories[indexPath.row].name
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
}
