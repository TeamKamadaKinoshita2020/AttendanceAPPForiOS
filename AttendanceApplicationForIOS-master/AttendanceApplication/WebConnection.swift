import Foundation

class WebConnection {
    let session = URLSession.shared
    let semaphore = DispatchSemaphore(value: 0)// 一時ロック（排他制御）変数　非同期を同期にして値を受け取る
    
    /// HTTP通信で出席可能な講義情報を取得
    ///
    /// - Returns: 出席可能講義の一覧(LectureInfoObjectのArrayList)
    func getPossibleAttendList() -> Array<LectureInfo> {
        var returnData: Data!
        var result = Array<LectureInfo>()
        let tempUrl = URL(string:Constants.URL_DOMAIN + Constants.URL_GET_POSSIBLE_ATTEND_LIST)// 関数用urlの設定
        print("URL:" + Constants.URL_DOMAIN + Constants.URL_GET_POSSIBLE_ATTEND_LIST)
        let req = URLRequest(url: tempUrl!)
        let task = session.dataTask(with: req) {
            (
            data, response, error) in
            // print(String(data: data!, encoding: String.Encoding.utf8)) // デバッグ用
            if data == nil {
                print("error")
            }
            else {
                returnData  = data
            }
            self.semaphore.signal()// 一時ロックの解除
        }
        
        task.resume()
        semaphore.wait()// 通信処理が終わる前にリターンしてしまうので一時ロックで同期処理化
        print(String(data: returnData, encoding: .utf8))
        // 返り値のJSONをパース
        if returnData != nil {
            do {
                var dic = try JSONSerialization.jsonObject(with: returnData!,options: []) as? [String: Any]
                var returnLectures = dic?["results"] as AnyObject?
                print(returnLectures)
                let count = Int(dic?["count"] as! String)!// JSON内の要素数
                for i in 0 ..< count {
                    print(returnLectures?[i] as? [String: Any])
                    let lectureInfo = returnLectures?[i] as? [String: Any]// returnLectures?[String(i)] as? [String: Any]
                    result.append(LectureInfo(
                        holdingId: String(lectureInfo?["holding_id"] as! Int),
                        // なぜか数値型(NSCFNumber)にされているので、ここだけInt変換→String変換の処理を記述
                        lectureName: lectureInfo?["text"] as! String,
                        repName: lectureInfo?["rep_name"] as! String,
                        roomName: lectureInfo?["room_name"] as! String))
                }
                
                // 旧処理
                /*for i in 0 ..< count {
                    let lectureInfo = dic?[String(i)] as? [String: Any]
                    result.append(LectureInfo(
                        holdingId: String(lectureInfo?["holding_id"] as! Int),// なぜか数値型(NSCFNumber)にされているので、ここだけInt変換→String変換の処理を記述
                        lectureName: lectureInfo?["text"] as! String,
                        repName: lectureInfo?["rep_name"] as! String,
                        roomName: lectureInfo?["room_name"] as! String))
                }*/
            } catch {
                print(error)
            }
        }
        return result
    }
    
    /// HTTP通信で同じ学生が同じ講義に出席していないかを確認する
    ///
    /// - Parameters:
    ///   - holdingId: 出席する講義の開催回固有ID
    ///   - userId: 学生IID
    /// - Returns: 出席済みかどうか真偽で返す
    func checkAlreadyAttend(holdingId: String, userId: String) -> Bool {
        var returnData: Data!
        var result = false
        let tempUrl = URL(string:Constants.URL_DOMAIN + Constants.URL_CHECK_ALREADY_ATTEND)// 関数用urlの設定
        print("URL:" + Constants.URL_DOMAIN + Constants.URL_CHECK_ALREADY_ATTEND)
        var req = URLRequest(url: tempUrl!)
        // POST通信の設定
        req.httpMethod = "POST"
        let postData = ["h_id":holdingId, "u_id":userId]
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        req.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: req) {
            (
            data, response, error) in
            if data == nil {
                print("error")
            }
            else {
                returnData  = data
            }
            self.semaphore.signal()// 一時ロックの解除
        }
        task.resume()
        semaphore.wait()// 通信処理が終わる前にリターンしてしまうので一時ロックで同期処理化
        
        // 返り値のJSONをパース
        if returnData != nil {
            do {
                var dic = try JSONSerialization.jsonObject(with: returnData!,options: []) as? [String: Any]
                var returnResult = dic?["result"] as AnyObject?
                print(returnResult)
                
                result = returnResult as! Bool
            } catch {
                print(error)
            }
        }

        return result
    }
    
    func getSeatNum(holdingId: String, cardId: String) -> String {
        var returnData: Data!
        var result = "0"
        let tempUrl = URL(string:Constants.URL_DOMAIN + Constants.URL_GET_SEAT_NUM)// 関数用urlの設定
        print("URL:" + Constants.URL_DOMAIN + Constants.URL_GET_SEAT_NUM)
        var req = URLRequest(url: tempUrl!)
        // POST通信の設定
        req.httpMethod = "POST"
        let postData = ["h_id":holdingId, "c_id":cardId]
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        req.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: req) {
            (
            data, response, error) in
            if data == nil {
                print("error")
            }
            else {
                returnData  = data
            }
            self.semaphore.signal()// 一時ロックの解除
        }
        task.resume()
        semaphore.wait()// 通信処理が終わる前にリターンしてしまうので一時ロックで同期処理化
        // 返り値のJSONをパース
        if returnData != nil {
            do {
                var dic = try JSONSerialization.jsonObject(with: returnData!,options: []) as? [String: Any]
                var returnResult = dic?["seatNum"] as AnyObject?
                print(returnResult)
                
                // 返り値が0の場合はNSTaggedPointerString(上)に、それ以外はNSStringになるっぽいので処理を分割
                if let value = (returnResult as? NSString)?.doubleValue {
                    print(Int(value))
                    result = String(Int(value))
                } else {
                    print( String(describing: returnResult as! Int))
                    result = String(describing: returnResult as! Int)
                }

            } catch {
                print(error)
                result = "0"
            }
        }
        
        return result
    }
    
    func checkEmptySeat(holdingId: String, cardId: String) -> Bool {
        var returnData: Data!
        var result = false
        let tempUrl = URL(string:Constants.URL_DOMAIN + Constants.URL_CHECK_EMPTY_SEAT)// 関数用urlの設定
        print("URL:" + Constants.URL_DOMAIN + Constants.URL_CHECK_EMPTY_SEAT)
        var req = URLRequest(url: tempUrl!)
        // POST通信の設定
        req.httpMethod = "POST"
        let postData = ["h_id":holdingId, "c_id":cardId]
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        req.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: req) {
            (
            data, response, error) in
            if data == nil {
                print("error")
            }
            else {
                returnData  = data
            }
            self.semaphore.signal()// 一時ロックの解除
        }
        task.resume()
        semaphore.wait()// 通信処理が終わる前にリターンしてしまうので一時ロックで同期処理化
        // 返り値のJSONをパース
        if returnData != nil {
            do {
                var dic = try JSONSerialization.jsonObject(with: returnData!,options: []) as? [String: Any]
                var returnResult = dic?["result"] as AnyObject?
                print(returnResult)
                
                result = returnResult as! Bool
            } catch {
                print(error)
            }
        }
        
        return result
    }
    
    
    /// HTTP通信で出席情報を送信する
    ///
    /// - Parameters:
    ///   - holdingId: 出席する講義の開催回固有ID
    ///   - userId: 学生IID
    ///   - cardId: 座席ID
    /// - Returns: 成功したかどうか真偽で返す
    func sendAttend(holdingId: String, userId: String, cardId: String) -> Bool {
        var returnData: Data!
        var result = false
        let tempUrl = URL(string:Constants.URL_DOMAIN + Constants.URL_SEND_ATTEND)// 関数用urlの設定
        print("URL:" + Constants.URL_DOMAIN + Constants.URL_SEND_ATTEND)
        var req = URLRequest(url: tempUrl!)
        // POST通信の設定
        req.httpMethod = "POST"
        let postData = ["h_id":holdingId, "u_id":userId, "c_id":cardId]
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        req.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: req) {
            (
            data, response, error) in
            // print(String(data: data!, encoding: String.Encoding.utf8)) // デバッグ用
            if data == nil {
                print("error")
            }
            else {
                returnData  = data
            }
            self.semaphore.signal()// 一時ロックの解除
        }
        task.resume()
        semaphore.wait()// 通信処理が終わる前にリターンしてしまうので一時ロックで同期処理化
        // 返り値のJSONをパース
        if returnData != nil {
            do {
                var dic = try JSONSerialization.jsonObject(with: returnData!,options: []) as? [String: Any]
                var returnResult = dic?["result"] as AnyObject?
                print(returnResult)
                
                result = returnResult as! Bool
            } catch {
                print(error)
            }
        }
        
        return result
    }
    
    struct SeatNum: Codable {
        let seatNum: Int
    }
}
