import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var studentInfo: StudentInfo!
    var lectureList = Array<LectureInfo>()
    let webConnection = WebConnection()
    @IBOutlet weak var studentInfoLabel: UILabel!
    @IBOutlet weak var lectureTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ヘッダー文字列の設定
        self.navigationItem.title = "出席講義選択"
        // 値渡しで受け取った学生情報をセット
        self.studentInfoLabel.text = self.studentInfo.studentNumber + ":" + self.studentInfo.studentName
        // HTTP通信で講義情報を取得
        self.lectureList =  self.webConnection.getPossibleAttendList()
        print("lecture list" + String(self.lectureList.count))
        // 先に空のリストが描画されてしまっているので再描画
        self.lectureTable.reloadData()
        lectureTable.register (UINib(nibName: "MyCell", bundle: nil),forCellReuseIdentifier:"myCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* ↓↓以下テーブル処理関連の関数群↓↓ */
    // リストテーブルの大きさ定義？(必須関数)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(lectureList.count)
        return lectureList.count
    }
    // セルの高さの設定(任意)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // リストテーブルに値をセット(必須関数)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let lectureCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCell
        // セルに表示する値を設定する
        lectureCell.setCell(data: lectureList[indexPath.row])
        return lectureCell
    }
    // タッチイベント処理(任意定義関数)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         //セルの選択解除
         tableView.deselectRow(at: indexPath, animated: true)
        // 各アラートインスタンスの宣言・生成
        // 出席確認アラートインスタンスの生成
        let attendAlert: UIAlertController = UIAlertController(title: "この講義に出席しますか？",
                                                               message: "講義名：" + lectureList[indexPath.row].lectureName,
                                                               preferredStyle: UIAlertController.Style.alert)
        // okボタンの設定
        let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            // button push action
            (action: UIAlertAction!) -> Void in // 講義情報確定　座席選択画面へ遷移する処理
            print("講義情報確定")
            // 同じstororyboard内であることを定義
            let storyboard: UIStoryboard = self.storyboard!
            // 移動先のstoryboard(画面)を選択(as!~を付けないと値渡しができない コントローラを指定していないから？)
            let third = storyboard.instantiateViewController(withIdentifier: "thirdViewController") as! ThirdViewController
            // 値渡し設定
            third.studentInfo = self.studentInfo
            third.lectureInfo = self.lectureList[indexPath.row]
            // 遷移
            self.navigationController?.pushViewController(third, animated: true)
        })
        // cencelボタンの設定
        let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
            //button push action
            (action: UIAlertAction!) -> Void in
        })
        // コントローラにアクション追加
        attendAlert.addAction(defaultAction)
        attendAlert.addAction(cancelAction)
        
        // 座席移動確認アラートインスタンスの生成
        let alreadyAttendAlert = UIAlertController(title: "あなたは既にこの講義に出席しています",
                                                   message: "座席移動を行いますか？",
                                                   preferredStyle: UIAlertController.Style.alert)
        // okボタンの設定
        let alreadyAttendDefaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            // button push action
            (action: UIAlertAction!) -> Void in // 出席確認アラートを表示
            self.present(attendAlert, animated: true, completion: nil)
        })
        // cencelボタンの設定
        let alreadyAttendCancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
            //button push action
            (action: UIAlertAction!) -> Void in
        })
        // コントローラにアクション追加
        alreadyAttendAlert.addAction(alreadyAttendDefaultAction)
        alreadyAttendAlert.addAction(alreadyAttendCancelAction)
        
        // 座聖移動判定&出席処理
        // 既に同講義に出席していた場合、ダイヤログのテキストを座席移動を行うか確認する内容に変更する
        if webConnection.checkAlreadyAttend(holdingId: lectureList[indexPath.row].holdingId, userId: studentInfo.studentNumber) {
            // 座席移動確認アラートの表示
            present(alreadyAttendAlert, animated: true, completion: nil)
        }
        else {
            // 出席確認アラートの表示
            present(attendAlert, animated: true, completion: nil)
        }
    }
    
}
