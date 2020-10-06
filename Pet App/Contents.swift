//
//  File.swift
//  Pet App
//
//  Created by maya on 2020/10/06.
//

import Foundation

class Contents {
    var userNameString: String = ""
    //var profileImageString: String = ""
    var videoString: String = ""
    var postDateString: String = ""
    //var Transfer: Bool = false
    
    init (userNameString: String,videoString: String,postDateString: String){
        self.userNameString = userNameString
        //self.profileImageString = profileImageString
        self.videoString = videoString
        self.postDateString = postDateString
        //self.Transfer = Transfer
    }
}
