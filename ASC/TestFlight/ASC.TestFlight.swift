//
//  ASC.TestFlight.swift
//  ASC
//
//  Created by Cocoa on 2025/5/22.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK
extension ASC {
    struct TestFlight: AsyncParsableCommand {
        // Customize your command's help and subcommands by implementing the
        // `configuration` property.
        static var configuration = CommandConfiguration(
            // Optional abstracts and discussions are used for help output.
            abstract: " TestFlight管理 ",
            
            // Commands can define a version for automatic '--version' support.
            version: "2.0.0",
            
            // Pass an array to `subcommands` to set up a nested tree of subcommands.
            // With language support for type-level introspection, this could be
            // provided by automatically finding nested `ParsableCommand` types.
            subcommands: [Groups.self, AddBuild.self],
            
            // A default subcommand, when provided, is automatically selected if a
            // subcommand is not given on the command line.
            defaultSubcommand: AddBuild.self)
    }
}
