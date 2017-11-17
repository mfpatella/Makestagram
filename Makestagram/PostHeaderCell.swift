//
//  PostHeaderCell.swift
//  Makestagram
//
//  Created by Matthew Patella on 10/21/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {

    static let height: CGFloat = 54
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        print("options button tapped")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
