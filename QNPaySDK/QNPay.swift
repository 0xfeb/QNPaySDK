//
//  QNPay.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/21.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import Foundation
import Coastline

public class QNPay {
	public static var shareInstance:QNPay = { QNPay() }()
	
	public var closeButton:UIImage?
	public var baseUrl = "http://laaaa.6655.la:1288"
	public var appKey = "c4ca4238a0b923820dcc509a6f75849b"
	public var appId = 1
	public var originUserId = "1"
	public var iapPassword = "e8be13b9f28045808294e40240deaf95"
	public var headers:[String:String] = [:]
	
	var pay:CLPay = CLPay.shareInstance
	
	var notiBag:CLNotificationBag = CLNotificationBag()
	
	public enum Result {
		case success
		case faild
		case timeout
	}
	
	public func registerQueue(notify: @escaping (Result, QNOrder)->()) {
		let q = QNOrderQueue.shareInstance
		q.check()
		
		_ = pay.register()
		
		NotificationCenter.received(Notification.Name.orderQueueFaild) { (order) in
			//收到订单正确的信息
			notify(.success, QNOrder(dict: order as! [String : Any])!)
		}.addBag(notiBag)
		
		_ = NotificationCenter.received(Notification.Name.orderQueueFaild) { (order) in
			//收到订单错误的信息
			notify(.faild, QNOrder(dict: order as! [String : Any])!)
		}.addBag(notiBag)
		
		_ = NotificationCenter.received(Notification.Name.orderQueueTimeout) { (order) in
			//收到订单错误的信息
			notify(.timeout, QNOrder(dict: order as! [String : Any])!)
		}.addBag(notiBag)
	}
}

public enum QNPayError  : Error{
	case hasNotTrust
	case payChannelNotExists
	case iapError
	case iapCanNotFindReceipt
	case iapReceiptContentError
	case iapReceiptJsonError
}

public extension Notification.Name {
	public static let orderQueueSuccess = "orderQueueSuccess"
	public static let orderQueueFaild = "orderQueueFaild"
	public static let orderQueueTimeout = "orderQueueTimeout"
}
