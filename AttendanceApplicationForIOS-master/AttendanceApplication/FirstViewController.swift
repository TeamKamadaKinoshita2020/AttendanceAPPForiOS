import UIKit

class FirstViewController: UIViewController {
    var studentInfo: StudentInfo!
    var nfcFeliCaProcess: NFCFeliCaProcess!
    var blinkLabelTimer = Timer()
    @IBOutlet weak var messageLabel: UILabel!
    
    var gifView: GifAnimateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ヘッダー文字列の設定
        self.navigationItem.title = "学生証読取"
        // チュートリアルgifアニメの再生
        self.gifView = GifAnimateView(fileName: "studentcard_tutorial")
        self.gifView.frame = CGRect(x: 67, y: 243, width: 240, height: 180)
        self.view.addSubview(gifView)
        self.gifView.center = self.view.center
        self.gifView?.startAnimate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ボタン押下アクションクラス　ストーリーボードから　option + ドラック　で追加
    @IBAction func tappdButton(_ sender: Any) {
        self.nfcFeliCaProcess = NFCFeliCaProcess()
        let nfcInfo = self.nfcFeliCaProcess.read()

        if !nfcInfo.isEmpty {
            if nfcInfo["type"] == Constants.TYPE_STUDENT_ID_CARD { // 正常なタグであるので処理を行う
                studentInfo = StudentInfo(num: nfcInfo["StudentNumber"]!, name: nfcInfo["StudentName"]!)
                // アラートインスタンスの生成
                let alert: UIAlertController = UIAlertController(title: "この学生証で出席を行いますか？",
                                                                 message: "学籍番号：" + studentInfo.studentNumber + " 氏名:" + studentInfo.studentName,
                                                                 preferredStyle: UIAlertController.Style.alert)
                // okボタンの設定
                let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
                    // button push action
                    (action: UIAlertAction!) -> Void in // 学生情報確定　講義選択画面へ遷移する処理
                    // 点滅タイマーの停止
                    self.blinkLabelTimer.invalidate()
                    // 同じstororyboard内であることを定義
                    let storyboard: UIStoryboard = self.storyboard!
                    // 移動先のstoryboard(画面)を選択(as!~を付けないと値渡しができない コントローラを指定していないから？)
                    let second = storyboard.instantiateViewController(withIdentifier: "secondViewController") as! SecondViewController
                    // 値渡し設定
                    second.studentInfo = self.studentInfo
                    // 遷移
                    self.navigationController?.pushViewController(second, animated: true)
                })
                // cencelボタンの設定
                let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
                    // button push action
                    (action: UIAlertAction!) -> Void in
                })
                // コントローラにアクション追加
                alert.addAction(defaultAction)
                alert.addAction(cancelAction)
                // アラート表示
                present(alert, animated: true, completion: nil)
            }
            else { // カードの種類が違うので処理を行わない
                // アラートインスタンスの生成
                let alert: UIAlertController = UIAlertController(title: "NFCエラー",message: "カードの種類が異なります",
                                                                 preferredStyle: UIAlertController.Style.alert)
                // cencelボタンの設定
                let cancelAction: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertAction.Style.cancel, handler:{
                    //button push action
                    (action: UIAlertAction!) -> Void in
                })
                // コントローラにアクション追加
                alert.addAction(cancelAction)
                // アラート表示
                present(alert, animated: true, completion: nil)
            }
        }
        else{ // レコードが空
            let alert: UIAlertController = UIAlertController(title: "NFCエラー",message: "カードのレコードが空です",
                                                             preferredStyle: UIAlertController.Style.alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertAction.Style.cancel, handler:{
                (action: UIAlertAction!) -> Void in
            })
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    /// Segue画面遷移での値渡し処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! SecondViewController
        secondViewController.studentInfo = studentInfo
    }
    
    // ラベル点滅処理(隠す隠さないの繰り返し) タイマーで定期的に呼ぶ
    @objc func blinkLabel() {
        self.messageLabel.isHidden = self.messageLabel.isHidden
    }
}

