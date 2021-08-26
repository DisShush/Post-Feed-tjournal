//
//  PostCell.swift
//  PostFeed
//
//  Created by Владислав Шушпанов on 24.08.2021.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var headerPost: UILabel!
    @IBOutlet weak var textPost: UILabel!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var newsType: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    
    override func prepareForReuse() {
        imagePost.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
}
