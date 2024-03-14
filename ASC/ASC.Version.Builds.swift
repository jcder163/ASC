//
//  Builds.swift
//  ASC
//
//  Created by cocoa on 2024/3/13.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.Version {
    
    // 查询对应版本构建的命令
    struct Builds: AsyncParsableCommand {
        static var configuration =
        CommandConfiguration(abstract: " 产看对应版本的构建列表 ")
        
        @Option(name:.shortAndLong, help: "项目")
        var project: String?
        
        @Option(name: .shortAndLong,help: "版本号")
        var version: String?

        @Option(name: .shortAndLong,help: "Build号，有build时请求对应的build号的信息，没有时请求对应版本的buildlist")
        var bulildNum: String?
        
        mutating func run() async throws {
            LogInfo("开始检查构建")

            guard let project = project,
                    let version = version else {
                fatalError("Project, Version 不可为空")
            }
            
            let manager = try ASCManager.project(project)
            // 查找对应app
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 根据版本号查询
            let builds = try await manager.fetchBuilds(appID: app.id, versionString: version)
            builds.forEach { build in
                print("Version: \(build.attributes?.version ?? "") ID: \(build.id)")
            }
            
        }
        
        
    }
    
}

extension ASCManager {
    
    func fetchBuilds(appID: String,
                     versionString: String,
                     buildNumber: String? = nil) async throws -> [Build] {
        if let buildNumber = buildNumber {
            let req = APIEndpoint.v1.builds.get(parameters: APIEndpoint.V1.Builds.GetParameters(filterPreReleaseVersionVersion: [versionString],
                                                                                                filterVersion: [buildNumber],
                                                                                                filterApp: [appID]))
            let result = try await provider.request(req).data
            return result
        } else {
            let req = APIEndpoint.v1.builds.get(parameters: APIEndpoint.V1.Builds.GetParameters(filterPreReleaseVersionVersion: [versionString],
                                                                                                filterApp: [appID]))
            let result = try await provider.request(req).data
            return result
        }

    }
    
}
