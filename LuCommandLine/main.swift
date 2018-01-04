//
//  main.swift
//  LuCommandLine
//
//  Created by Brave Lu on 2017/12/30.
//  Copyright © 2017年 Brave Lu. All rights reserved.
//

import Foundation

print("Hello, World!")

//Communicator<Int>().send("", nil , IListener(ListListener()))

Config.getToken()

var view = BuyerOrderView()
repeat {view.onCmdList()} while (view.increasePage() < 10);
view.id = 100
view.onCmdDelete()
view.onCmdCancel()
view.id = 0
view.onCmdInput()
view.onCmdEdit()
view.onCmdInput()
view.onCmdDetails()
view.onCmdFavor()
view.onCmdReview()
var vendorOrderView = VendorOrderView()
vendorOrderView.id = 100
vendorOrderView.operation = VendorOrderNao.OPERATION_CHANGE_PAYMENT
vendorOrderView.onCmdEdit()
vendorOrderView.operation = VendorOrderNao.OPERATION_FINISH
vendorOrderView.onCmdEdit()
