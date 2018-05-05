//
//  MovieCollectionViewCell.swift
//  filmLibrary
//
//  Created by Alyona Hulak on 4/30/18.
//  Copyright © 2018 Alyona Hulak. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
