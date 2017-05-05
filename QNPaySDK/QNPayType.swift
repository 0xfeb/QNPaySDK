//
//  QNPayType.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/24.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import Foundation

public struct QNPayType {
	public var key:String
	public var isUrl:Bool?
	public var content:String?
	public var name:String?
	
	public var isIap:Bool {
		return key == "iap"
	}
	
	public init?(dict:[String:Any]) {
		guard let k = dict["pay_type"] as? String else { return nil }
		key = k
		
		if let u = dict["is_url"] as? Int {
			isUrl = u == 1
		}
		
		if let c = dict["content"] as? String {
			content = c
		}
		
		if let n = dict["name"] as? String {
			name = n
		}
	}
	
	public func url(trust:String) -> String? {
		if isUrl == true {
			return QNQuery.shareInstance.trustUrl(trust: trust, payType: key)
		}
		
		return nil
	}
	
	public var dict:[String:Any] {
		var d:[String:Any] = [ "pay_type": key ]
		
		if let isUrl = isUrl {
			d["is_url"] = isUrl
		}
		
		if let content = content {
			d["content"] = content
		}
		
		if let name = name {
			d["name"] = name
		}
		
		return d
	}
}
