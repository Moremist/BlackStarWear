import UIKit
import Kingfisher

class BasketViewController: UIViewController {


    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var basketTableView: UITableView!
    @IBOutlet weak var emptyStack: UIStackView!
    @IBOutlet weak var eraseBasketButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    //MARK: - eraseBasketButtonPressed
    @IBAction func eraseBasketButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Очистить корзину?", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Отмена", style: .default) { (action) in
            return
        }
        let okButton = UIAlertAction(title: "Очистить", style: .cancel) { (action) in
            self.currentBasket.basketArray.removeAll()
            self.basketIsEmptyCheck()
        }
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        present(alert, animated: true)
    }
    
    //MARK: - checkoutButtonPressed
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.checkoutButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (done) in
            UIView.animate(withDuration: 0.2) {
                self.checkoutButton.transform = CGAffineTransform.identity
            }
        }
        print(currentBasket.basketArray)
    }
    
    var currentBasket = Basket()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        basketTableView.delegate = self
        basketTableView.dataSource = self
        
        currentBasket = Basket.shared
        
        buyButtonConfigure()
        basketIsEmptyCheck()
    
    }
    
    //MARK: - buyButtonConfigure
    fileprivate func buyButtonConfigure() {
        checkoutButton.layer.cornerRadius = 10
        checkoutButton.clipsToBounds = true
    }
    
    //MARK: - basketIsEmptyCheck
    public func basketIsEmptyCheck() {
        if currentBasket.basketArray.isEmpty {
            checkoutButton.isEnabled = false
            checkoutButton.backgroundColor = .gray
            emptyStack.alpha = 1
            basketTableView.alpha = 0
            eraseBasketButton.isHidden = true
        } else {
            checkoutButton.isEnabled = true
            checkoutButton.backgroundColor = .black
            basketTableView.alpha = 1
            emptyStack.alpha = 0
            eraseBasketButton.isHidden = false
        }
        updateTotalSum()
        basketTableView.reloadData()
    }
    
    //MARK: - updateTotalSum
    fileprivate func updateTotalSum(){
        var totalSum = 0
        for item in currentBasket.basketArray {
            totalSum += Int(item.item.price.split(separator: ".")[0]) ?? 0
        }
        totalPriceLabel.text = String(totalSum) + " ₽"
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension BasketViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentBasket.basketArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = basketTableView.dequeueReusableCell(withIdentifier: "basketCell") as! BasketTableViewCell
        cell.itemNameLabel.text = currentBasket.basketArray[indexPath.row].item.name.cleanName()
        cell.itemOfferLabel.text = currentBasket.basketArray[indexPath.row].offer
        cell.itemPriceLabel.text = currentBasket.basketArray[indexPath.row].item.price.priceInRubles()
        let imageURL = URL(string: "https://blackstarshop.ru/" + currentBasket.basketArray[indexPath.row].item.mainImage)
        cell.itemImage.kf.setImage(with: imageURL)
        cell.itemImage.contentMode = .scaleAspectFill
        cell.index = indexPath
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegueWithIdentifier(identifier: "fromBasketToDetail", sender: nil) { (segue) in
            guard let vc = segue.destination as? WearDetailViewController else { return }
            vc.wear = self.currentBasket.basketArray[indexPath.row].item
            vc.imagesURLs = self.currentBasket.basketArray[indexPath.row].item.productImages
            vc.offers = self.currentBasket.basketArray[indexPath.row].item.offers
            vc.basketVC = self
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.currentBasket.basketArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            self.basketIsEmptyCheck()
        }
    }
}

//MARK: - BasketTableViewCellDelegate
extension BasketViewController: BasketTableViewCellDelegate {
    func deleteItemButtonPressed(index: IndexPath) {
        let alert = UIAlertController(title: "", message: "Удалить из корзины?", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Оставить", style: .default) { (action) in
            return
        }
        let okButton = UIAlertAction(title: "Удалить", style: .cancel) { (action) in
            self.currentBasket.basketArray.remove(at: index.row)
            self.basketTableView.deleteRows(at: [index], with: .left)
            self.basketIsEmptyCheck()
        }
        
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        
        present(alert, animated: true)
    }
}

