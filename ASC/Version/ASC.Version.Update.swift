//
//  Version.Update.swift
//  ASC
//
//  Created by cocoa on 2024/3/13.
//

import Foundation
import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.Version {
    // 更新版本信息命令
    struct Update: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " 更新版本信息 ")

        @Option(name:.shortAndLong, help: "项目")
        var project: String?
        
        @Option(name: .shortAndLong,help: "版本号")
        var version: String?
        
        @Option(name: .shortAndLong, help: "whats new，每种语言最少十个字。‘,’分割不同语言，语言信息和内容以‘:’分割，参考'en-US:1234567890,zh-Hans:1234567890'")
        var whatsnew: String?
        
        @Option(name: .shortAndLong,help: "build号")
        var buildNum: String?

        mutating func run() async throws {
            LogInfo("开始更新版本信息")
   
            try await update()
            
            print("更新完成")
            
        }
        
        func update() async throws {
            
            guard let project = project,
                    let version = version else {
                fatalError("Project, Version 不可为空")
            }
            
            let manager = try ASCManager.project(project)
            // 查找对应app
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 根据版本号查询
            let versionInfo = try await manager.fetchAppVerion(appID: app.id, versionString: version)
      
            if versionInfo.relationships?.appStoreVersionPhasedRelease?.data == nil {
                _ = try await manager.createPhasedRelease(versionID: versionInfo.id)
            }
            
            try await manager.setPhased(versionId: versionInfo.id)
            
            if let whatsnew = whatsnew {
                try await manager.updateWhatsNew(whatsnew, versionId: versionInfo.id)
            } else {
                print("whatsnew 不存在")
            }
            
            if let buildNum = buildNum {
                let _ = try await manager.updateVersion(appID: app.id, version: version, buildNum: buildNum)
            }
        
        }
    }

    
}

private extension ASCManager {
    
    /// 更新版本的构建
    /// - Parameters:
    ///   - app: app
    ///   - version: 版本号
    ///   - buildNum: build号
    /// - Returns: 版本信息
    func updateVersion(appID: String,
                       version: String,
                       buildNum: String) async throws -> AppStoreVersion {
        
        let versionInfo = try await self.fetchAppVerion(appID: appID,
                                                        versionString: version)
        guard let buildInfo = try await self.fetchBuilds(appID: appID, versionString: version, buildNumber: buildNum).first else {
            fatalError("\(appID) \(version) 不存在build: \(buildNum)")
        }
        
        
        if versionInfo.relationships?.build?.data?.id == buildInfo.id {
            print("版本构建已经是: \(buildNum)")
            return versionInfo
        }
        
        return try await self.updateVersion(appID: appID, versionID: versionInfo.id, buildID: buildInfo.id)
    }
    
}
