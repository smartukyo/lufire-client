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
class OrderView : ComboView<Result, ListLeaseOrdersResult> {
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
	
}


