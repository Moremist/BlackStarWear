import UIKit

class SubCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subCatImageView: UIImageView!
    @IBOutlet weak var subCatNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
