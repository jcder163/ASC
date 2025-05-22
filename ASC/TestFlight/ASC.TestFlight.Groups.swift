//
//  ASC.TestFlight.Groups.swift
//  ASC
//
//  Created by Cocoa on 2025/5/22.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.TestFlight {
    
    // 查询对应版本构建的命令
    struct Groups: AsyncParsableCommand {
        static var configuration =
        CommandConfiguration(abstract: " 查询所有的 Group ")
        
        @Option(name:.shortAndLong, help: "项目")
        var project: String?
                
        mutating func run() async throws {
            LogInfo("开始查询 Group")
            guard let project = project else {
                fatalError("Project 不可为空")
            }
            
            let manager = try ASCManager.project(project)
            // 查找对应app
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 根据版本号查询
            let groups = try await manager.fetchGroups(appID: app.id)
            groups.forEach { group in
                print("Name: \(group.attributes?.name ?? "") ID: \(group.id)")
            }
            
        }
        
        
    }
    
}

