import UIKit
import Bond
import Kingfisher
import ReactiveKit

class SubCategoryViewController: UIViewController {

    @IBOutlet weak var subTableView: UITableView!
    var subcategories: [Subcategory]?
    var subCat = MutableObservableArray<Subcategory>([])
    var dispBag = DisposeBag()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        subTableView.delegate = self
        
        generateSubCat()
        configureSubTableViewBinding().dispose(in: dispBag)
        configureSelectedRowSubTableView().dispose(in: dispBag)
    }
    
    //MARK: - configureSelectedRowSubTableView
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
    
    //MARK: - configureSubTableViewBinding
    fileprivate func configureSubTableViewBinding() -> Disposable {
        return subCat.bind(to: subTableView) { (data, indexPath, tableView) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "subcatCell") as! SubCategoryTableViewCell
            cell.subCatNameLabel.text = data[indexPath.row].name
            if data[indexPath.row].iconImage == "" {
                switch data[indexPath.row].name {
                case "Скидки":
                    cell.subCatImageView.image = UIImage(named: "commerce-and-shopping")
                default:
                    cell.subCatImageView.image = UIImage(named: "signaling")
                }
            } else {
                let url = URL(string: "https://blackstarshop.ru/" + data[indexPath.row].iconImage)
                cell.subCatImageView.kf.setImage(with: url)
            }
            return cell
        }
    }
    
    //MARK: - generateSubCat
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

//MARK: - UITableViewDelegate
extension SubCategoryViewController: UITableViewDelegate {
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
