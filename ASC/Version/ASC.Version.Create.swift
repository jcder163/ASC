//
//  Version.Create.swift
//  ASC
//
//  Created by cocoa on 2024/3/13.
//


import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.Version {
    
    // 创建版本
    struct Create: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " 创建版本 ")

        @Option(name: .shortAndLong, help: "项目")
        var project: String?
        
        @Option(name: .shortAndLong, help: "版本号")
        var version: String?
        
        @Option(name: .shortAndLong, help: "whats new，每种语言最少十个字。‘,’分割不同语言，语言信息和内容以‘:’分割，参考'en-US:1234567890,zh-Hans:1234567890'")
        var whatsnew: String?
        
        func run() async throws {
            LogInfo("开始创建版本")
            guard let project = project,
                    let version = version else {
                
                fatalError("Project, Version 不可为空")
            }
            
            // 查找对应app
            let manager = try ASCManager.project(project)
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 根据版本号创建版本
            let versionInfo = try await manager.createVersion(appID: app.id, versionString: version)
            // 创建完成版本则修改为灰度发布
            try await manager.setPhased(versionId: versionInfo.id)

            if let whatsnew = whatsnew {
                try await manager.updateWhatsNew(whatsnew, versionId: versionInfo.id)
            } else {
                
            }
            print(version)
        }

    }
}

private extension ASCManager {
    
    /// 创建版本
    /// - Parameters:
    ///   - app: app
    ///   - versionString: 版本号
    /// - Returns: 版本信息
    func createVersion(appID: String,
                       versionString: String) async throws -> AppStoreVersion {
        let request = APIEndpoint.v1.appStoreVersions.post(AppStoreVersionCreateRequest(data: AppStoreVersionCreateRequest.Data(type: .appStoreVersions,
                                                                                                                                attributes: AppStoreVersionCreateRequest.Data.Attributes(platform: .ios,
                                                                                                                                                                                         versionString: versionString,
                                                                                                                                                                                         releaseType: .manual),
                                                                                                                                relationships: AppStoreVersionCreateRequest.Data.Relationships(app: AppStoreVersionCreateRequest.Data.Relationships.App(data: AppStoreVersionCreateRequest.Data.Relationships.App.Data(type: .apps, id: appID))))))
        
        let result = try await provider.request(request).data
        return result
    }
    
}
