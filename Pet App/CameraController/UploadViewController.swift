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
import FirebaseFirestore

class UploadViewController: UIViewController {
    
    let refDatabase = Database.database().reference()
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    var userDefaults = UserDefaults.standard
    //let userDefaults = UserDefaults.standard
    @IBOutlet var uploadB: UIButton!
    
    var setUrl: URL!
    var url: URL!
    private var observers: (NSObjectProtocol)?
    var loadComplete: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uploadB.layer.cornerRadius = 10
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
            let timeLineDB = refDatabase.child("timeline").childByAutoId()
            guard let key = timeLineDB.childByAutoId().key else { return }
            let adopt = userDefaults.bool(forKey: "adopt")
            
            let movieRef = storageRef.child(String(describing: key) + ".mp4")
            
            let uploadTask = movieRef.putFile(from: url, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    //error
                    print("Uh-oh, an error occurred!")
                    return
                }
                let size = metadata.size
                movieRef.downloadURL{ (url, error) in
                    
                    if url != nil {
                        let postT = ["uid" : user.uid,
                                    "author" : user.displayName as Any,
                                    //"profileImage" : user.photoURL as Any,
                                    "videoURL" : url!.absoluteString as Any,
                                    "adopt" : adopt,
                                    "postDate" : ServerValue.timestamp(),
                                    "key" : key,
                                    "good" : 0] as [String : Any]
                        let postU = ["videoURL" : url!.absoluteString as Any,
                                     "postDate" : ServerValue.timestamp(),
                                     "good" : 0]
                        let childUpDates = ["/timeline/\(key)" : postT,
                                            "/user/\(user.uid)/video/\(key)" : postU]
                        //databaseに送信
                        self.refDatabase.updateChildValues(childUpDates)
                    }
                    guard let downloadURL = url else {
                        //error
                        print("Uh-oh, an error occurred!")
                        return
                    }
                }
            }
            uploadTask.resume()
            dismiss(animated: true, completion: nil)
        }
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
