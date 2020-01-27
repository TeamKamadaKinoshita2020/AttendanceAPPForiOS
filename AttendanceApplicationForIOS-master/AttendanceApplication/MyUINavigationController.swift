//
//  MyUINavigationController.swift
//  AttendanceApplication
//
//  Created by kinoshita on 2019/09/06.
//  Copyright © 2019 kinoshitaShinya Kinoshita. All rights reserved.
//

import UIKit
import Foundation

class MyUINavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景色 水色
        navigationBar.barTintColor = UIColor(red: 0,green: 170/255,blue: 221/255,alpha: 1)
        // 戻るボタンの色 白
        navigationBar.tintColor = .white
        // 文字色 白
        let descriptor = UIFontDescriptor(fontAttributes: [
            UIFontDescriptor.AttributeName.name: "System -System"
        ])
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
            , NSAttributedString.Key.font : UIFont(descriptor: descriptor, size: 20)
        ]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
