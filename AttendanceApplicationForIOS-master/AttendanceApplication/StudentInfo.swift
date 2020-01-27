import Foundation

/// 学生情報クラス
class StudentInfo {
    var studentNumber: String
    var studentName: String
    
    //イニシャライザ(コンストラクタ的なもの)
    ///
    /// - Parameters:
    ///   - num: 学籍番号
    ///   - name: 氏名
    init(num: String, name: String) {
        self.studentNumber = num
        self.studentName = name

    }
}
