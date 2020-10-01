//
//  UploadViewController.swift
//  Pet App
//
//  Created by maya on 2020/09/27.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit

class UploadViewController: UIViewController {
    
    var setUrl: URL!
    var url: URL!
    private var observers: (NSObjectProtocol)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(setUrl!)
        url = setUrl!
    }
    override func viewDidAppear(_ animated: Bool) {
        //self.playVideo(url: url)
        
        let player = AVPlayer(url: url)
        player.play()
        // AVPlayer用のLayerを生成
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: self.view.bounds.height / 4, width: self.view.bounds.width, height: self.view.bounds.width)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(playerLayer, at: 0) // 動画をレイヤーとして追加
        // 最後まで再生したら最初から再生する
        let playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak playerLayer] _ in
            playerLayer?.player?.seek(to: CMTime.zero)
            playerLayer?.player?.play()
        }
        observers = (playerObserver)
    }
        
    deinit {
        // 画面が破棄された時に監視をやめる
        if let observers = observers {
            NotificationCenter.default.removeObserver(observers)
        }
    }
    
    @IBAction func uploadButton() {
        
        
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
