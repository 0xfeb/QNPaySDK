//
//  QNOrderQueue.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/24.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import UIKit

public class QNOrderQueue {
	public static var shareInstance:QNOrderQueue = { QNOrderQueue() }()
	
	public var waitingList:[QNOrder] = []
	public var updateStateEvent:(QNOrder, String)->() = { _ in }
	
	init() {}
	
	func loadList() {
		let ud = UserDefaults.standard
		if let list = ud.array(forKey: "order_queue_list") as? [[String:String]] {
			waitingList = list.flatMap{ QNOrder(dict: $0) }
		}
	}
	
	func saveList() {
		let ud = UserDefaults.standard
		let list = waitingList.map{ $0.dict }
		ud.set(list, forKey: "order_queue_list")
		ud.synchronize()
	}
	
	func remove(orderId:String) {
		if let index = waitingList.oneIndex({ $0.create?.orderId == orderId }) {
			waitingList.remove(at: index)
			
			saveList()
		}
	}
	
	func checkState(order:QNOrder) {
		guard let oid = order.create?.orderId else { return }
		
		let q = QNQuery.shareInstance
		q.orderCheck(orderId: oid) {  [weak self, order, oid] (dict, error) in
			if let dict = dict, let data = dict["data"] as? [String:Any], let status = data["status"] as? String {
				self?.updateStateEvent(order, status)
				
				guard let state = Int(status) else { return }
				
				if state == 9 {
					NotificationCenter.send(Notification.Name.orderQueueSuccess, userInfo: order.dict)
					self?.remove(orderId: oid)
				} else if state > 9 {
					NotificationCenter.send(Notification.Name.orderQueueFaild, userInfo: order.dict)
					self?.remove(orderId: oid)
				}
			}
		}
	}
	
	var checkTimer:Timer?
	
	public func check() {
		checkTimer?.invalidate()
		checkTimer = Timer(timeInterval: 10.0, target: self, selector: #selector(checkAction), userInfo: nil, repeats: true)
	}
	
	@objc func checkAction() {
		waitingList.forEach {
			checkState(order: $0)
		}
	}
	
	public func create(originOrderId:String, content:String, price:Int, payTypes:[String]?, resp:@escaping (QNOrder?, [QNPayType], Error?)->()) {
		let q = QNQuery.shareInstance
		q.orderNew(appId: QNPay.shareInstance.appId, originOrderId: originOrderId, uid: QNPay.shareInstance.originUserId, data: content, price: price, payType: payTypes) { (dict, error) in
			guard let dict = dict, let data = dict["data"] as? [String:Any], let code = dict["code"] as? Int, code == 200 else {
				resp(nil, [], error)
				return
			}
			
			let start = QNOrder.Start(appId: QNPay.shareInstance.appId, originOrderId: originOrderId, uid: QNPay.shareInstance.originUserId, content: content, price: price)
			var order = QNOrder(start: start)
			
			if let orderId = data["order_id"] as? String, let trust = data["trust"] as? String, let pt = data["pay"] as? [[String:Any]] {
				let create = QNOrder.Create(orderId: orderId, trust: trust)
				order.create = create
				let pts = pt.flatMap{ QNPayType(dict:$0) }
				
				if pts.count == 0 {
					resp(order, pts, QNPayError.payChannelNotExists)
				} else {
					resp(order, pts, error)
				}
			}
		}
	}
	
	public func pay(order:QNOrder, payType:String, receipt:String?, resp:@escaping (Error?)->()) {
		guard let trust = order.create?.trust else {
			resp(QNPayError.hasNotTrust)
			return
		}
		
		let q = QNQuery.shareInstance
		q.orderPay(content: trust, payType: payType, receipt: receipt) { [weak self] (dict, error) in
			guard let dict = dict, let code = dict["code"] as? Int, code == 200 else {
				resp(error)
				return
			}
			
			self?.waitingList.append(order)
			resp(nil)
		}
	}
	
	public func trustPay(order:QNOrder, payType:String, container:UIViewController) -> Bool {
		guard let trust = order.create?.trust else { return false }
		
		let q = QNQuery.shareInstance
		let urlString = q.trustUrl(trust: trust, payType: payType)
		guard let url = urlString.url else { return false }
		
		let wv = QNWebVC()
		container.present(wv, animated: true) { 
			wv.load(url: url)
		}
		return true
	}
}
