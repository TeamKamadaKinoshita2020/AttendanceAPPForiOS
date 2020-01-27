//
//  NFCProcess.swift
//  AttendanceApplication
//
//  Created by kinoshita on 2019/05/27.
//  Copyright © 2019 kinoshitaShinya Kinoshita. All rights reserved.
//
import Foundation
import CoreNFC

class NFCTagProcess: NSObject, NFCNDEFReaderSessionDelegate {
    var session: NFCNDEFReaderSession?
    var returnValue: [String] = [] // 返り値で使う文字列配列
    let semaphore = DispatchSemaphore(value: 0)

    // 読み取り失敗時の処理
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("error:\(error.localizedDescription)")
        self.semaphore.signal()
    }
    // 読み取り成功時の処理
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("reader session")
        var result = ""
        print(messages)
        // メッセージ内の複数レコードを順番に読み出す
        for payload in messages[0].records {
            // レコードの前2文字は文字種類なので3文字目から読む
            result = String.init(data: payload.payload.advanced(by: 3), encoding: .utf8)!
            // 配列に追加
            self.returnValue.append(result)
        }
        self.semaphore.signal()
        DispatchQueue.main.async {
            print("reader session finish")
        }
    }
    
    /// nfc読取を行う関数
    ///
    /// - Returns: 読み取った内容を文字列配列として返す
    func read() -> [String] {
        // print("クラス内関数読み込み")
        if NFCNDEFReaderSession.readingAvailable {
            session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session?.alertMessage = "NFCタグをiPhoneに近づけてください"
            session?.begin()
            // print("読みー")
        } else {
            print("NFCが使えません")
        }
        self.semaphore.wait()
        print(self.returnValue)
        return self.returnValue
    }
}
