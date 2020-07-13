//
//  DetailViewController.swift
//  TaskByMobiotics
//
//  Created by Kap's on 11/07/20.
//

import UIKit
import AVKit
import Alamofire
import AlamofireImage

class DetailViewController: UIViewController, AVPlayerViewControllerDelegate {

    @IBOutlet weak var thumbCumPlayerView: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var shirnkButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var minDuration: UILabel!
    @IBOutlet weak var maxDuration: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var player      = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var videoData   : DataModel?
    var modelData   : [DataModel]?
    var videoPlayerLabel: UILabel = UILabel()
    var nextURL = [String]()
    
    var id              = [String]()
    var urlData         = [String]()
    var thumbData       = [String]()
    var titleData       = [String]()
    var descriptionData = [String]()
    
// MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getDefaults()
        self.setupPlayerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
// MARK: - Functions
    func getDefaults() {
        self.id = UserDefaults.standard.value(forKey: "id") as! [String]
        self.urlData = UserDefaults.standard.value(forKey: "urlData") as! [String]
        self.thumbData = UserDefaults.standard.value(forKey: "thumbData") as! [String]
        self.titleData = UserDefaults.standard.value(forKey: "titleData") as! [String]
        self.descriptionData = UserDefaults.standard.value(forKey: "descriptionData") as! [String]
    }
    
    func setupPlayerView() {
        
        self.configureAVPlayer(videoString: videoData!.url)
        self.updateLabelforSelectedVideo(with: videoData!.title, vDescription: videoData!.description)
        
        self.configureSlider()
        
        let interval = CMTime(value: 1, timescale: 2)
        self.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { (progressTime) in
            let seconds  = CMTimeGetSeconds(progressTime)
            let sringSecond = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
            let sringMinute = String(format: "%02d", Int(seconds / 60))
            
            self.minDuration.text = "\(sringMinute):\(sringSecond)"
            
            if let duration = self.player.currentItem?.duration {
                let durationSeconds  = CMTimeGetSeconds(duration)
                self.playerSlider.value = Float(seconds / durationSeconds)
            }
        }
    }
    
    @objc func handleSliderChange() {
        if let duration = player.currentItem?.duration {
            let totalSeconds  = CMTimeGetSeconds(duration)
            let value = Float64(playerSlider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player.seek(to: seekTime) { (completedSeek) in
            }
        }
    }
    
    func updateLabelforSelectedVideo(with vTitle: String, vDescription:String) {
        self.videoTitle.text = vTitle
        self.videoDescription.text = vDescription
    }
    
    func configureAVPlayer(videoString : String) {
        if player.currentItem == nil {
            if let url = URL(string: videoString) {
                self.setAVPlayer(url: url)
            }
            self.player.actionAtItemEnd = .none
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: self.player.currentItem)
        } else {
            let url = URL(string: videoString)
            self.setAVPlayer(url: url!)
            self.configureSlider()
            self.player.play()
        }
    }
    
    func setAVPlayer(url : URL) {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        
        self.playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.thumbCumPlayerView.bounds
        playerLayer.videoGravity = .resizeAspect
        self.thumbCumPlayerView.layer.addSublayer(playerLayer)
    }
    
    func configureButtons() {
        if self.playButton.isHidden {
            self.player.pause()
            self.playButton.isHidden = false
            self.pauseButton.isHidden = true
        } else {
            self.player.play()
            self.playButton.isHidden = true
            self.pauseButton.isHidden = false
        }
    }
    
    func configureSlider() {
        self.playerSlider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        self.player.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
                if #available(iOS 10.0, *) {
                    let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
                    let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
                    if newStatus != oldStatus {
                       DispatchQueue.main.async {[weak self] in
                           if newStatus == .playing || newStatus == .paused {
                            self!.activityIndicator.stopAnimating()
                           } else {
                            self!.activityIndicator.startAnimating()
                           }
                       }
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
        
        if keyPath == "currentItem.loadedTimeRanges" {
            self.activityIndicator.stopAnimating()
            
            if let duration = player.currentItem?.duration {
                let seconds  = CMTimeGetSeconds(duration)
                let secondsText = seconds.truncatingRemainder(dividingBy: 60)
                let minutesText = String(format: "%02d", Int(seconds)/60)
                self.maxDuration.text = "\(minutesText):\(Int(secondsText))"
                
            }
        }
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        print("Player item finished playing")
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
    
// MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.configureButtons()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        configureButtons()
    }
    
    @IBAction func pauseButtonTapped(_ sender: Any) {
        self.configureButtons()
    }
    
    @IBAction func fullScreenTapped(_ sender: Any) {
        //self.configureButtons()
        self.expandButton.isHidden = true
        self.shirnkButton.isHidden = false
        self.view.layer.addSublayer(playerLayer)
        playerLayer.frame = self.view.layer.bounds
        self.thumbCumPlayerView.isHidden = true
        self.tableView.isHidden = true
        self.playerSlider.isHidden = true
    }
    
    @IBAction func shirnkButtonTapped(_ sender: Any) {
        self.expandButton.isHidden = false
        self.shirnkButton.isHidden = true
        self.thumbCumPlayerView.layer.addSublayer(playerLayer)
        playerLayer.frame = self.thumbCumPlayerView.layer.bounds
        self.thumbCumPlayerView.isHidden = false
        self.tableView.isHidden = false
        self.playerSlider.isHidden = false
    }
}

// MARK: - Table View Extension
extension DetailViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName = "Related Videos..."
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (thumbData.count)-1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "relatedCell")! as! RelatedVideosCell
        if videoData?.id != id[indexPath.row] {
            cell.relatedTitle?.text = titleData[indexPath.row]
            cell.relatedDescription?.text = descriptionData[indexPath.row]
            
            Alamofire.request("\(self.thumbData[indexPath.row])").responseImage { response in
                if case .success(let image) = response.result {
                    DispatchQueue.main.async {
                        cell.relatedThumb.image = image
                    }
                } else {
                    print("Could not load image for cell")
                }
            }
            
            self.nextURL.append(thumbData[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.player.rate = 0.0
        self.playerLayer.removeFromSuperlayer()
        self.playButton.isHidden = true
        self.pauseButton.isHidden = false
        self.configureButtons()
        self.configureAVPlayer(videoString: urlData[indexPath.row])
        self.updateLabelforSelectedVideo(with: titleData[indexPath.row], vDescription: descriptionData[indexPath.row])
                
        self.tableView.reloadData()
    }
}

