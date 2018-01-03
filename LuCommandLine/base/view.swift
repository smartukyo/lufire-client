//
//  view.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

/**
* 操作视图
* @param <R> 回应的数据类型
* @author BraveLu
*/
class OpView<R> : PListener {
	func onResponse(_ response : R ,  _ querier : Querier<R>?) -> Void {
		show(response , querier)
	}
	func onError(_ error : Int, _ msg : String , _ querier : Querier<R>?) -> Void {
		print("通讯出错啦！error=\(error),msg=\(msg)");
	}
	func show(_ response : R , _ querier : Querier<R>?) {
		print("〖\(operationName)〗操作成功！操作结果：\(response)");
	}
	/** 操作名称 */
	var operationName : String = ""
}

/**
* 操作视图
* @param <R> 回应的数据类型
* @author BraveLu
*/
class OpViewEx<R> : PListener {
	func onResponse(_ response : R , _ querier : Querier<R>?) -> Void {
		show(response , querier)
	}
	func onError(_ error : Int, _ msg : String ,  _ querier : Querier<R>?) -> Void {
		print("通讯出错啦！error=\(error),msg=\(msg)");
	}
	func show(_ response : R , _ querier : Querier<R>?) {
		print("〖\(querier!.name)\(operationName)〗操作成功！操作结果：\(response)");
	}
	/** 操作名称 */
	var operationName : String {return ""}
}


/**
* 组合视图。内含对实体的操作，以及对实体列表的操作。
* @param <E> 实体/元素操作返回类型
* @param <L> 列表操作返回类型
* @author BraveLu
*/
class ComboView<E, L> {
	class ListView<L> : OpViewEx<L> {
		var outer : ComboView<E, L>
		init(_ outer : ComboView<E, L>) {
			self.outer = outer
			super.init()
		}
		override var operationName : String {return "获取\(outer.entityName)列表"}
		override func show(_ response: L , _ querier : Querier<L>?) {
			super.show(response , querier)
			outer.showList(response)
		}
	}
	class SimpleOpView<E> : OpViewEx<E> {
		var outer : ComboView<E, L>
		init(_ outer : ComboView<E, L>) {
			self.outer = outer
			super.init()
		}
		override var operationName : String {return "\(outer.entityName)"}
		override func show(_ response: E , _ querier : Querier<E>?) {
			super.show(response , querier)
			outer.simpleOperate(response , querier)
		}
	}
	
	func showList(_ response : L) {
		print("asdfasdfasfasdfasdfsdfasdfasdfas")
	}
	func simpleOperate<T>(_ response : E , _ querier : Querier<T>?) {
		switch querier!.operation {
//		case Business.OP_DELETE : print("Delete OK!")
//		case Business.OP_CANCEl : print("Cancel OK!")
//		case Business.OP_INPUT : print("Input OK!")
//		case Business.OP_MODIFY : print("Edit OK!")
//		case Business.OP_DETAILS : print("Details OK!")
		default:
			print("〖\(querier!.name)〗OK!")
		}
	}
	
	/** 实体类型名称 */
	var entityName : String = "实体"
	/** 组合Presenter */
	var comboPresenter : ComboPresenter<E, L>?
	init() {
		listView = ListView<L>(self)
		simpleOpView = SimpleOpView<E>(self)
		comboPresenter = createComboPresenter()
		//listView.operationName = "获取\(entityName)列表"
	}
	/** 分页器 */
	var pager : Pager? = nil
	/** 列表操作视图 */
//	var listView : OpView<L> = OpView<L>()
//	{
//		override var operationName {return "获取\(entityName)列表"}
//	};
	var listView : ListView<L>? = nil
	
	/** 简单操作视图 */
	var simpleOpView : SimpleOpView<E>? = nil
//
//	/** 取消视图 */
//	protected OpView<E> m_cancelView=new OpView<E>() {
//	@Override public String getOperationName() {return "取消"+m_entityName;}
//	};

	//控件变量
	/** 当前操作的实体ID */
	var id = 0

	/** 创建对应的组合Presenter */
	func createComboPresenter() -> ComboPresenter<E, L>? {return nil}
	/** 准备下一页 */
	func increasePage() -> Int {
		if pager==nil {
			pager = Pager(1)
		} else {
			pager!.increase()
		}
		return pager!.page
	}
//	/** 获取列表 */
//	func onCmdList() {
//		var listPresenter = comboPresenter!.listPresenter
//		if (pager != nil) { listPresenter!.pager = pager }
//		//listPresenter!.listener = IListener(listView)
//		listPresenter!.fnOnResponse =  { (response , querier) in
//			if response is ListLeaseOrdersResult {
//				print("回应：;ladfjas;dfasdfasdasf")
//			}
//		}
//		listPresenter!.execute()
//	}
	/** 获取列表 */
	func onCmdList() {
		let listPresenter = comboPresenter!.listPresenter
		if (pager != nil) { listPresenter!.pager = pager }
		listPresenter!.listener = IListener(listView!)
		listPresenter!.execute()
	}
	/** 删除 */
	func onCmdDelete() {comboPresenter?.entityPresenter.delete(id, IListener(simpleOpView!))}
	/** 取消 */
	func onCmdCancel() {comboPresenter?.entityPresenter.cancel(id, IListener(simpleOpView!))}
	/** 编辑UI */
	func onCmdInput() {comboPresenter?.entityPresenter.input(id, IListener(simpleOpView!))}
	/** 编辑 */
	func onCmdEdit() {comboPresenter?.entityPresenter.edit(id, IListener(simpleOpView!))}
	/** 详情 */
	func onCmdDetails() {comboPresenter?.entityPresenter.details(id, IListener(simpleOpView!))}
	/** 执行某项操作 */
	func doCmdOperate(_ operation : Int) {
		let o : OperationPresenter<E>? = comboPresenter?.findOperationPresenter(operation)
		o?.operate(id, IListener(simpleOpView!))
	}
}
