//
//  order_nao.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

/**
* 订单操作NAO
* @author BraveLu
*/
class OrderNao : BaseEntityNao<Result> {
	override init() {
		super.init()
		baseUrl = Config.BASE_URL+"lease/"
	}
	private static var INSTANCE = OrderNao()
	static func obtainOrderNaoInstance() -> OrderNao {return INSTANCE}
}

class BuyerOrderNao : OrderNao {
	override init() {
		super.init()
		baseUrl = Config.BASE_URL+"lease/lessee/order";
	}
	private static var INSTANCE = BuyerOrderNao()
	static func obtainBuyerOrderNaoInstance() -> BuyerOrderNao {return INSTANCE}
	/** 查询：付款 */
	static func getPayQuerier(_ money : Int) -> Querier<Result> {
		// TODO
		let q = Querier<Result>("!pay", nil, nil)
		//var p = q.obtainParams()
		q.params["money"] = money
		q.params["balanceDeducted"] = false
		return q;
	}
}

class VendorOrderNao : OrderNao {
	static let OPERATION_CHANGE_PAYMENT = 2000
	static let OPERATION_FINISH = 2001
	override init() {
		super.init()
		baseUrl = Config.BASE_URL+"lease/lessor/order";
	}
	private static var INSTANCE = VendorOrderNao()
	static func obtainVendorOrderNaoInstance() -> VendorOrderNao {return INSTANCE}
	override func getEditQuerier(_ id: Int) -> Querier<Result> {
		let operationMethod = operation == VendorOrderNao.OPERATION_CHANGE_PAYMENT ? "changePayment" : "finish"
		return getCommonQuerier(id, "!\(operationMethod)" , "编辑" , /*Business.OP_MODIFY*/operation)
	}
}

/**
* 订单列表操作NAO
* @author BraveLu
*/
class OrderListNao : BaseNao<ListLeaseOrdersResult> {
	override init() {
		super.init()
		baseUrl = Config.BASE_URL+"lease/"
	}
	static var INSTANCE : OrderListNao = OrderListNao()
	static func obtainInstance() -> OrderListNao {return INSTANCE}
	/** 作为买家的订单列表 */
	static func getListAsBuyerQuerier() -> Querier<ListLeaseOrdersResult> {
		// TODO
		return Querier<ListLeaseOrdersResult>("lessee/order", nil, nil);
	}
	/** 作为卖家的订单列表 */
	static func getListAsVendorQuerier() -> Querier<ListLeaseOrdersResult> {
		// TODO
		return Querier<ListLeaseOrdersResult>("lessor/order", nil, nil);
	}
}

/** 收藏订单NAO */
class FavorOrderNao : FavorNao<Result> {
	static private var INSTANCE = FavorOrderNao()
	static func obtainFavorOrderNaoInstance() -> FavorOrderNao {return INSTANCE}
	override init() {
		super.init()
		baseUrl = Config.BASE_URL+"lease/order/favor"
	}
}

/** 评价订单NAO */
class ReviewOrderNao : ReviewNao<Result> {
	static private var INSTANCE = ReviewOrderNao()
	static func obtainReviewOrderNaoInstance() -> ReviewOrderNao {return INSTANCE}
	override init() {
		super.init()
		baseUrl = Config.BASE_URL+"lease/order/review"
	}
}
