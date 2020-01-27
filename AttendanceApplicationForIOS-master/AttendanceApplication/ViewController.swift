//
//  ViewController.swift
//  AttendanceApplication
//
//  Created by kinoshita on 2019/04/19.
//  Copyright © 2019 kinoshitaShinya Kinoshita. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var textStudentNumber: UITextField!
    @IBOutlet weak var textStudentName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // ボタン押下アクションクラス　ストーリーボードから　option + ドラック　で追加
    @IBAction func tappdButton(_ sender: Any) {
        
        // テキストフィールドの内容に応じた処理分岐
        if let name = textStudentName.text , let number = textStudentNumber.text{// 型チェックとやらでif文内で仮代入をしないといけないらしい(nullチェック?nil許容??)
            if(!name.isEmpty && !number.isEmpty){ // 正常処理(名前、IDが入力されているので 講義選択ページへ)
                
            }
            else{ // 異常処理(未入力など)
                // テストクラスオブジェクトの宣言
                var studentInfo = StudentInfo(name: "永遠の", num: "17")
                // アラートインスタンスの生成
                let alert: UIAlertController = UIAlertController(title: "alerttest",message: studentInfo.studentName + studentInfo.studentNumber + "歳",
                                                                 preferredStyle: UIAlertController.Style.alert)
                // okボタンの設定
                let defaultAction: UIAlertAction = UIAlertAction(title: "おｋ", style: UIAlertAction.Style.default, handler:{
                    //button push action
                    (action: UIAlertAction!) -> Void in
                    print("おｋ")
                })
                // cencelボタンの設定
                let cancelAction: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertAction.Style.cancel, handler:{
                    //button push action
                    (action: UIAlertAction!) -> Void in
                    print("戻る")
                })
                // コントローラにアクション追加
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                // アラート表示
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // textfield以外がタッチされたらキーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

