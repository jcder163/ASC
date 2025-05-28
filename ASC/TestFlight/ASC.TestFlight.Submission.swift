//
//  ASC.TestFlight.Builds.swift
//  ASC
//
//  Created by Cocoa on 2025/5/23.
//

import Foundation
import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.TestFlight {
    // 更新版本信息命令
    struct Submission: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " TestFlight 提审 ")

        @Option(name:.shortAndLong, help: " 项目 ")
        var project: String?

        @Option(name:.shortAndLong, help: " Build 号 ")
        var buildNum: String?

        mutating func run() async throws {
            guard let project = project,
                  let buildNum = buildNum else {
                fatalError("Project 不可为空")
            }
            let groupId = ASCConfiger.groupId(project)
            LogInfo("开始提审 TestFlight : Build: \(buildNum)")

            let manager = try ASCManager.project(project)
            
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))

            let build = try await manager.fetchBuild(appID: app.id, buildNumber: buildNum)
            
            try await manager.addBuild(build.id, to: ASCConfiger.groupId(project))

            let resp = try await manager.submissionBeta(build: build.id)
            print(resp)
            print("添加完成")
            
        }

    }

    
}
