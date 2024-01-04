//
//  SurveyAnswersTableViewCell.swift
//  RecordApp
//
//  Created by Darijan Gruevski on 12/27/23.
//  Copyright © 2023 Darijan Gruevski. All rights reserved.
//

import UIKit

class SurveyAnswersTableViewCell: UITableViewCell {
    @IBOutlet weak var subjectLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
