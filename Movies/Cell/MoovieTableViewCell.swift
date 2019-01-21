//
//  MoovieTableViewCell.swift
//  Movies
//
//  Created by Sarika on 20/01/19.
//  Copyright © 2019 Sarika. All rights reserved.
//

import UIKit

class MoovieTableViewCell: UITableViewCell {

    @IBOutlet weak var moovieImageView: UIImageView!
    @IBOutlet weak var moovieTitleLabel: UILabel!
    @IBOutlet weak var moovieFormatLabel: UILabel!
    @IBOutlet weak var userRatingView: UserRating!
    
    var userRatingHandler : ((_ rating: Int) -> Void)?
    {
        didSet{
            if let userRatingHandler = userRatingHandler{
                userRatingView.ratingUpdateHandler = userRatingHandler
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(moovie: Movie){
        moovieTitleLabel.text = moovie.title
        moovieFormatLabel.text = moovie.format
        userRatingView.rating = Int(moovie.userRating) //converting from Integer16 to Int because in our entity its Int16 and in userRating class we have Int.
        if let imageData = moovie.image as Data? {
            moovieImageView.image = UIImage(data: imageData)
        }
    }

}
