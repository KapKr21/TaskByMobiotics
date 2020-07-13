//
//  VideoDataCell.swift
//  TaskByMobiotics
//
//  Created by Kap's on 10/07/20.
//

import UIKit

class VideoDataCell: UITableViewCell {

    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.videoImage.layer.cornerRadius = 18
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
