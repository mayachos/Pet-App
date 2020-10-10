//
//  StartViewController.swift
//  Pet App
//
//  Created by maya on 2020/10/04.
//

import UIKit
import Firebase
import FirebaseAuth


class StartViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    var userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
        nameTextField.placeholder = "表示名"
        emailTextField.placeholder = "メールアドレス"
        passwordTextField.placeholder = "パスワード"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButton() {
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if name == "" || email == "" || password == "" {
            displayMyAlertMessage(userMessage: "全てのフォームに入力してください")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let user = result?.user {
                let req = user.createProfileChangeRequest()
                req.displayName = name
                req.commitChanges() { [weak self] error in
                    guard let self = self else { return }
                    if error == nil {
                        user.sendEmailVerification() {[weak self] error in
                            guard let self = self else { return }
                            if error == nil {
                                self.displayMyAlertMessage(userMessage: "登録が完了しました")
                                //仮登録画面処理に遷移
                                
                                let ref = Database.database().reference()
                                let userDB = ref.child("user").child(user.uid)
                                let post = ["user" : user.displayName as Any,
                                            "adopt" : false,
                                            "area": "",
                                            "address": ""] as [String : Any]
                                userDB.setValue(post)
                                self.userDefaults.set(false, forKey: "adopt")
                                self.dismiss(animated: true, completion: nil)
                            }
                            self.showErrorIfNeeded(error)
                        }
                    }
                    self.showErrorIfNeeded(error)
                }
            }
            self.showErrorIfNeeded(error)
        }
        
    }
    
    private func showErrorIfNeeded(_ errorOnNil: Error?) {
        //error処理
        guard let error = errorOnNil else { return }
        
        let message = "エラーが起きました"
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
 

    private func errorMessage(of error: Error) -> String {
        var message = "エラーが発生しました"
        guard let errcd = AuthErrorCode(rawValue: (error as NSError).code) else {
            return message
        }
        
        switch errcd {
        case .networkError: message = "ネットワークに接続できません"
        case .userNotFound: message = "ユーザが見つかりません"
        case .invalidEmail: message = "不正なメールアドレスです"
        case .emailAlreadyInUse: message = "このメールアドレスは既に使われています"
        case .wrongPassword: message = "入力した認証情報でサインインできません"
        case .userDisabled: message = "このアカウントは無効です"
        //case .weakPassword: message = "パスワードが脆弱すぎます"
        // これは一例です。必要に応じて増減させてください
        default: break
        }
        return message
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
