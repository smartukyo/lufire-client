//
//  results.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2018/1/1.
//  Copyright © 2018年 Brave Lu. All rights reserved.
//

import Foundation

/**
* 业务操作结果
* @author BraveLu
*/
class Result {
	var error : Int = 0
	var desc : String = ""
	var token : String = "47754564756546346"
}

class ListResult : Result {
	
	/** 当前页的起始位置 */
	var pageStart : Int = 0
	
	/** 当前页的结束位置 */
	var pageStop : Int = 0
	
	/** 符合查询条件的所有记录数 */
	var totalRecords : Int = 0
	
	/** 是否还有下一页？ */
	func hasMore() -> Bool {return pageStop < totalRecords}
}

class OrderResult {
	
}

class ListLeaseOrdersResult : ListResult {
	
}
