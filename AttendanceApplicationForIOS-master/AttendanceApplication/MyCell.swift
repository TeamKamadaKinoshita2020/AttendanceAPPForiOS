//
//  MyCell.swift
//  AttendanceApplication
//
//  Created by kinoshita on 2019/05/06.
//  Copyright © 2019 kinoshitaShinya Kinoshita. All rights reserved.
//

import UIKit

class MyCell: UITableViewCell {
    @IBOutlet weak var lectureLabel: UILabel!
    @IBOutlet weak var repLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    
    func setCell(data: LectureInfo){
        self.lectureLabel.text = data.lectureName
        self.repLabel.text = "担当教員:" + data.repName
        self.roomLabel.text = "使用教室:" + data.roomName
    }
    
}
