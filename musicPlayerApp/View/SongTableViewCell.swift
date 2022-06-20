//
//  SongTableViewCell.swift
//  musicPlayerApp
//
//  Created by 林祐辰 on 2022/6/17.
//

import UIKit

class SongTableViewCell: UITableViewCell {

        
    let indexLabel = UILabel(frame: CGRect(x: 10, y: 15, width: 30, height: 20))
    let nameLabel = UILabel(frame: CGRect(x: 50, y: 15, width: 400, height: 20))
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    override init(style:UITableViewCell.CellStyle,reuseIdentifier:String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(indexLabel)
        self.contentView.addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


