//
//  order.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

/**
* 订单Presenter
* @author BraveLu
*/
class OrderComboPresenter : ComboPresenter<Result, ListLeaseOrdersResult> {
	override init() {
		super.init()
		addPresenter(FavorOrderPresenter())
		addPresenter(ReviewOrderPresenter())
	}
}

/**
* 订单列表Presenter
* @author BraveLu
*/
class OrderListPresenter : ListPresenter<ListLeaseOrdersResult> {
	override init() {
		super.init()
		nao = OrderListNao.obtainInstance()
	}
}

/**
* 买家订单列表操作
* @author BraveLu
*/
class BuyerOrderListPresenter : OrderListPresenter {
	override var querier : Querier<ListLeaseOrdersResult>? {
		get {
			return OrderListNao.getListAsBuyerQuerier()
		}
	}
}

/**
* 买家订单（组合）操作
* @author BraveLu
*/
class BuyerOrderComboPresenter : OrderComboPresenter {
	override func createListPresenter() -> OrderListPresenter {
		return BuyerOrderListPresenter()
	}
	override init() {
		super.init()
		nao = BuyerOrderNao.obtainBuyerOrderNaoInstance()
	}
	/**
	* 付款
	* @param money
	* @param listener
	* @return
	*/
	func pay(_ money : Int, _ listener : IListener<Result>) -> Int {
		return execute(nao!, BuyerOrderNao.getPayQuerier(money), listener);
	}
}

/** 收藏订单Presenter */
class FavorOrderPresenter : FavorPresenter<Result> {
	override init() {
		super.init()
		nao = FavorOrderNao.obtainFavorOrderNaoInstance()
	}
}

/** 收藏订单Presenter */
class ReviewOrderPresenter : ReviewPresenter<Result> {
	override init() {
		super.init()
		nao = ReviewOrderNao.obtainReviewOrderNaoInstance()
	}
}
