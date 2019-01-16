import UIKit
import AVKit
import AVFoundation
import Photos

class ViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    let imagePickerController = UIImagePickerController()
    var videoURL: URL?
    var existplayer: Bool = false
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var playerViewController = AVPlayerViewController()
    var currentTime: Float64!
    var currentTimeB: Float64!
    var duration: CMTime?
    var maxTime: Float64!
    var interval: CMTime!
    var interval1: CMTime!
    var LockB: Bool = false
    var VSize: Bool = false
    var asset: AVAsset!
    var Back: Bool = false
    var forward: Bool = false
    var Select: Bool = false
    // 表示できる限界(bound)のサイズ
    let BoundSize_w: CGFloat = UIScreen.main.bounds.width  //横幅
    let BoundSize_h: CGFloat = UIScreen.main.bounds.height //縦幅
    //ロックボタン
    @IBOutlet weak var LockButton: UIButton!
    @IBOutlet weak var LockButtonS: UIButton!
    //拡大縮小ボタン
    @IBOutlet weak var VideoSize: UIButton!
    @IBOutlet weak var VideoSizeS: UIButton!
    //再生ボタン
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var PlayButtonS: UIButton!
    //動画をだす範囲
    @IBOutlet weak var movieView: UIImageView!
    //動画の再生時間のスライダー
    @IBOutlet weak var mySlider: UISlider!
    //設定ボタン
    @IBOutlet weak var Setting: UIButton!
    //セレクトボタン
    @IBOutlet weak var selectButton: UIButton!
    //早送りボタン
    @IBOutlet weak var SpeedButton: UIButton!
    @IBOutlet weak var SpeedButtonS: UIButton!
    //巻き戻しボタン
    @IBOutlet weak var BackVideo: UIButton!
    @IBOutlet weak var BackVideoS: UIButton!
    //動画を５秒飛ばすボタン
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var forwardButtonS: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LockButtonS.isHidden = true
        VideoSizeS.isHidden = true
        PlayButtonS.isHidden = true
        SpeedButtonS.isHidden = true
        BackVideoS.isHidden = true
        forwardButtonS.isHidden = true
        Setting.layer.zPosition = -1
        selectButton.layer.zPosition = -1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PHPhotoLibrary.requestAuthorization { (_) in } // for iOS11
    }
    
    //動画を取得
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("動画を取得")
        if existplayer == true {
            player.pause()
            player = nil
        }
        existplayer = false
        videoURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        movieView.image = previewImageFromVideo(videoURL!)!
        movieView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    //動画のサムネイルを作る
    func previewImageFromVideo(_ url:URL) -> UIImage? {
        print("動画からサムネイルを生成する")
        asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(30,32)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
    //動画のシークバー
    @IBAction func SliderAction(_ sender: UISlider) {
        if existplayer == false {
            return
        }
        currentTime = CMTimeGetSeconds(player.currentTime())
        interval = CMTimeMakeWithSeconds(Double((mySlider?.value)!), preferredTimescale: Int32(UInt64(NSEC_PER_SEC)))
        if LockB == true {
            if Back == true ||  forward == true{
                player.seek(to: interval, toleranceBefore: interval, toleranceAfter: interval) { (Bool) in
                    self.currentTime = Float64(self.mySlider.value)
                }
            }
            return
        }
        player.seek(to: interval, toleranceBefore: interval, toleranceAfter: interval) { (Bool) in
            self.currentTime = Float64(self.mySlider.value)
        }
    }
    //動画が進むと自動でシークも動く
    @objc func updateseek() {
        if player == nil {
            return
        }
        currentTime = CMTimeGetSeconds(player.currentTime())
        mySlider.value = Float(currentTime)
    }
    
    //動画拡大ボタンを押したとき
    @IBAction func VideoSize(_ sender: UIButton) {
        if existplayer == false {
            return
        }
        if VSize == false {
            VSize = true
            VideoSize.setImage(UIImage(named: "縮小ボタン"), for: UIControl.State())
            VideoSizeS.setImage(UIImage(named: "縮小ボタン"), for: UIControl.State())
            playerLayer.frame = CGRect(x: 0, y: 0, width: BoundSize_w, height: BoundSize_h)
        } else {
            VSize = false
            VideoSize.setImage(UIImage(named: "拡大ボタン"), for: UIControl.State())
            VideoSizeS.setImage(UIImage(named: "拡大ボタン"), for: UIControl.State())
            playerLayer.frame = movieView.frame
        }
    }
    //ロックボタンを押したとき
    @IBAction func LockButton(_ sender: UIButton) {
        if existplayer == false {
            return
        }
        if LockB == false {
            LockB = true
            LockButton.setImage(UIImage(named: "ロック"), for: UIControl.State())
            LockButtonS.setImage(UIImage(named: "ロック"), for: UIControl.State())
            mySlider.layer.zPosition = -1
        } else {
            LockB = false
            LockButton.setImage(UIImage(named: "ロック解除"), for: UIControl.State())
            LockButtonS.setImage(UIImage(named: "ロック解除"), for: UIControl.State())
            mySlider.layer.zPosition = 0
        }
    }
    //Playボタンを押したときの動作
    @IBAction func StartButton(_ sender: UIButton) {
        print("ボタン")
        if existplayer == false {
            if Select == false {
                return
            }
            player = AVPlayer(url: videoURL!)
            playerLayer = AVPlayerLayer(player: player)
            var playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.view.layer.addSublayer(playerLayer)
            playerLayer.frame = movieView.frame
            playerLayer.zPosition = -0.9
            //動画時間の最大を取得
            duration = player?.currentItem?.asset.duration
            //上で取得したものを秒にしてる
            maxTime = CMTimeGetSeconds(duration!)
            //スライダーの最大の長さを動画の時間に合わせてる
            mySlider.maximumValue = Float(maxTime)
            mySlider.minimumValue = 0
            Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(ViewController.updateseek), userInfo: nil, repeats: true)
            movieView.image = nil
            existplayer = true
        }
        //動画が再生中か停止中か判定する
        var isPlaying: Bool {
            return player.rate != 0 && player.error == nil
        }
        if isPlaying == false {
            player.play()
            print("play")
        } else {
            player.pause()
            print("pause")
        }
    }
    //速度変更ボタンを押したとき
    @IBAction func RateButton(_ sender: UIButton) {
        if existplayer == false {
            return
        }
        let ratealert: UIAlertController = UIAlertController(title: "動画の速度を変更", message: "", preferredStyle: .actionSheet)
        ratealert.addAction(UIAlertAction(title: "1.0✗", style: .default, handler: { (action: UIAlertAction!) -> Void in
            self.player.rate = 1
        }))
        ratealert.addAction(UIAlertAction(title: "0.75✗", style: .default, handler: { (action: UIAlertAction!) -> Void in
            self.player.rate = 0.75
        }))
        ratealert.addAction(UIAlertAction(title: "0.5✗", style: .default, handler: { (action: UIAlertAction!) -> Void in
            self.player.rate = 0.5
        }))
        ratealert.addAction(UIAlertAction(title: "0.25✗", style: .default, handler: { (action: UIAlertAction!) -> Void in
            self.player.rate = 0.25
        }))
        ratealert.popoverPresentationController?.sourceView = view
        ratealert.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
        //UIAlertControllerの起動
        present(ratealert, animated: true, completion: nil)
    }
    //巻き戻しボタンを押したとき
    @IBAction func BackVideo(_ sender: UIButton) {
        if existplayer == false {
            return
        }
        Back = true
        self.mySlider.value -= 5
        SliderAction(mySlider)
        Back = false
    }
    //5秒飛ばしボタンを押したとき
    @IBAction func forwardVideo(_ sender: UIButton) {
        if existplayer == false {
            return
        }
        forward = true
        self.mySlider.value += 5
        SliderAction(mySlider)
        forward = false
    }
    //設定ボタンを押したときの動作
    @IBAction func SetingButton(_ sender: UIButton) {
        if LockB == true {
            return
        }
        let alertController: UIAlertController = UIAlertController(title: "ボタンの配置", message: "", preferredStyle: .actionSheet)
        //UIAlertController
        alertController.addAction(UIAlertAction(title : "ボタン画面横", style: .default, handler: { (action: UIAlertAction!) -> Void in
            //Sideボタン
            self.LockButtonS.isHidden = false
            self.VideoSizeS.isHidden = false
            self.PlayButtonS.isHidden = false
            self.SpeedButtonS.isHidden = false
            self.BackVideoS.isHidden = false
            self.forwardButtonS.isHidden = false
            //Topボタン
            self.LockButton.isHidden = true
            self.VideoSize.isHidden = true
            self.PlayButton.isHidden = true
            self.SpeedButton.isHidden = true
            self.BackVideo.isHidden = true
            self.forwardButton.isHidden = true
        }))
        alertController.addAction(UIAlertAction(title : "ボタン画面上", style: .default, handler: { (action: UIAlertAction!) -> Void in
            //Sideボタン
            self.LockButtonS.isHidden = true
            self.VideoSizeS.isHidden = true
            self.PlayButtonS.isHidden = true
            self.SpeedButtonS.isHidden = true
            self.BackVideoS.isHidden = true
            self.forwardButtonS.isHidden = true
            //Topボタン
            self.LockButton.isHidden = false
            self.VideoSize.isHidden = false
            self.PlayButton.isHidden = false
            self.SpeedButton.isHidden = false
            self.BackVideo.isHidden = false
            self.forwardButton.isHidden = false
        }))
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
        //UIAlertControllerの起動
        present(alertController, animated: true, completion: nil)
    }
    //selectボタンを押したときの動作
    @IBAction func selectImage(_ sender: Any) {
        if LockB == true {
            return
        }
        Select = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true, completion: nil)
    }
}
