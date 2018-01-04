//
//  presenter.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

protocol PPresenter {
	var pid : Int {get set}
}

/**
* Presenter<br>
* 相当于业务操作层面的“视图”。
* @param <R> 回应的数据类型
* @author BraveLu
*/
class Presenter<R> : PPresenter {
	/** Presenter ID */
	var pid : Int = 0
	/** 操作类型 */
	var operation : Int = 0
	/** 默认的NAO */
	var nao : Nao<R>? = nil
	/** 默认的监听器 */
	var listener : IListener<R>? = nil
	/** callback blocks */
	var fnOnResponse : FnOnResponse<R>? = nil
	var fnOnError : FnOnError<R>? = nil
	/** 默认的查询器 */
	var querier : Querier<R>? {return nil}
	/**
	* 执行操作
	* @param nao NAO
	* @param querier 查询器
	* @param listener 监听器
	* @return 错误码（表示同步结果）
	*/
	func execute<T>(_ nao : Nao<T> , _ querier : Querier<T> , _ listener : IListener<T> , _ processor : IQuerierProcessor<T>? = nil) -> Int {
		querier.presenter = self
		querier.listener = listener
		var q = querier
		if let p = processor {q = p.processQuerier(querier)}
		nao.operation = operation
		return nao.execute(q)
	}
	/**
	* 执行操作
	* @param nao NAO
	* @param querier 查询器
	* @param listener 监听器
	* @return 错误码（表示同步结果）
	*/
	func execute<T>(_ nao : Nao<T> , _ querier : Querier<T> , _ fnOnResponse : FnOnResponse<T>? , _ fnOnError : FnOnError<T>?) -> Int {
		querier.listener = nil
		querier.fnOnResponse=fnOnResponse
		querier.fnOnError=fnOnError
		return nao.execute(querier)
	}
	/**
	* 执行默认操作
	* @return 错误码（表示同步结果）
	*/
	func execute() -> Int {
		if let l = listener { return execute(nao!, querier!, l)}
		return execute(nao!, querier!, fnOnResponse, fnOnError)
	}
}

/**
* 列表Presenter
* @param <R> 回应的数据类型
* @author BraveLu
*/
class ListPresenter<R> : Presenter<R> {
	/** 分页器 */
	var pager : Pager? = nil
	
	override init() {
		super.init()
		pid = Business.OP_LIST
	}
	override func execute<T>(_ nao : Nao<T> , _ querier : Querier<T> , _ listener : IListener<T> , _ processor : IQuerierProcessor<T>? = nil) -> Int {
		// 为查询器设置分页器（如果有）
		if let pager=self.pager { querier.pager = pager }
		return super.execute(nao, querier, listener);
	}
}

/**
* 组Presenter
* @param <R>
* @author BraveLu
*/
class GroupPresenter<R> : Presenter<R> {
	/** Presenter组 */
	lazy var group = [Int : Any]()
	//public void setGroup(Map<Integer, Presenter<?>> group) {m_group = group;}
//	func obtainGroup() -> Dictionary<Int, Presenter<Any>> {
//		if group==nil {group = createGroup()}
//		return group!
//	}
	/** 创建组 */
	//func createGroup() -> Dictionary<Int, Presenter<AnyClass>> {return Dictionary<Int, Presenter<Any>>()}
	/**
	* 查找内部的Presenter
	* @param pid Presenter ID
	* @return
	*/
	func findPresenter<T>(_ pid : Int) -> Presenter<T>? {
		if let p = group[pid] { return p as! Presenter<T>}
		return nil
	}
	/**
	* 查找内部的Operation Presenter
	* @param pid
	* @return
	*/
	func findOperationPresenter<T>(_ pid : Int) -> OperationPresenter<T>? {
		if let p : Presenter<T> = findPresenter(pid) {return p as! OperationPresenter<T>}
		return nil
	}
	/**
	* 往组内添加一个Presenter
	* @param presenter 其pid不能为空
	*/
	func addPresenter<T>(_ presenter : Presenter<T>) {
		group[presenter.pid] = presenter
	}	
}

/**
* 实体Presenter
* @param <E> 对实体操作的返回类型
* @author BraveLu
*/
class EntityPresenter<E> : GroupPresenter<E> {
	/** 实体对象的ID */
	var id : Int = 0
	/**  */
	var entityNao : IEntityNao<E>? {
		get {
			nao!.operation = operation
			let o : Any? = nao
			//return o as! IEntityNao<E>
			if o is BaseEntityNao<E> {
				return IEntityNao(o as! BaseEntityNao<E>)
			}
			return nil
		}
	}
	/** 删除 */
	func delete(_ id : Int , _ listener : IListener<E>) -> Int {
		return execute(nao!, entityNao!.getDeleteQuerier(id), listener)
	}
	/** 取消 */
	func cancel(_ id : Int , _ listener : IListener<E>) -> Int {
		return execute(nao!, entityNao!.getCancelQuerier(id), listener)
	}
	/** 编辑UI */
	func input(_ id : Int , _ listener : IListener<E> , _ processor : IQuerierProcessor<E>? = nil) -> Int {
		return execute(nao!, entityNao!.getInputQuerier(id), listener , processor)
	}
	/** 编辑 */
	func edit(_ id : Int , _ listener : IListener<E> , _ processor : IQuerierProcessor<E>) -> Int {
		return execute(nao!, entityNao!.getEditQuerier(id), listener, processor)
	}
	/** 获取详情 */
	func details(_ id : Int , _ listener : IListener<E>) -> Int {
		return execute(nao!, entityNao!.getDetailsQuerier(id), listener)
	}
}

/**
* 操作Presenter
* @param <O> “操作”实体操作的返回类型
* @author BraveLu
*/
class OperationPresenter<O> : EntityPresenter<O> {
	/** 目标实体对象ID */
	var targetId : Int = 0
	/**  */
	var operationNao : IOperationNao<O>? {
		get {
			let o : Any? = nao
			//return IOperationNao(nao as! )
			if o is OperationNao<O> {
				return IOperationNao(o as! OperationNao<O>)
			}
			return nil
		}
	}
	/**
	* 操作
	* @param targetId
	* @param listener
	* @return
	*/
	func operate(_ targetId : Int, _ listener : IListener<O>) -> Int {
		return execute(nao!, operationNao!.getOperateQuerier(targetId), listener);
	}
}

/**
* 组合Presenter：包含一个操作实体的Persenter与操作实体列表的Presenter
* @param <E> 列表元素（实体）操作返回的数据类型
* @param <L> 获取列表操作返回的数据类型
* @author BraveLu
*/
class ComboPresenter<E, L> : EntityPresenter<E> {
	/** 列表Presenter */
	var listPresenter : ListPresenter<L>?
	/** 实体Presenter */
	//protected EntityPresenter<E> m_entityPresenter;
	var entityPresenter : EntityPresenter<E> {return self}
	
	override init() {
		super.init()
		listPresenter = createListPresenter()
	}
	/** 创建列表Presenter */
	func createListPresenter() -> ListPresenter<L>? {return nil}
	/** 获取列表 */
	func list() -> Int {
		return listPresenter!.execute()
	}
}

/** 收藏Presenter */
class FavorPresenter<F> : OperationPresenter<F> {
	override init() {
		super.init()
		pid = Business.OP_FAVOR
	}
}

/** 评价Presenter */
class ReviewPresenter<F> : OperationPresenter<F> {
	override init() {
		super.init()
		pid = Business.OP_REVIEW
	}
}
