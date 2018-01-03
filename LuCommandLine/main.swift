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
view.onCmdList()
view.id = 100
view.onCmdDelete()
view.onCmdCancel()
view.onCmdEdit()
view.onCmdInput()
view.onCmdDetails()
view.onCmdFavor()
view.onCmdReview()
