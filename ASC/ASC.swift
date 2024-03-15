//
//  ASC.swift
//  ASC
//
//  Created by cocoa on 2023/5/17.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

@main
struct ASC: AsyncParsableCommand {
    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: " 创建版本，更新whats new，提交审核，检查审核状态，发布审核完成版本 ",

        // Commands can define a version for automatic '--version' support.
        version: "2.0.0",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Version.self, Config.self, Show.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Version.self)

}


