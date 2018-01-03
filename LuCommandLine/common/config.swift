//
//  config.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

class Config {
	
	static var token : String = "12345678"
	
	static func getToken() -> String {
		if let t = UserDefaults.standard.value(forKey: "token") {token = t as! String}
		else {token = ""}
		return token
	}
	
	static func saveToken(_ token : String) {
		//self.token = "12333333"
		self.token = token
		UserDefaults.standard.set(token, forKey: "token")
	}
	
	static let BASE_URL = "http://localhost:8080/"
	
}
