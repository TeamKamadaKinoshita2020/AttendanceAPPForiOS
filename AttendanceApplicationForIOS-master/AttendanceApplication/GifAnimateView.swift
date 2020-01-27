import UIKit
import WebKit

/**
 *https://qiita.com/KikurageChan/items/fe3b670a1c996d7cd16f
 *gifアニメ再生用の簡易カスタムクラス
 */
class GifAnimateView: WKWebView {
    
    private var data: Data?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }
    
    private override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.initialize()
    }
    
    convenience init?(fileName: String, origin: CGPoint = CGPoint.zero) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "gif") else { return nil }
        guard let gifData = NSData(contentsOf: url) else { return nil }
        guard let image = UIImage(data: gifData as Data) else { return nil }
        self.init(frame: CGRect(origin: origin, size: image.size))
        self.data = gifData as Data
    }
    
    private func initialize() {
        self.scrollView.isScrollEnabled = false
        self.scrollView.isUserInteractionEnabled = false
    }
    /**
     gifを再生します (infinity animation)
     */
    func startAnimate() {
        guard let data = self.data else { return }
        self.load(data, mimeType: "image/gif", characterEncodingName: "utf-8", baseURL: NSURL() as URL)
    }
    /**
     gif再生を停止し、表示をクリーンします
     */
    func clear() {
        guard let url = URL(string: "about:blank") else { return }
        self.load(URLRequest(url: url))
    }
    /**
     URLからgifをロードします
     */
    static func setGifBy(url: String, origin: CGPoint = CGPoint.zero, completion: @escaping ((GifAnimateView) -> ())) {
        guard let url = URL(string: url) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error == nil, case .some(let result) = data {
                guard let image = UIImage(data: result as Data) else { return }
                DispatchQueue.main.async {
                    let gifAnimateView = GifAnimateView(frame: CGRect(origin: origin, size: image.size))
                    gifAnimateView.data = result
                    completion(gifAnimateView)
                }
            }
        }
        task.resume()
    }
}
