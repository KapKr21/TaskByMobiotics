//
//  RelatedVideosCell.swift
//  TaskByMobiotics
//
//  Created by Kap's on 11/07/20.
//

import UIKit

class RelatedVideosCell: UITableViewCell {
    
    @IBOutlet weak var relatedThumb: UIImageView!
    @IBOutlet weak var relatedTitle: UILabel!
    @IBOutlet weak var relatedDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.relatedThumb.layer.cornerRadius = 18
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
