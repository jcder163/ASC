////
////  ASC.TestFlight.AddBuild.swift
////  ASC
////
////  Created by Cocoa on 2025/5/22.
////
//
//
//import Foundation
//import Foundation
//import ArgumentParser
//import AppStoreConnect_Swift_SDK
//
//extension ASC.TestFlight {
//    // 更新版本信息命令
//    struct AddBuild: AsyncParsableCommand {
//        
//        static var configuration =
//            CommandConfiguration(abstract: " 添加 Build 到测试组 ")
//
//        @Option(name:.shortAndLong, help: "项目")
//        var project: String?
//        
//        @Option(name: .shortAndLong,help: "build号")
//        var buildNum: String?
//
//        mutating func run() async throws {
//        
//            guard let project = project,
//                  let buildNum = buildNum else {
//                fatalError("Project 不可为空")
//            }
//            let groupId = ASCConfiger.groupId(project)
//            LogInfo("开始添加 Build: \(buildNum) 到测试小组")
//
//            let manager = try ASCManager.project(project)
//            // 查找对应app
//            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
//            
//            let build = try await manager.fetchBuild(appID: app.id, buildNumber: buildNum)
//            
//            try await manager.addBuild(build.id, to: groupId)
//            
//            print("添加完成")
//            
//        }
//
//    }
//
//    
//}
