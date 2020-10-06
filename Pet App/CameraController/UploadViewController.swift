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
import Firebase

class UploadViewController: UIViewController {
    
    let refDatabase = Database.database().reference()
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    let userDefaults = UserDefaults.standard
    
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
        if let user = user {
            let storageRef = storage.reference(forURL: "gs://pet-app-8ad40.appspot.com")
            let timeLineDB = refDatabase.child("timeline")
            let key = timeLineDB.child("video").childByAutoId().key
            
            let movieRef = storageRef.child("video").child(String(describing: key!) + ".mp4")
            
            let uploadTask = movieRef.putFile(from: url, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    //error
                    print("Uh-oh, an error occurred!")
                    return
                }
                let size  = metadata.size
                movieRef.downloadURL{ (url, error) in
                    
                    if url != nil {
                        let post = ["uid" : user.uid,
                                    "author" : user.displayName as Any,
                                    //"profileImage" : user.photoURL as Any,
                                    "videoURL" : url!.absoluteString as Any,
                                    //"transfer" : ,
                                    "postDate" : ServerValue.timestamp()] as [String : Any]
                        //databaseに送信
                        timeLineDB.updateChildValues(post)
                    }
                    guard let downloadURL = url else {
                        //error
                        print("Uh-oh, an error occurred!")
                        return
                    }
                }
            }
            uploadTask.resume()
        }
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
