//
//  TDLogManager.swift
//  travelDiary
//
//  Created by Hoang Cap on 7/11/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//


// App ID: 9GzdGM
// App secret: s0X8sibklaw8lDh4EzlzAmqbMc4smzyc
// Encryption key: jnLhqxt2cwDeaJhnozmjhgebk7uzt1Eh


import Foundation
import XCGLogger

let log: XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger.default
    let emojiLogFormatter = PrePostFixLogFormatter()
    emojiLogFormatter.apply(prefix: "🗯🗯🗯 ", postfix: " 🗯🗯🗯", to: .verbose)
    emojiLogFormatter.apply(prefix: "\n🔹🔹🔹🔹🔹🔹🔹🔹🔹\n ", postfix: " \n🔹🔹🔹🔹🔹🔹🔹🔹🔹", to: .debug)
    emojiLogFormatter.apply(prefix: "\nℹ️ℹ️ℹ️ℹ️ℹ️ℹ️ℹ️ℹ️ℹ️\n ", postfix: " \nℹ️ℹ️ℹ️ℹ️ℹ️ℹ️ℹ️ℹ️ℹ️", to: .info)
    emojiLogFormatter.apply(prefix: "\n⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️\n ", postfix: " \n⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️", to: .warning)
    emojiLogFormatter.apply(prefix: "\n‼️‼️‼️‼️‼️‼️‼️‼️‼️\n ", postfix: " \n‼️‼️‼️‼️‼️‼️‼️‼️‼️", to: .error)
    emojiLogFormatter.apply(prefix: "\n💣💣💣💣💣💣💣💣💣\n ", postfix: " \n💣💣💣💣💣💣💣💣💣", to: .severe)
    log.formatters = [emojiLogFormatter]

    return log;
}()
