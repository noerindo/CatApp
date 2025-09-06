//
//  CatCollectionViewCell.swift
//  CatApp
//
//  Created by Phincon on 05/09/25.
//

import UIKit
import Kingfisher

class CatCollectionViewCell: UICollectionViewCell {
    
    var viewModel: CardCatViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            setupCard(viewModel)
        }
    }
    
    @IBOutlet weak var photoCatImageView: UIImageView! {
        didSet {
            photoCatImageView.layer.cornerRadius = 10
            photoCatImageView.clipsToBounds = true
            photoCatImageView.contentMode = .scaleAspectFill
            photoCatImageView.layer.borderWidth = 2
            photoCatImageView.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCard(_ cardData: CardCatViewModel) {
        if let urlString = cardData.imageUrl, let url = URL(string: urlString) {
            photoCatImageView.kf.setImage(with: url)
        }
    }
}
