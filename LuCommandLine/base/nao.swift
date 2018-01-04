//
//  nao.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

/**
* 网络访问对象（NAO）<br>
* @param <R> 回应的数据类型
* @author BraveLu
*/
class Nao<R> {
	/** 基路径 */
	var baseUrl : String? = ""
	/** 基本参数集 */
	var baseParams : Dictionary<String , Any> =  Dictionary<String , Any>()
	/** the current operation */
	var operation = 0
	
	/** 对查询器进行加工 */
	func processQuerier(_ querier : Querier<R>) -> Querier<R>  {
		// TODO 合并参数集
		if (baseUrl != nil ) {querier.url = baseUrl! + querier.url}
		// 如果指定了分页器，装载分页器
		if let pager = querier.pager {
			//var params = querier.obtainParams()
			pager.fill(&querier.params)
		}
		return querier;
	}
	/** 创建通讯器 */
	func createCommunicator() -> Communicator<R> {return Communicator<R>()}
	/** 通讯器 */
	var communicator : Communicator<R> {
		get {
			return createCommunicator()
			//comm.setReponseClass(m_reponseClass);
		}
	}
	/**
	* 执行操作
	* @param querier
	* @return
	*/
	func execute(_ querier : Querier<R>) -> Int {
		let comm = communicator
		//let _querier = processQuerier(querier)
//		comm.operation = querier.operation
//		//comm.setParams(querier.getParams());
//		if _querier.listener != nil {return comm.send(_querier.url, _querier.params, _querier.listener!)}
//		return comm.send(_querier.url, _querier.params, _querier.fnOnResponse, _querier.fnOnError)
		return comm.send(processQuerier(querier))
	}
}

/**
* 实体操作NAO
* @param <E> 实体操作返回的结果类型
* @author BraveLu
*/
protocol PEntityNao {
	//associatedtype E
	/** 提供编辑UI查询器 */
	func getInputQuerier<T>(_ id : Int) -> Querier<T>
	/** 编辑操作查询器 */
	func getEditQuerier<T>(_ id : Int) -> Querier<T>
	/** 获取详情操作查询器 */
	func getDetailsQuerier<T>(_ id : Int) -> Querier<T>
	/** 删除操作查询器 */
	func getDeleteQuerier<T>(_ id : Int) -> Querier<T>
	/** 取消操作查询器 */
	func getCancelQuerier<T>(_ id : Int) -> Querier<T>
}

class IEntityNao<E> : PEntityNao {
//	let m_fnGetDeleteQuerier : (Int) -> Querier<E>
//	let m_fnGetCancelQuerier : (Int) -> Querier<E>
//	let m_fnGetDetailsQuerier : (Int) -> Querier<E>
//	let m_fnGetEditQuerier : (Int) -> Querier<E>
//	let m_fnGetInputQuerier : (Int) -> Querier<E>
	let delegatee : PEntityNao
	
	init<D: PEntityNao>(_ delegatee: D) /*where D.E == E*/ {
//		m_fnGetDeleteQuerier = delegatee.getDeleteQuerier
//		m_fnGetCancelQuerier = delegatee.getCancelQuerier
//		m_fnGetDetailsQuerier = delegatee.getDetailsQuerier
//		m_fnGetInputQuerier = delegatee.getInputQuerier
//		m_fnGetEditQuerier = delegatee.getEditQuerier
		self.delegatee = delegatee
	}
//	func getDeleteQuerier<T>(_ id : Int) -> Querier<T> {return m_fnGetDeleteQuerier(id)}
//	func getCancelQuerier<T>(_ id : Int) -> Querier<T> {return m_fnGetCancelQuerier(id)}
//	func getDetailsQuerier<T>(_ id : Int) -> Querier<T> {return m_fnGetDetailsQuerier(id)}
//	func getInputQuerier<T>(_ id : Int) -> Querier<T> {return m_fnGetInputQuerier(id)}
//	func getEditQuerier<T>(_ id : Int) -> Querier<T> {return m_fnGetEditQuerier(id)}
	func getDeleteQuerier<T>(_ id : Int) -> Querier<T> {return delegatee.getDeleteQuerier(id)}
	func getCancelQuerier<T>(_ id : Int) -> Querier<T> {return delegatee.getCancelQuerier(id)}
	func getDetailsQuerier<T>(_ id : Int) -> Querier<T> {return delegatee.getDetailsQuerier(id)}
	func getInputQuerier<T>(_ id : Int) -> Querier<T> {return delegatee.getInputQuerier(id)}
	func getEditQuerier<T>(_ id : Int) -> Querier<T> {return delegatee.getEditQuerier(id)}
}

/**
*
* @param <O>
* @author BraveLu
*/
protocol POperationNao : PEntityNao {
	associatedtype O /*where O==E*/
	/** 举报操作查询器 */
	func getOperateQuerier(_ id : Int) -> Querier<O>
}

class IOperationNao<T> : IEntityNao<T> , POperationNao {
	typealias O = T
	typealias E = T
	let m_fnGetOperateQuerier : (Int) -> Querier<T>
	override init<D: POperationNao>(_ delegatee: D) where D.O == T {
		m_fnGetOperateQuerier = delegatee.getOperateQuerier
		super.init(delegatee)
	}
	func getOperateQuerier(_ id : Int) -> Querier<T> {return m_fnGetOperateQuerier(id)}
}

/**
*
* @author BraveLu
* @param <R>
*/
class BaseNao<R> : Nao<R> {
	var tokenAware = true
	override init() {
		super.init()
		baseUrl = Config.BASE_URL
		baseParams["token"] = Config.token
	}
	override func createCommunicator() -> Communicator<R> {
		return BaseCommunicator<R>()
	}
	override func processQuerier(_ querier: Querier<R>) -> Querier<R> {
		let q = super.processQuerier(querier)
		if tokenAware {
			//var params = q.obtainParams()
			//var params = q.params!
			q.params["token"] = Config.token
		}
		return q
	}
}

/**
* 基本实体NAO
* @param <E>
* @author BraveLu
*/
class BaseEntityNao<E> : BaseNao<E> , PEntityNao {
	/**
	* 普通的查询器
	* @param id
	* @param method
	* @return
	*/
	func getCommonQuerier<T>(_ id : Int, _ method : String, _ name : String , _ operation : Int) -> Querier<T> {
		let querier = Querier<T>(method, nil, nil)
		//var p = querier.obtainParams()
		if id != 0 {querier.params["id"] = id}
		querier.name = name
		querier.operation = operation
		return querier
	}
	func getDeleteQuerier<T>(_ id : Int) -> Querier<T> {return getCommonQuerier(id, "!delete" , "删除" , Business.OP_DELETE)}
	func getCancelQuerier<T>(_ id : Int) -> Querier<T> {return getCommonQuerier(id, "!cancel" , "取消" , Business.OP_CANCEl)}
	func getInputQuerier<T>(_ id : Int) -> Querier<T> {return getCommonQuerier(id, "!input" , "输入" , Business.OP_INPUT)}
	func getEditQuerier<T>(_ id : Int) -> Querier<T> {return getCommonQuerier(id, "!edit" , "编辑" , Business.OP_MODIFY)}
	func getDetailsQuerier<T>(_ id : Int) -> Querier<T> {return getCommonQuerier(id, "!details" , "详情" , Business.OP_DETAILS)}
	//func getCommonQuerier<T>(_ id : Int) -> Querier<T> {return Querier<T>()}
}

class OperationNao<T> : BaseEntityNao<T> , POperationNao {
	typealias O = T
	var name = ""
	func getOperateQuerier(_ targetId : Int) -> Querier<T> {
		let querier = Querier<T>("", nil, nil)
		querier.params["targetId"] = targetId
		querier.name = name
		querier.operation = operation
		return querier
	}
}

/** 收藏NAO */
class FavorNao<T> : OperationNao<T> {
	override init() {
		super.init()
		name = "收藏"
		operation = Business.OP_FAVOR
	}
}

/** 评价NAO */
class ReviewNao<T> : OperationNao<T> {
	override init() {
		super.init()
		name = "评价"
		operation = Business.OP_REVIEW
	}
}
