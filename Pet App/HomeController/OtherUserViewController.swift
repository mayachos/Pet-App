//
//  OtherUserViewController.swift
//  Pet App
//
//  Created by maya on 2020/10/09.
//

import UIKit
import Firebase

class OtherUserViewController: UIViewController {

    let ref = Database.database().reference()
    var snap: DataSnapshot!
    var userId: String!
    var userProfile = DataSnapshot()
    var adopt: Bool!
    let semaphore = DispatchSemaphore(value: 0)
    @IBOutlet var userName: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var area: UILabel!
    @IBOutlet var heartImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        semaphore.wait()
        if snap != nil {
            let content = userProfile.value as! Dictionary<String, Any>
            adopt = content["adopt"] as? Bool ?? false
            userName.text = content["user"] as? String
            area.text = content["area"] as? String
            address.text = content["address"] as? String
            if adopt {
                heartImage.image = UIImage(named: "pink_heart.png")
            } else {
                heartImage.image = UIImage(named: "empty_heart.png")
            }
        }
    }
    
    func fetchProfile() {
        ref.child("user").child(userId).observe(.value, with: { (snapShot) in
            
            dump(snapShot)
            //if snapShot.children.allObjects is DataSnapshot {
            print("snapShots.children...\(snapShot.childrenCount)") //いくつのデータがあるかプリント
            print("snapShot...\(snapShot)") //読み込んだデータをプリント
            
            self.snap = snapShot
            //}
            self.reload()
        })
        self.semaphore.signal()
    }
    
    func reload() {
        if snap != nil {
            print(snap!)
            userProfile = snap!

            ref.child("user").child(userId).keepSynced(true)
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
