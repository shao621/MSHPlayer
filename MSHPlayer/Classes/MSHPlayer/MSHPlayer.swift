//
//  MSHPlayer.swift
//  MSHPlayer
//
//  Created by Myshao on 2020/8/27.
//
//支持视频格式： MP4，MOV，M4V，3GP，AVI等。
//支持音频格式：MP3，AAC，WAV，AMR，M4A等。
//https://www.jianshu.com/p/e04a59894c15 参考链接
//https://www.jianshu.com/p/780738918a6c
import UIKit
import AVKit
import SnapKit

//class MSHPlayer: UIView {
//
//
//
//}

public enum MSPlayerStatus {
    case MSDefault //播放失败
    case MSFaild //播放失败
    case MSBuffering //缓冲中
    case MSPlaying // 播放中
    case MSStopped // 暂停播放
    case MSFinished // 播放完成
    case MSPause // 播放中断
    
}

 @objc public protocol MSPlayerDelegate: NSObjectProtocol {

    ///进入前台
    @objc optional func ms_avplayDidEnterBackgroundFunc(notion:NSNotification)
    ///进入前台
    @objc optional func ms_avplayDidBecomeActiveFunc(notion:NSNotification)
    ///开始播放 暂停播放
    @objc optional func MSPlayerPlayOrPauseFunc(play:MSHPlayer , btn:UIButton)
    ///全屏
    @objc optional func MSPlayerFullScreenFunc(play:MSHPlayer , btn:UIButton)
    ///播放完成
    @objc optional func MSPlayerFinishPlayFunc(play:MSHPlayer)
    ///返回
    @objc optional func MSPlayerBackFunc(play:MSHPlayer)
    ///单机屏幕
    @objc optional func MSPlayerSigleTapContentViewFunc(play:MSHPlayer,tap:UITapGestureRecognizer)
    ///播放失败
    @objc optional func MSPlayerFailePlayFunc(play:MSHPlayer)
    ///播放失败
    @objc optional func MSPlayerPushAdFunc(play:MSHPlayer)
}

public class MSHPlayer: UIView {
    
    
    //---
    public var adImageURL:String = ""{
        didSet{
            if adImageURL.count<=0 {
                return
            }
//            self.adImageView.kf.setImage(with: URL.init(string: adImageURL), placeholder: UIImage.init(named: ""), options: [.fromMemoryCacheOrRefresh], progressBlock: nil, completionHandler: nil)
        }
    }
    
    public var showAd:Bool=false{
        didSet{
            if showAd==true && (self.state==MSPlayerStatus.MSPause || self.state==MSPlayerStatus.MSStopped || self.state==MSPlayerStatus.MSFinished){
                self.addSubview(self.adView)
                self.adView.addSubview(self.adImageView)
                self.adView.addSubview(self.adBtn)
                self.adImageView.backgroundColor=UIColor.blue
                self.adView.snp.makeConstraints { (make) in
                    make.top.bottom.left.right.equalToSuperview()
                }
                self.adImageView.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.size.equalTo(CGSize.init(width: self.contentView.bounds.size.width*0.8, height:self.contentView.bounds.size.height*0.8 ))
                }
                self.adBtn.snp.makeConstraints { (make) in
                    make.right.equalTo(self.adImageView).offset(10)
                    make.top.equalTo(self.adImageView).offset(-10)
                    make.size.equalTo(CGSize.init(width: 20, height: 20))
                }
            }
            
        }
    }
    lazy var adView: UIView = {
        let ad=UIView()
        ad.backgroundColor=UIColor.init(white: 0, alpha: 0.3)
//        let tap=UITapGestureRecognizer.init(target: self, action: #selector(tapGestureDismissImageView))
//        ad.addGestureRecognizer(tap)
        
        return ad
    }()
    lazy var adBtn: UIButton = {
        let ad=UIButton()
        ad.addTarget(self, action: #selector(clickAdBtn), for: UIControlEvents.touchUpInside)
        ad.setImage(self.loadingImagePath(name: "YBSAdDel"), for: .normal)
        return ad
    }()
    
    lazy var adImageView: UIImageView = {
        let ad=UIImageView()
        ad.isUserInteractionEnabled=true
        ad.contentMode=UIViewContentMode.scaleAspectFill
        let tap=UITapGestureRecognizer.init(target: self, action: #selector(tapGestureAdImageView))
        ad.addGestureRecognizer(tap)
        return ad
    }()
//---
    
 static var avplayerItemContextValue: UInt32 = 0
 static  let avplayerItemContext: UnsafeMutableRawPointer = UnsafeMutableRawPointer(&avplayerItemContextValue)
    public weak var delegate: MSPlayerDelegate!
    //是否开启进入后台播放
    public var backgroundModel:Bool = false
    
//    let playbacktimeobserver
    ///是否展示上下菜单栏
    public var showTopAndBottomView: Bool = true
    //是否隐藏状态栏
    public var hiddenStatusBar: Bool = false

    //进度条拖拽
    public var isDragingSlider: Bool = false
    ///播放状态
    public var state :MSPlayerStatus?=MSPlayerStatus.MSDefault{
        didSet{
            guard let states = state else { return  }
            if states==MSPlayerStatus.MSBuffering{//缓冲中
                self.loadView.startAnimating()
            }else if states==MSPlayerStatus.MSPlaying{//播放中
                self.loadView.stopAnimating()
            }else if states==MSPlayerStatus.MSPause{//播放失败
                self.loadView.stopAnimating()
            }else{
                self.loadView.stopAnimating()
            }
        
        }
    }
    /// 内容视图
    private lazy var contentView: MSHView={
       let view=MSHView()
        view.backgroundColor=UIColor.black
        return view
    }()
    private lazy var loadView: UIActivityIndicatorView={
        let view=UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        self.contentView.addSubview(view)
        view.startAnimating()
        view.center=self.contentView.center
        return view
    }()
    /// 上菜单栏
    private lazy var topView: UIView={
        let view = UIView()
        view.backgroundColor=UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    ///返回按钮
    private lazy var backBtn:UIButton={
        let btn=UIButton.init(type: UIButtonType.custom)
        btn.setImage(self.loadingImagePath(name: "MSBack"), for: .normal)
        btn.adjustsImageWhenHighlighted=false
        btn.addTarget(self, action: #selector(clickBackBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    ///标题
    private lazy var titleLabel:UILabel={
        let label=UILabel()
        label.font=UIFont .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    ///下菜单栏
    private lazy var bottomView: UIView={
        let view = UIView()
        view.backgroundColor=UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    ///  全屏
    private lazy var fullScreenBtn:UIButton={
        let btn=UIButton.init(type: UIButtonType.custom)
        btn.setImage(self.loadingImagePath(name: "MSFullScreen"), for: .normal)
        btn.adjustsImageWhenHighlighted=false
        btn.addTarget(self, action: #selector(clickFullscreenBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    ///播放
    private lazy var playBtn:UIButton={
        let btn=UIButton.init(type: UIButtonType.custom)
        btn.adjustsImageWhenHighlighted=false
        btn.setImage(self.loadingImagePath(name: "MSPlay"), for: .normal)
        btn.setImage(self.loadingImagePath(name: "MSStop"), for: .selected)
        btn.addTarget(self, action: #selector(clickPlayBtn(btn:)), for: .touchUpInside)
        return btn
    }()
    ///当前时间
    private lazy var curTimeLabel:UILabel={
        let label=UILabel()
        label.font=UIFont .systemFont(ofSize: 12)
        label.textColor=UIColor.white
        label.text="00:00"
        return label
    }()
    ///总共时长
    private lazy var totalTimeLabel:UILabel={
        let label=UILabel()
        label.font=UIFont .systemFont(ofSize: 12)
        label.textAlignment = .right
        label.textColor=UIColor.white
        label.text="00:00"
        return label
    }()
    ///进度滑动条
    private lazy var progressSlider: UISlider={
        let progress=UISlider()
        progress.minimumValue=0.0
        progress.maximumValue=1.0
        progress.minimumTrackTintColor=UIColor.red
        progress.maximumTrackTintColor=UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        progress.backgroundColor=UIColor.init(white: 1, alpha: 0)
        progress.setThumbImage(self.loadingImagePath(name: "MSDot"), for: .normal)
        progress.value=0.0
        progress.addTarget(self, action: #selector(dragSliderProgress(slider:)), for: .valueChanged)
        progress.addTarget(self, action: #selector(updateProgress(slider:)), for: .touchUpInside)
        progress.addTarget(self, action: #selector(updateProgress(slider:)), for: .touchUpOutside)
        progress.addGestureRecognizer(self.progressTap)
        return progress
    }()
    ///加载进度条
    private lazy var loadingProgresss: UIProgressView={
        let progress=UIProgressView()
        progress.progressTintColor=UIColor.white
        progress.trackTintColor=UIColor.init(white: 1, alpha: 0)
        progress.progress=0.0
        return progress
    }()
    ///总共进度条
     private lazy var totalProgresss: UIProgressView={
        let progress=UIProgressView()
        progress.trackTintColor=UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        return progress
    }()
    
    ///总时长
    public var duration:CGFloat?{
        set{
        }
        get{
            let second:CGFloat = CGFloat(CMTimeGetSeconds(self.avplay.currentItem?.asset.duration ?? CMTime.init(value: 0, timescale: 1)))
            return second
        }
    }
    ///当前时长
     public var currentTime:CGFloat?{
        set{
        }
        get{
            return CGFloat(CMTimeGetSeconds(self.avplay.currentTime()))
        }
    }
    public var totalTime:CGFloat = 0.0
    
    
    /// 当前播放item
    public var videoURL:String?{
        didSet{
            guard let url=URL.init(string: videoURL ?? "") else {
                return
            }
            
            if let currentItems = self.currentItem {
                if currentItems != nil {
                    currentItems.removeObserver(self, forKeyPath: "status")
                    currentItems.removeObserver(self, forKeyPath: "loadedTimeRanges")
                    currentItems.removeObserver(self, forKeyPath: "playbackBufferEmpty")
                    currentItems.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
                    currentItems.removeObserver(self, forKeyPath: "duration")
                    currentItems.removeObserver(self, forKeyPath: "presentationSize")
                    self.avplay.removeTimeObserver(self.periodic)
                    self.loadingProgresss.progress=0
                    self.progressSlider.value=0
                    self.totalProgresss.progress=0
                }
            }
            self.currentItem=AVPlayerItem.init(url: url)
            self.currentItem!.addObserver(self, forKeyPath: "status", options: .new, context: MSHPlayer.avplayerItemContext)
            self.currentItem!.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: MSHPlayer.avplayerItemContext)
            self.currentItem!.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: MSHPlayer.avplayerItemContext)
            self.currentItem!.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: MSHPlayer.avplayerItemContext)
            self.currentItem!.addObserver(self, forKeyPath: "duration", options: .new, context: MSHPlayer.avplayerItemContext)
            self.currentItem!.addObserver(self, forKeyPath: "presentationSize", options: .new, context: MSHPlayer.avplayerItemContext)
            
            self.avplay.replaceCurrentItem(with: self.currentItem)
            let second:CGFloat = CGFloat(CMTimeGetSeconds(self.currentItem!.asset.duration))
            self.totalTimeLabel.text="\(self.durationToDate(second: second))"
            NotificationCenter.default.addObserver(self, selector: #selector(MSPlayerDidEnd(notion:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentItem)
            self.addTimer()
        }
    }
    /// 获取当前播放item
    public var currentItem: AVPlayerItem?
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == MSHPlayer.avplayerItemContext {
            if keyPath=="status" {
                let dic:NSDictionary = change! as NSDictionary
                let num:NSNumber=dic.object(forKey: NSKeyValueChangeKey.newKey) as! NSNumber
                let status:AVPlayerItemStatus = AVPlayerItemStatus(rawValue: AVPlayerItem.Status.RawValue(truncating: num)) ?? AVPlayerItemStatus.unknown
                switch status {
                case .unknown://未知
                    self.loadingProgresss.progress=0.0
                    self.state=MSPlayerStatus.MSBuffering
                    self.loadView.startAnimating()
                    break
                case .readyToPlay://准备播放
                    //准备播放的代理
                    self.loadView.stopAnimating()
                    //跳转到指定位置播放
                    if self.seektime > 0 {
                        self.seekToTimePlayVideo(time: self.seektime)
                    }
                    break
                case .failed://加载失败
                    self.state=MSPlayerStatus.MSFaild
                    //加载失败代理方法
                    // 加载失败提示
                    self.loadView.stopAnimating()
                    
                    if self.delegate != nil {
                        delegate.MSPlayerFailePlayFunc?(play: self)
                    }
                    break
                default:
                    break
                    
                }
                
            }else if keyPath=="loadedTimeRanges" {//缓冲进度
                //1 获取当前时间
               let loadedTime = self.availableDurationWithPlayerItem()
                let totalTime = CMTimeGetSeconds(self.currentItem!.duration)
                self.loadingProgresss.progress=Float(loadedTime/totalTime)
                
            }else if keyPath=="playbackBufferEmpty" {//进行跳转后没数据
                self.loadView.stopAnimating()
                if self.currentItem!.isPlaybackBufferEmpty==true {
                    //缓冲回调
                    self.loadedTimeRanges()
                }
            }else if keyPath=="playbackLikelyToKeepUp" {//进行跳转后有数据
                //
                self.loadView.stopAnimating()
                if self.currentItem!.isPlaybackLikelyToKeepUp==true && self.state==MSPlayerStatus.MSBuffering {
                }
            }else if keyPath=="duration" {//时长
                if CGFloat(CMTimeGetSeconds(self.currentItem!.duration)) != self.totalTime {
                    self.totalTime=CGFloat(CMTimeGetSeconds(self.currentItem!.duration))
                   
                    if self.totalTime.isNaN == false{
                        self.progressSlider.maximumValue=Float(self.totalTime)
                    }else{
                        self.totalTime=CGFloat(MAXFLOAT)
                    }
                }
                
            }else if keyPath=="presentationSize" {//视频尺寸大小
                // 返回视频尺寸 代理方法
            }
        }
    }
    // 删除弹框
    @objc func clickAdBtn()  {
        self.adView.removeFromSuperview()
    }
    //
    @objc private func tapGestureDismissImageView()  {
        self.adView.removeFromSuperview()
    }
    //
    @objc private func tapGestureAdImageView()  {
        self.adView.removeFromSuperview()
        //进入
        if self.delegate != nil  {
            self.delegate.MSPlayerPushAdFunc?(play: self)
        }
    }
    //播放完成
    @objc func MSPlayerDidEnd(notion:NSNotification)  {
        self.state=MSPlayerStatus.MSFinished
        if self.delegate != nil {
            delegate.MSPlayerFinishPlayFunc?(play: self)
        }
        
        self.playBtn.isSelected=false
    }
    //缓冲回调
    func loadedTimeRanges() {
        if self.state==MSPlayerStatus.MSPause {
            
        }else{
            self.state=MSPlayerStatus.MSBuffering
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0) {
            if self.state==MSPlayerStatus.MSPlaying ||  self.state==MSPlayerStatus.MSFinished{
                
            }else{
                self.play()
            }
            self.loadView.stopAnimating()
        }
    }
    
    func playerItemDuration() -> CMTime {
        let playerItem:AVPlayerItem=self.currentItem!
        if playerItem.status==AVPlayerItemStatus.readyToPlay {
            return playerItem.duration
        }
       
        return kCMTimeInvalid
    }
    //转换格式
    func converTime(second:CGFloat) -> NSString {
        let date:NSDate = NSDate.init(timeIntervalSince1970: TimeInterval(second))
        if second/3600/24>1{
             return ""
        }else if second/3600>1{
            self.dateFormatter.dateFormat="HH:mm:ss"
            return self.dateFormatter.string(from: date as Date) as NSString
        }else{
            self.dateFormatter.dateFormat="mm:ss"
            return self.dateFormatter.string(from: date as Date) as NSString
        }
    }
    //获取当前时间
    func availableDurationWithPlayerItem() -> TimeInterval {
        guard let loadedTimeRange = self.avplay.currentItem?.loadedTimeRanges, let first = loadedTimeRange.first else {
//            fatalError()
            return 0.0
        }
        let timeRange=first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecond=CMTimeGetSeconds(timeRange.duration)
        let result=startSeconds+durationSecond
        return result
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentItem)
        self.currentItem!.removeObserver(self, forKeyPath: "status")
        self.currentItem!.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.currentItem!.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.currentItem!.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.currentItem!.removeObserver(self, forKeyPath: "duration")
        self.currentItem!.removeObserver(self, forKeyPath: "presentationSize")
        self.avplay.removeTimeObserver(self.periodic)
        self.currentItem=nil
        
    }
    /// player 的 layer
//    private lazy var avplayer: AVPlayerLayer={
//        let layer=AVPlayerLayer.init(player: self.avplay)
//        layer.videoGravity=AVLayerVideoGravity(rawValue: self.videoGravity)
//        return layer
//    }()
    private  var avplayer: AVPlayerLayer!
    
    
    var periodic: Any!
    
    ///播放器
    private lazy var avplay: AVPlayer={
        let play=AVPlayer.init(playerItem: self.currentItem)
        if #available(iOS 10.0, *) {
            play.automaticallyWaitsToMinimizeStalling=false
        } else {
            play.usesExternalPlaybackWhileExternalScreenIsActive=true;
        }
        var session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        } catch  {
            print(error)
        }
        
        return play
    }()
    /// 跳转进度
     private  var seektime:Double = 0.0
    
    ///填充模式
    lazy var videoGravity: String={
        let videog=AVLayerVideoGravity.resizeAspect
        return videog.rawValue
    }()
    //点击视图
    private lazy var tapGesture: UITapGestureRecognizer={
        let tap=UITapGestureRecognizer.init(target: self, action: #selector(tapGestureContentView(tap:)))
        tap.numberOfTouchesRequired=1 //一个指头
        tap.numberOfTapsRequired=1 //单击
        tap.delegate=self
        return tap
    }()
    // 点击进度条手势
    private lazy var progressTap: UITapGestureRecognizer={
        let tap=UITapGestureRecognizer.init(target: self, action: #selector(tapGestureProgressView(tap:)))
        tap.delegate=self
        return tap
    }()
    // 点击进度条
    @objc private func tapGestureProgressView(tap: UITapGestureRecognizer)  {
        let point=tap.location(in: self.progressSlider)
        let value = CGFloat((self.progressSlider.maximumValue-self.progressSlider.minimumValue))*(point.x/self.progressSlider.frame.size.width)
        self.progressSlider.value=Float(value)
        self.totalProgresss.progress=self.progressSlider.value
        self.avplay.seek(to: CMTimeMake(Int64(value), 1), toleranceBefore: CMTimeMake(1, 1000), toleranceAfter: CMTimeMake(1, 1000)) { (finished) in
            self.seektime=0.0
        }
        if self.state==MSPlayerStatus.MSPlaying {
            self.play()
        }
        
    }
    public var isFullScreen: Bool = false
//    {
//        didSet{
//            guard let fullScreen=self.isFullScreen else {
//                return
//            }
//
//
//        }
//    }
    
    // 点击contentView
    @objc private func tapGestureContentView(tap: UITapGestureRecognizer)  {
        UIView.animate(withDuration: 0.5, animations: {
            if self.showTopAndBottomView==true {
                self.showTopAndBottomView=false
                self.hiddenTopAndBottomViewFunc()
            }else{
                self.showTopAndBottomView=true
                self.showTopAndBottomViewFunc()
            }
        }) { (finish) in
            
        }
        if self.delegate != nil {
            delegate.MSPlayerSigleTapContentViewFunc?(play: self, tap: tap)
        }
        
    }
    //展示topView bottomView
    public func showTopAndBottomViewFunc() {
        self.topView.alpha=1.0
        self.bottomView.alpha=1.0
    }
    //隐藏topView bottomView
    public func hiddenTopAndBottomViewFunc() {
        self.topView.alpha=0.0
        self.bottomView.alpha=0.0
    }
    //拖拽进度
   @objc private func dragSliderProgress(slider: UISlider)  {
        self.isDragingSlider=true
    }
    //点击更新进度
    @objc private func updateProgress(slider: UISlider)  {
        self.isDragingSlider=false
        self.avplay.seek(to: CMTimeMake(Int64(slider.value), 1), toleranceBefore: CMTimeMake(1, 1000), toleranceAfter: CMTimeMake(1, 1000)) { (finished) in
            self.seektime=0.0
        }
        
    }
    
    //点击返回按钮
    @objc private func clickBackBtn(btn: UIButton)  {
//        self.isFullScreen=false
        if self.delegate != nil {
           delegate.MSPlayerBackFunc?(play: self)
       }
    }
    //点击全屏按钮
    @objc private func clickFullscreenBtn(btn: UIButton)  {
        btn.isSelected = !btn.isSelected
        if self.delegate != nil {
            delegate.MSPlayerFullScreenFunc?(play: self, btn: btn)
        }
        
    }
    //点击播放按钮
    @objc private func clickPlayBtn(btn: UIButton)  {
        btn.isSelected = !btn.isSelected
        if btn.isSelected==true {
            self.play()
            NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(notion:)), name: .UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(notion:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        }else{
            self.pause()
        }
        if self.delegate != nil {
            delegate.MSPlayerPlayOrPauseFunc?(play: self, btn: btn)
        }
        
    }
    
    ///跳转到指定的位置
    func seekToTimePlayVideo(time: Double)  {
        if seektime > Double(self.totalTime) || seektime<0{
            seektime=0.0
        }
        self.avplay.seek(to: CMTimeMake(Int64(seektime), 1), toleranceBefore: CMTimeMake(1, 1000), toleranceAfter: CMTimeMake(1, 1000)) { (finished) in
            self.seektime=0.0
        }
    }
    ///进入后台
    @objc func appDidEnterBackground(notion:NSNotification) {
        if self.state==MSPlayerStatus.MSFinished {
            return
        }else if self.state==MSPlayerStatus.MSPlaying{
            // 是否允许播放
            if self.backgroundModel==true {
                self.pause()
                self.state=MSPlayerStatus.MSPause
            }else{
                //系统级暂停 --
                self.pause()
                self.state=MSPlayerStatus.MSPause
            }
        }else if self.state==MSPlayerStatus.MSStopped{
            // 系统级暂停 --
        }
        
    }
    ///进入前台
    @objc func appDidBecomeActive(notion:NSNotification) {
        if self.state==MSPlayerStatus.MSFinished {
            if self.backgroundModel==true {
                /// 处理需求
                return
            }else{
                return
            }
        }else if self.state==MSPlayerStatus.MSPlaying{
            // 是否允许播放
            if self.backgroundModel==true {
                self.play()
            }else{
                return
            }
        }else if self.state==MSPlayerStatus.MSStopped{
            return
        }else if self.state==MSPlayerStatus.MSPause{
            self.play()
        }
    }
    ///时间处理
    func durationToDate(second:CGFloat) -> NSString{
        let date = Date.init(timeIntervalSince1970: TimeInterval(second))
        if second/3600/24 >= 1 {
            return ""
        }else if second/3600 >= 1{
            self.dateFormatter.dateFormat="HH:mm:ss"
            return self.dateFormatter.string(from: date) as NSString
        }else{
            self.dateFormatter.dateFormat="mm:ss"
            return self.dateFormatter.string(from: date) as NSString
        }
        
        
    }
    /// 格式处理
    lazy var dateFormatter: DateFormatter={
        let date=DateFormatter()
        date.timeZone=NSTimeZone.init(name: "GMT") as TimeZone?
//        date.timeZone=NSTimeZone.localizedName(<#T##self: NSTimeZone##NSTimeZone#>)
        return date
    }()
    
    func runLoopProgress()  {
       let playDuration = self.playerItemDuration()
       let totalTime = CMTimeGetSeconds(playDuration)
        let curTime = self.currentItem!.currentTime().value/Int64(self.currentItem!.currentTime().timescale)
        self.curTimeLabel.text=self.converTime(second: CGFloat(curTime)) as String
        self.totalTimeLabel.text=self.converTime(second: CGFloat(totalTime)) as String
        
        if totalTime.isNaN {
            self.totalTimeLabel.text=""
        }
        if self.isDragingSlider==false {
            let  value=(self.progressSlider.maximumValue-self.progressSlider.minimumValue)*Float(curTime)/Float(self.totalTime)+self.progressSlider.minimumValue
            self.progressSlider.value=value
            self.totalProgresss.progress=Float(curTime)/Float(self.totalTime)
        }
        
    
    }
    //播放进度
    func addTimer()  {
        self.periodic=self.avplay.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1.0, Int32(NSEC_PER_SEC)), queue: DispatchQueue.main) {[weak self] (time)  in
            self?.runLoopProgress()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor=UIColor.white
        self.topView.addSubview(self.backBtn)
        self.topView.addSubview(self.titleLabel)
        
        self.bottomView.addSubview(self.playBtn)
        self.bottomView.addSubview(self.fullScreenBtn)
        self.bottomView.addSubview(self.totalProgresss)
        self.bottomView.addSubview(self.loadingProgresss)
        self.bottomView.addSubview(self.progressSlider)
        
        self.bottomView.addSubview(self.curTimeLabel)
        self.bottomView.addSubview(self.totalTimeLabel)
        self.addSubview(self.contentView)

        self.contentView.addSubview(self.topView)
        self.contentView.addSubview(self.bottomView)
        
        
        self.avplayer=self.contentView.layer as! AVPlayerLayer
        self.avplayer.player=self.avplay
        self.avplayer.videoGravity=AVLayerVideoGravity(rawValue: self.videoGravity)
        self.contentView.addGestureRecognizer(self.tapGesture)
        self.setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupSubViews()  {
        self.contentView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.topView.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView)
            make.width.equalTo(self.contentView)
            make.height.equalTo(50)
        }
        self.bottomView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.contentView)
            make.width.equalTo(self.contentView)
            make.height.equalTo(50)
        }
        self.backBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.top.equalTo(0)
        }
        self.playBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(self.bottomView)
            make.top.equalTo(self.bottomView)
        }
        self.fullScreenBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.right.equalTo(self.bottomView)
            make.top.equalTo(self.bottomView)
        }
        self.loadingProgresss.snp.makeConstraints { (make) in
            make.left.equalTo(self.playBtn.snp.right).offset(5)
            make.right.equalTo(self.fullScreenBtn.snp.left).offset(-5)
            make.centerY.equalTo(self.playBtn)
            make.height.equalTo(1)
        }
        self.totalProgresss.snp.makeConstraints { (make) in
            make.left.equalTo(self.playBtn.snp.right).offset(5)
            make.right.equalTo(self.fullScreenBtn.snp.left).offset(-5)
            make.centerY.equalTo(self.playBtn)
            make.height.equalTo(1)
        }
        self.progressSlider.snp.makeConstraints { (make) in
            make.left.equalTo(self.playBtn.snp.right).offset(5)
            make.right.equalTo(self.fullScreenBtn.snp.left).offset(-5)
            make.centerY.equalTo(self.playBtn)
            make.height.equalTo(1)
        }
        self.curTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.playBtn.snp.right).offset(5)
            make.top.equalTo(self.totalProgresss.snp.bottom).offset(10)
            make.right.equalTo(self.totalTimeLabel.snp.left)
        }
        self.totalTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.fullScreenBtn.snp.left).offset(-5)
            make.top.equalTo(self.totalProgresss.snp.bottom).offset(10)
            make.left.equalTo(self.curTimeLabel.snp.right)
        }
    }
}
extension MSHPlayer{
   
    ///播放
    @objc public func play() {
        if (self.state==MSPlayerStatus.MSStopped) || (self.state==MSPlayerStatus.MSPause) || (self.state==MSPlayerStatus.MSDefault){
            self.state=MSPlayerStatus.MSPlaying
            self.playBtn.isSelected=true
            self.avplay.play()
        }
    }
    ///暂停
    @objc public func pause() {
        if self.state==MSPlayerStatus.MSPlaying {
            self.state=MSPlayerStatus.MSStopped
        }
        self.avplay.pause()
        self.playBtn.isSelected=false
    }
}
extension MSHPlayer: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view=touch.view else {
            return true
        }
        if view.isKind(of: UIControl.self)==true {
            return false
        }
        return true
    }
}
extension MSHPlayer{
//   @objc func loadingImagePath(name: String) -> String {
//        let path: NSString = "MSPlayer.bundle"
//        return   path.appendingPathComponent(name)//"MSPlayer.bundle"
//    }
    // MARK 获取图片资源
      @objc func loadingImagePath(name: String) -> UIImage {
           let curBundle = Bundle.init(for: MSHPlayer.self)
       let scale = Int(UIScreen.main.scale)
           guard let path = curBundle.path(forResource: "\(name)@\(scale)x.png", ofType: nil, inDirectory: "MSPlayer.bundle") else { return UIImage() }
           return UIImage.init(contentsOfFile: path) ?? UIImage()
       }
}
