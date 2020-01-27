import UIKit
import CoreNFC

class ThirdViewController: UIViewController {
    var studentInfo: StudentInfo!
    var lectureInfo: LectureInfo!
    var seatCardId: String!
    var nfcFeliCaProcess: NFCFeliCaProcess!
    let webConnection = WebConnection()
    var blinkLabelTimer = Timer()
    @IBOutlet weak var studentInfoLabel: UILabel!
    @IBOutlet weak var lectureInfoLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    var gifView: GifAnimateView!
    
    var session: NFCTagReaderSession?
    
    var num = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ヘッダー文字列の設定
        self.navigationItem.title = "座席カード読取"
        // 値渡しで受け取った情報をセット
        self.studentInfoLabel.text = self.studentInfo.studentNumber + ":" + self.studentInfo.studentName
        self.lectureInfoLabel.text = self.lectureInfo.lectureName
        // チュートリアルgifアニメの再生
        self.gifView = GifAnimateView(fileName: "seatcard_tutorial")
        self.gifView.frame = CGRect(x: 67, y: 243, width: 240, height: 180)
        self.view.addSubview(gifView)
        self.gifView.center = self.view.center
        self.gifView?.startAnimate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ボタン押下で出席処理
    @IBAction func tappedButton(_ sender: Any) {
        self.nfcFeliCaProcess = NFCFeliCaProcess()
        let nfcInfo = self.nfcFeliCaProcess.read()

        if !nfcInfo.isEmpty {
            if nfcInfo["type"] == Constants.TYPE_SEAT_ID_CARD { // 正常なタグであるので出席手続きを行う
                self.seatCardId = nfcInfo["idm"]
                print(self.seatCardId)
                
                /* 出席前のチェック処理群 エラーがなければ出席処理に移る*/
                /* 存在しない座席(0番座席)を読み取った場合 */
                let seatNum = String(webConnection.getSeatNum(holdingId: lectureInfo.holdingId, cardId: self.seatCardId))
                if seatNum == "0" {
                    // アラートインスタンスの生成
                    let alert: UIAlertController = UIAlertController(title: "出席エラー",message: "無効な座席カードです",
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
                /* 既に他人が出席している座席に出席しようとした場合 */
                else if webConnection.checkEmptySeat(holdingId: lectureInfo.holdingId, cardId: self.seatCardId) {
                    // アラートインスタンスの生成
                    let alert: UIAlertController = UIAlertController(title: "NFCエラー",message: "この座席は既に出席されています",
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
                /* 出席処理 */
                else {
                    print("出席失敗")
                    let alert: UIAlertController = UIAlertController(title: "この内容で出席を行いますか？",message: lectureInfo.roomName + ":" +  seatNum + "番座席",
                                                                     preferredStyle: UIAlertController.Style.alert)
                    let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        // 出席を行う
                        let result = self.webConnection.sendAttend(holdingId: self.lectureInfo.holdingId, userId: self.studentInfo.studentNumber, cardId: self.seatCardId)
                        if result {
                            print("出席成功")
                            let alert: UIAlertController = UIAlertController(title: "出席成功",message: "出席が完了しました",
                                                                             preferredStyle: UIAlertController.Style.alert)
                            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler:{
                                (action: UIAlertAction!) -> Void in
                                // アプリの再起動処理↓↓
                                self.blinkLabelTimer.invalidate()
                                self.restartApplication()
                            })
                            alert.addAction(cancelAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            print("出席失敗")
                            let alert: UIAlertController = UIAlertController(title: "出席エラー",message: "出席に失敗しました",
                                                                             preferredStyle: UIAlertController.Style.alert)
                            let cancelAction: UIAlertAction = UIAlertAction(title: "戻る", style: UIAlertAction.Style.cancel, handler:{
                                (action: UIAlertAction!) -> Void in
                            })
                            alert.addAction(cancelAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                    let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
                        (action: UIAlertAction!) -> Void in
                    })
                    alert.addAction(defaultAction)
                    alert.addAction(cancelAction)
                    present(alert, animated: true, completion: nil)
                }
            }
            else { // タグの種類が違うので処理を行わない
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
    
    // ラベル点滅処理(隠す隠さないの繰り返し) タイマーで定期的に呼ぶ
    @objc func blinkLabel() {
        self.messageLabel.isHidden = !self.messageLabel.isHidden
    }
    
    
    // 出席成功時のアプリ再起動処理
    func restartApplication() {
        /* 動かすとアプリが止まるのでコメントアウト
        let restartViewController = FirstViewController()
        restartViewController.modalTransitionStyle = .crossDissolve
        self.present(restartViewController, animated: true, completion: nil)
        */
    }
}
