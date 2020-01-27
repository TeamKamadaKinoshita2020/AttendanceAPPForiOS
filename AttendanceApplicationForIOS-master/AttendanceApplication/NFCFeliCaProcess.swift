
import Foundation
import CoreNFC

class NFCFeliCaProcess: NSObject, NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?
    var returnValue: [String: String] = ["": ""] // 返り値で使用するハッシュ(連想配列)
    let semaphore = DispatchSemaphore(value: 0)
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("tagReaderSessionDidBecomeActive(_:)")
    }
    
    // 読取失敗時の処理
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("error:\(error.localizedDescription)")
        self.semaphore.signal()
    }
    
    // 読取成功時の処理
    /*
     FeliCa読取処理
     https://qiita.com/m__ike_/items/7dc3e643396cf3381167 を参照
     */
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first, case let .feliCa(felicaTag) = tag else { return }    // ①最初に検出したタグの抽出　この時点でIdm,SystemCodeの取得が可能
        
        // カードの種類(SystemCode)に応じて処理を分岐(学生証以外はここで処理が終了する)
        let idm = felicaTag.currentIDm.map { String(format: "%.2hhx", $0) }.joined()
        let systemCode = felicaTag.currentSystemCode.map { String(format: "%.2hhx", $0) }.joined()
        self.returnValue["idm"] = String(idm.suffix(idm.count - 1))
        if systemCode != Constants.SYSTEMCODE_STUDENT_ID_CARD {
            if systemCode == Constants.SYSTENCODE_SEAT_ID_CARD {
                self.returnValue["type"] = Constants.TYPE_SEAT_ID_CARD
            } else {
                self.returnValue["type"] = Constants.TYPE_UNKNOWN_CARD
            }
            session.invalidate()
            self.semaphore.signal()
            return
        }
        // 学生証なので中身の読み取りへ移る
        self.returnValue["type"] = Constants.TYPE_STUDENT_ID_CARD
        session.connect(to: tag) { error in    // ②
            if let error = error {
                print("Error: ", error)
                self.semaphore.signal()
                return
            }
            
            let historyServiceCode = Data([0x10, 0x0b].reversed())    // ③アドレス100bに学生情報が存在　リトルエンディアンなのでひっくり返す
            felicaTag.requestService(nodeCodeList: [historyServiceCode]) { nodes, error in    // ④
                if let error = error {
                    print("Error: ", error)
                    self.semaphore.signal()
                    return
                }
                
                /*
                guard let data = nodes.first, data != Data([0xff, 0xff]) else {    // ⑤
                    print("サービスが存在しない")
                    return
                }*/
                
                let blockList = (0..<12).map { Data([0x80, UInt8($0)]) }    // ⑥
                felicaTag.readWithoutEncryption(serviceCodeList: [historyServiceCode], blockList: blockList)    // ⑦
                { status1, status2, dataList, error in
                    if let error = error {
                        print("Error: ", error)
                        return
                    }
                    guard status1 == 0x00, status2 == 0x00 else {    // ⑧
                        print("ステータスフラグエラー: ", status1, " / ", status2)
                        return
                    }
                    session.invalidate()    // ⑨ 読取処理の終了
                    
                    let studentNumber = String(data: dataList[0], encoding: .shiftJIS)!.prefix(8) // データ配列の0番目に学籍番号が存在
                    var studentName = String(data: dataList[4] + dataList[5] + dataList[6], encoding: .shiftJIS)! // 4,5,6番目に名前が存在
                    var studentNameKana = String(data: dataList[7] + dataList[8] + dataList[9], encoding: .shiftJIS)! // 7,8,9番目にﾌﾘｶﾞﾅが存在
                    //studentNumber  = String(studentNumber.prefix(8))// 学籍番号切り出し
                    studentName = studentName.trimmingCharacters(in: .whitespaces)// 空白部分を削除
                    studentNameKana = studentNameKana.trimmingCharacters(in: .whitespaces)
                    
                    self.returnValue["StudentNumber"] = studentNumber + ""
                    self.returnValue["StudentName"] = studentName
                    self.semaphore.signal()
                    /*
                    // デバッグ用
                    var str: String = ""
                    str += studentNumber + ": "
                    str += studentName
                    str += "(" + studentNameKana + ")"
                    print(str)
                     */
                }
            }
        }
    }
    
    /*
     * NFCセッションを起動し、読み取ったv中身のデータを返す関数
     */
    func read() -> [String: String] {
        if NFCTagReaderSession.readingAvailable {
            self.session = NFCTagReaderSession(pollingOption: .iso18092, delegate: self)
            self.session?.alertMessage = "Hold your iPhone near the item to learn more about it."
            self.session?.begin()
            
        } else {
            print("NFCが使えません")
        }
        self.semaphore.wait()
        print(self.returnValue)
        return self.returnValue
    }
}

