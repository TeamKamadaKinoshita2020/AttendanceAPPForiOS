import Foundation

// 定数定義ファイル
struct Constants {
    /// HTTP通信関連の定数定義
    // 通信タイムアウト時間設定
    static let TIME_OUT = 2000
    // 通信結果の真偽返り値の設定(PHPのboolは1,0なので)
    static let RETURN_HTTP_TRUE = "1"
    static let RETURN_HTTP_FALSE = "0"
    // 出席管理システムのドメイン サーバには乗せていないのでローカルIPアドレス＋階層を記述
    static let URL_DOMAIN = "http://157.80.87.65/attendancesystem/android/"
    // 各処理で接続するURLの定数
    static let URL_GET_POSSIBLE_ATTEND_LIST = "get-possible-attend-list.php"
    static let URL_CHECK_ALREADY_ATTEND = "check-already-attend.php"
    static let URL_GET_SEAT_NUM = "get-seat-num.php"
    static let URL_CHECK_EMPTY_SEAT = "check-empty-seat.php"
    static let URL_SEND_ATTEND = "send-attendance.php"
    
    /// NFCタグ関連の定数定義
    // NFCタグ毎の処理分岐条件定数 読取タグにこの文字列が記録されていなければ各処理を行わない
    static let TYPE_STUDENT_ID_TAG = "IbarakiUnivStudentIdTag"
    static let TYPE_SEAT_ID_TAG = "IbarakiUnivSeatIdTag"
    
    /// FeliCa読取関連の定数定義
    // FeliCaカードタイプ
    static let TYPE_STUDENT_ID_CARD = "IbarakiUnivStudentIdCard"
    static let TYPE_SEAT_ID_CARD = "IbarakiUnivSeadIdCard"
    static let TYPE_UNKNOWN_CARD = "UnknownCard"
    // FeliCaシステムコード
    static let SYSTEMCODE_STUDENT_ID_CARD = "81f8"
    static let SYSTENCODE_SEAT_ID_CARD = "88b4"
    // FeliCaサービスコード
    static let SERVICECODE_STUDENT_ID_CARD = "100b"
}
