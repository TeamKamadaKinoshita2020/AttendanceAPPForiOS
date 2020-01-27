import Foundation

/// 講義情報クラス
class LectureInfo {
    var holdingId: String
    var lectureName: String
    var repName: String
    var roomName: String
    
    /// イニシャライザ(コンストラクタ的なもの)
    ///
    /// - Parameters:
    ///   - holdingId: 指定回講義の固有開催ID
    ///   - lectureName: 講義名　加工された名前で送られてくる
    ///   - repName: 担当教員名
    ///   - roomName: 部屋名
    init(holdingId: String, lectureName: String, repName: String, roomName: String) {
        self.holdingId = holdingId
        self.lectureName = lectureName
        self.repName = repName
        self.roomName = roomName
    }
}
