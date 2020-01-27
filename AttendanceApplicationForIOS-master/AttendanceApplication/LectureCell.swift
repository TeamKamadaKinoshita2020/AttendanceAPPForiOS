//
//  LectureCell.swift
//  AttendanceApplication
//
//  Created by kinoshita on 2019/05/06.
//  Copyright © 2019 kinoshitaShinya Kinoshita. All rights reserved.
//

import UIKit

class LectureCell: UITableViewCell {
    @IBOutlet weak var lectureName: UILabel!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var roomName: UILabel!
    
    
    /*func setValue(lectureList: Array<LectureInfo>,indexPath :IndexPath){
        self.lectureName.text = lectureList[indexPath.row].lectureName
        self.repName.text = lectureList[indexPath.row].lectureName
        self.roomName.text = lectureList[indexPath.row].lectureName
    }*/
    
    /*func setValue(lectureList: Array<LectureInfo>,count :Int){
        self.lectureName.text = lectureList[count].lectureName
        self.repName.text = lectureList[count].lectureName
        self.roomName.text = lectureList[count].lectureName
    }*/
}
