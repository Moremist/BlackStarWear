import UIKit

class BasketTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemOfferLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: BasketTableViewCellDelegate?
    var index : IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemImage.layer.cornerRadius = 10
        itemImage.clipsToBounds = true
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func deleteButtonPressed(){
        self.delegate?.deleteItemButtonPressed(index: index)
    }

}

protocol BasketTableViewCellDelegate {
    func deleteItemButtonPressed(index: IndexPath)
}
