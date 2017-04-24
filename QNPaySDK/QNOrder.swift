//
//  QNOrder.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/24.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import Foundation

public struct QNOrder {
	public struct Start {
		public var appId:Int
		public var originOrderId:String
		public var uid:String
		public var content:String
		public var price:Int
	}
	
	public struct Create {
		public var orderId:String
		public var trust:String
	}
	
	public struct Processing {
		public var payType:QNPayType
	}
	
	public struct Receipt {
		public var receipt:String
	}
	
	public var status:Int
	public var start:Start
	public var create:Create?
	public var processing:Processing?
	public var receipt:Receipt?
	
	public init(start s:Start) {
		status = 0
		start = s
	}
	
	public init?(dict:[String:Any]) {
		guard let ai = dict["appId"] as? Int, let ooi = dict["originOrderId"] as? String, let ui = dict["uid"] as? String, let c = dict["content"] as? String, let p = dict["price"] as? Int, let s = dict["status"] as? Int else  { return nil }
		
		status = s
		start = Start(appId: ai, originOrderId: ooi, uid: ui, content: c, price: p)
		
		if let oi = dict["orderId"] as? String, let t = dict["trust"] as? String {
			create = Create(orderId: oi, trust: t)
		}
		
		if let pc = dict["pay_type"] as? [String:Any], let pt = QNPayType(dict: pc) {
			processing = Processing(payType: pt)
		}
		
		if let rc = dict["receipt"] as? String {
			receipt = Receipt(receipt: rc)
		}
	}
	
	public var dict:[String:Any] {
		var d:[String:Any] = [
			"appId" : start.appId,
			"originOrderId" : start.originOrderId,
			"uid": start.uid,
			"content": start.content,
			"price": start.price
		]
		
		d["status"] = status
		
		if let create = create {
			d["orderId"] = create.orderId
			d["trust"] = create.trust
		}
		
		if let processing = processing {
			d["pay_type"] = processing.payType.dict
		}
		
		if let receipt = receipt {
			d["receipt"] = receipt.receipt
		}
		
		return d
	}
}
