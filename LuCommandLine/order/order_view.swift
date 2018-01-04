//
//  view.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

/**
* 订单视图
* @author BraveLu
*/
class OrderView : ComboView<Result, ListLeaseOrdersResult, OrderResult> {
	override init() {
		super.init()
		entityName = "订单"
	}
	func getOrderComboPresenter() -> OrderComboPresenter {return comboPresenter as! OrderComboPresenter}
	/** 收藏 */
	func onCmdFavor() {
//		let o : OperationPresenter<Result>? = comboPresenter?.findOperationPresenter(Business.OP_FAVOR)
//		o?.operate(id, IListener(simpleOpView!))
		doCmdOperate(Business.OP_FAVOR)
	}
	/** 评价 */
	func onCmdReview() {
		doCmdOperate(Business.OP_REVIEW)
	}
	/** callback for common operations */
	override func simpleOperate<T>(_ response: T, _ querier: Querier<T>?) {
		switch querier!.operation {
		case Business.OP_FAVOR:
			print("评价评价评价评价评价评价评价评价评价评价评价评价 OK")
		default:
			super.simpleOperate(response, querier)
		}
	}
	/** 删除 */
	override func onCmdDelete() {entityPresenter?.delete(id, IListener(SimpleOpView<DeleteOrderResult>(self)))}
}

/**
* 买家订单视图
* @author BraveLu
*/
class BuyerOrderView : OrderView {
	
//	/** 付款视图 */
//	protected OpView<Result> m_payView=new OpView<Result>() {
//		@Override public String getOperationName() {return "付款";}
//	};
//
//	//Overrides super
//
	override func createComboPresenter() -> ComboPresenter<Result,ListLeaseOrdersResult> {
		return BuyerOrderComboPresenter()
	};

	var getBuyerOrderComboPresenter : BuyerOrderComboPresenter {
		return comboPresenter as! BuyerOrderComboPresenter
	}
//	/** 付款 */
//	public void onCmdPay() {
//		getBuyerOrderComboPresenter().pay(100, m_payView);
//	}
	
	override func showList(_ response: ListLeaseOrdersResult) {
		print("display all orders here!!!!! error=\(response.error)")
	}
	
//	func showListEx(_ response : Any) {
//		var listResult = response as! ListLeaseOrdersResult
//		//listResult.error
//	}
	
	override func processEditQuerier<T>(_ querier: Querier<T>) {
		querier.params["saleItemId"] = 20
		querier.params["payMode"] = 1
	}
	override func processInputQuerier<T>(_ querier: Querier<T>) {
		querier.params["saleItemId"] = 20
	}
}

class VendorOrderView : OrderView {
	override func createComboPresenter() -> ComboPresenter<Result,ListLeaseOrdersResult> {
		return VendorOrderComboPresenter()
	}
	override func processEditQuerier<T>(_ querier: Querier<T>) {
		switch querier.operation {
		case VendorOrderNao.OPERATION_CHANGE_PAYMENT:
			querier.params["orderItem.due"] = 200
		default: //VendorOrderNao.OPERATION_FINISH:
			querier.params["orderItem.due"] = 400
		}
	}
}

