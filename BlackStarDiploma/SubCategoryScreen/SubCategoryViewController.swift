import UIKit
import Bond
import Kingfisher
import ReactiveKit

class SubCategoryViewController: UIViewController {

    @IBOutlet weak var subTableView: UITableView!
    var subcategories: [Subcategory]?
    var subCat = MutableObservableArray<Subcategory>([])
    var dispBag = DisposeBag()
    
    fileprivate func configureSelectedRowSubTableView() -> Disposable {
        return subTableView.reactive.selectedRowIndexPath.observeNext { (index) in
            self.subTableView.deselectRow(at: index, animated: true)
            self.performSegueWithIdentifier(identifier: "toWearList", sender: nil) { (segue) in
                if let vc = segue.destination as? WearListViewController {
                    vc.subcategoryID = self.subCat[index.row].id
                }
            }
        }
    }
    
    fileprivate func configureSubTableViewBinding() -> Disposable {
        return subCat.bind(to: subTableView) { (data, indexPath, tableView) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "subcatCell") as! SubCategoryTableViewCell
            cell.subCatNameLabel.text = data[indexPath.row].name
            let url = URL(string: "https://blackstarshop.ru/" + data[indexPath.row].iconImage)
            cell.subCatImageView.kf.setImage(with: url)
            return cell
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        generateSubCat()
        configureSubTableViewBinding().dispose(in: dispBag)
        configureSelectedRowSubTableView().dispose(in: dispBag)
    }
    
    func generateSubCat(){
        guard let subs = subcategories else {
            return
        }
        for sub in subs {
            if sub.type == .category {
                subCat.append(sub)
            }
        }
    }
}
