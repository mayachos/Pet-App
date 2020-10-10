//
//  UserViewController.swift
//  Pet App
//
//  Created by maya on 2020/10/02.
//

import UIKit
import Firebase

class UserViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var ref: DatabaseReference!
    var snap: DataSnapshot!
    var userDefaults = UserDefaults.standard
    let semaphore = DispatchSemaphore(value: 0)
    
    let user = Auth.auth().currentUser
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var heartImage: UIImageView!
    @IBOutlet var addressField: UITextField!
    @IBOutlet var picker: UIPickerView!
    @IBOutlet var areaLabel: UILabel!
    @IBOutlet var switchButton: UISwitch!
    @IBOutlet var areaTextLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var userProfile = DataSnapshot()
    var adopt: Bool = false
    var area: String = ""
    var address: String = ""
    
    let areaArray: [String] = ["","北海道","青森県","岩手県","宮城県","秋田県","山形県","福島県","茨城県","栃木県","群馬県","埼玉県","千葉県","東京都","神奈川県","新潟県","富山県","石川県","福井県","山梨県","長野県","岐阜県","静岡県","愛知県","三重県","滋賀県","京都府","大阪府","兵庫県","奈良県","和歌山県","鳥取県","島根県","岡山県","広島県","山口県","徳島県","香川県","愛媛県","高知県","福岡県","佐賀県","長崎県","熊本県","大分県","宮崎県","鹿児島県","沖縄県"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        ref = Database.database().reference()
        self.fetchProfile()
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            //let uid = user.uid
            let userName = user.displayName
            //let email = user.email
            let photoURL = user.photoURL
            
            nameTextField.text = userName
            //profileImage.image = getImageByUrl(url: photoURL!)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areaArray.count
    }
    // UIPickerViewの最初の表示
        func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
            
            return areaArray[row]
        }
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        area = areaArray[row]
        areaLabel.text = area
    }
    
    override func viewDidAppear(_ animated: Bool) {
        semaphore
        if snap != nil {
            let content = userProfile.value as! Dictionary<String, Any>
            adopt = content["adopt"] as? Bool ?? false
            area = content["area"] as? String ?? ""
            address = content["address"] as? String ?? ""
            self.adoptJuddge(juddge: adopt)
            switchButton.isOn = adopt
        }
    }
    
    func fetchProfile() {
        ref.child("user").child(user!.uid).observe(.value, with: { (snapShot) in
            
            dump(snapShot)
            //if snapShot.children.allObjects is DataSnapshot {
            print("snapShots.children...\(snapShot.childrenCount)") //いくつのデータがあるかプリント
            print("snapShot...\(snapShot)") //読み込んだデータをプリント
            
            self.snap = snapShot
            //}
            self.reload()
        })
        semaphore.signal()
    }
    
    func reload() {
        if snap != nil {
            print(snap!)
            userProfile = snap!

            ref.child("user").child(user!.uid).keepSynced(true)
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        self.adoptJuddge(juddge: sender.isOn)
    }
    
    func adoptJuddge(juddge: Bool) {
        if juddge {
            adopt = true
            heartImage.image = UIImage(named: "pink_heart.png")
            addressField.isHidden = false
            picker.isHidden = false
            areaLabel.text = area
            addressField.text = address
            areaTextLabel.text = "地域"
            addressLabel.text = "連絡先"
        } else {
            adopt = false
            heartImage.image = UIImage(named: "empty_heart.png")
            addressField.isHidden = true
            picker.isHidden = true
            areaLabel.text = ""
            areaTextLabel.text = ""
            addressLabel.text = ""
            area = ""
            address = ""
        }
    }
    
    @IBAction func logOutButton() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func saveProfile() {
        let userDB = ref.child("user").child(user!.uid)
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        if nameTextField.text != "" {
            changeRequest?.displayName = nameTextField.text
            address = addressField.text ?? ""
            let post = ["user" : user?.displayName as Any,
                        "adopt" : adopt as Any,
                        "area": area as Any,
                        "address": address as Any] as [String : Any]
            userDB.setValue(post)
            userDefaults.set(adopt, forKey: "adopt")
            displayMyAlertMessage(userMessage: "保存しました")
        } else {
            errorAlert()
        }
    }

    func errorAlert() {
        displayMyAlertMessage(userMessage: "名前を入力してください")
    }
    
    func getImageByUrl(url: URL) -> UIImage{
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
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
