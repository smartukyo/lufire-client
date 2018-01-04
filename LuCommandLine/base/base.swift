//
//  base.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

protocol PListener {
	associatedtype R
	func onResponse(_ response : R , _ querier : Querier<R>?) -> Void
	func onError(_ error : Int, _ msg : String , _ querier : Querier<R>?) -> Void
}

typealias FnOnResponse<R> = (_ response : R , _ querier : Querier<R>?) -> Void
typealias FnOnError<R> = (_ error : Int, _ msg : String , _ querier : Querier<R>?) -> Void

class /* should be struct? */ IListener<R> : PListener {
	let m_fnOnResponse : (R , Querier<R>?) -> Void
	let m_fnOnError : (Int , String , Querier<R>?) -> Void
	init<D: PListener>(_ delegatee: D) where D.R == R {
		m_fnOnResponse=delegatee.onResponse
		m_fnOnError=delegatee.onError
	}
	func onResponse(_ response : R , _ querier : Querier<R>?) -> Void {return m_fnOnResponse(response , querier)}
	func onError(_ error : Int, _ msg : String ,  _ querier : Querier<R>?) -> Void {return m_fnOnError(error, msg , querier)}
}

class Communicator<R> {
	//var presenter : PPresenter? = nil
	//var operation : Int = 0
//	func send(_ url : String , _ params : Dictionary<String , Any>? , _ listener : IListener<R>) -> Int {
//		print("准备发送操作数据：URL=\(url)，参数=\(params)");
//		//var response : R? = nil
//		//var response : R? = ListLeaseOrdersResult() as! R
//		var response : R? = Result() as! R
//		listener.onResponse(response!, presenter , operation)
//		//listener.onError(1, "error message")
//		return 0;
//	}
//	func send(_ url : String , _ params : Dictionary<String , Any>? , _ fnOnResponse : FnOnResponse<R>? , _ fnOnError : FnOnError?) -> Int {
//		print("准备发送操作数据：URL=\(url)，参数=\(params)");
//		//var response : R? = nil
//		var response : R? = ListLeaseOrdersResult() as! R
//		fnOnResponse!(response!)
//		//fnOnError!(1, "error message")
//		return 0;
//	}
	var querier : Querier<R>? = nil
	func send(_ querier : Querier<R>) -> Int {
		self.querier = querier
		print("准备发送操作数据：URL=\(querier.url)，参数=\(querier.params)");
		//var response : R? = nil
		//var response : R? = ListLeaseOrdersResult() as! R
		var response : R?
		if (querier.presenter?.pid == Business.OP_LIST) {response = ListLeaseOrdersResult() as! R}
		else if (querier.operation == Business.OP_INPUT) {response = OrderResult() as! R}
		else if (querier.operation == Business.OP_DELETE) {response = DeleteOrderResult() as! R}
		else {response = Result() as! R}
		//let c = type(of:R.self)
		//print("\(c)")
		//let x = R.init()
		return onResponse(response);
	}
	func getResult(_ response : R?) -> Result? {
		if (response is Result) {
			return response as? Result
		}
		return nil;
	}
	func onResponse(_ response : R?) -> Int {
		var error = 0 , msg = ""
		if let result = getResult(response) {
			if (result.error == 0) {//success
				if let l = querier?.listener { l.onResponse(response! , querier)}
				else {querier?.fnOnResponse!(response!, querier)}
			} else {//operation error
				error = result.error
				msg = result.desc
			}
		} else {//communication error
			error = -1
		}
		
		if (error != 0) {//error
			if let l = querier?.listener {l.onError(error, msg, querier)}
			else {querier?.fnOnError!(error, msg, querier)}
		}
		
		return error;
	}
}

/**
* 分页器
* @author BraveLu
*/
class Pager {
	/** 页码 */
	var page : Int = 0
	/** 每页长度。0将被忽略。 */
	var pageSize : Int = 0
	/** 填充量，表示待获取记录之前实际被删除的元素数目 */
	var pad : Int = 0
	
	init() {}
	init(_ page : Int) {
		self.page = page;
	}
	init(_ page : Int , _ pageSize : Int) {
		self.page = page;
		self.pageSize = pageSize;
	}
	/**
	* 增加一页
	* @return
	*/
	func increase() -> Int {
		page += 1
		return page
	}
	/**
	* 填充到参数集中
	* @param params 参数集
	*/
	func fill(_ params : inout Dictionary<String , Any>) {
		params["pager.page"] = page
		if (pageSize > 0) { params["pager.pageSize"] = pageSize }
		if (pad != 0) { params["pager.pad"] = pad }
	}
	
}

/**
* 网络查询器<br>
* 指明操作信息，如URL、参数等。
* @param <R> 回应的数据类型
* @author BraveLu
*/
class Querier<R> {
	/** 操作的URL */
	var url : String = ""
	/** 标志 */
	var flags : Int = 0
	/** 监听器/回调 */
	var listener : IListener<R>? = nil
	
	var fnOnResponse : FnOnResponse<R>? = nil
	var fnOnError : FnOnError<R>? = nil
	
	/** 参数集 */
	//var params : Dictionary<String , Any>? = nil
	lazy var params = [String: Any]()
//	func obtainParams() -> [String : Any] {
//		if (params==nil) {
//			//params = Dictionary<String , Any>()
//			params = [String: Any]()
//		}
//		return params!
//	}
	/** 分页器 */
	var pager : Pager? = nil
	
	var presenter : PPresenter? = nil
	var operation : Int = 0
	var name = ""
	
	init() {
		
	}
	init(_ url : String , _ params : Dictionary<String , Any>? , _ listener : IListener<R>?) {
		self.url = url
		if let p = params {self.params = p}
		self.listener = listener
	}
	init(_ url : String , _ params : Dictionary<String , Any>? , _ fnOnResponse : FnOnResponse<R>? , _ fnOnError : FnOnError<R>?) {
		self.url = url
		if let p = params {self.params = p}
		self.fnOnResponse = fnOnResponse
		self.fnOnError = fnOnError
	}
}

/**
* 查询器加工器
* @param <R>
* @author BraveLu
*/
protocol PQuerierProcessor {
	associatedtype R
	/** 对查询器进行加工 */
	func processQuerier(_ querier : Querier<R>) -> Querier<R>
}

/** 查询器加工器 */
class IQuerierProcessor<R> : PQuerierProcessor {
	let m_fnProcessQuerier : (Querier<R>) -> Querier<R>
	init<D: PQuerierProcessor>(_ delegatee: D) where D.R == R {m_fnProcessQuerier=delegatee.processQuerier}
	func processQuerier(_ querier : Querier<R>) -> Querier<R> {return m_fnProcessQuerier(querier)}
}

class BaseCommunicator<R> : Communicator<R> {
	override func onResponse(_ response : R?) -> Int {
		if response is Result {
			let result = response as! Result
			if result.token != "" {Config.saveToken(result.token)}
		}
		return super.onResponse(response)
	}
}

class BaseListener<R> : PListener {
	func onResponse(_ response : R , _ querier : Querier<R>?) -> Void {
		return print("Success:")
	}
	func onError(_ error : Int, _ msg : String , _ querier : Querier<R>?) -> Void {
		return print("Error:\(error),\(msg)")
	}
}

class ListListener : BaseListener<Int> {
	
}
