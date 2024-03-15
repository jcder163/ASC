//
//  ASC.Version.Publish.swift
//  ASC
//
//  Created by cocoa on 2024/3/14.
//


import Foundation
import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.Version {
    
    /// 发布版本命令
    struct Publish: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " 发布应用 ")

        @Option(name:.shortAndLong, help: "项目")
        var project: String?
        
        @Option(name: .shortAndLong,help: "版本号")
        var version: String?
        
        mutating func run() async throws {
            guard let project = project,
                    let version = version else {
                fatalError("Project, Version 不可为空")
            }
  
            let manager = try ASCManager.project(project)
            // 查找对应app
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 查询版本信息
            let versionInfo = try await manager.fetchAppVerion(appID: app.id, versionString: version)
            
            switch versionInfo.attributes?.appStoreState {
            case .pendingDeveloperRelease:
                _ = try await manager.publishVersion(with: versionInfo.id)
                let cResult = try await manager.fetchAppVerion(appID: app.id,
                                                               versionString: version)
                print("APP 状态为: \(cResult.attributes?.appStoreState?.rawValue ?? "")")
                print("发布完成")
                
            default:
                fatalError("APP 状态: \(versionInfo.attributes?.appStoreState?.rawValue ?? ""), 无法发布")
            }

        }
    }

}

private extension ASCManager {
    func publishVersion(with versionID: String) async throws -> AppStoreVersionReleaseRequestResponse {
        
        let req = APIEndpoint.v1.appStoreVersionReleaseRequests.post(AppStoreVersionReleaseRequestCreateRequest(data: AppStoreVersionReleaseRequestCreateRequest.Data(type: .appStoreVersionReleaseRequests, relationships: AppStoreVersionReleaseRequestCreateRequest.Data.Relationships(appStoreVersion: AppStoreVersionReleaseRequestCreateRequest.Data.Relationships.AppStoreVersion(data: AppStoreVersionReleaseRequestCreateRequest.Data.Relationships.AppStoreVersion.Data(type: .appStoreVersions, id: versionID))))))
        
        let result = try await provider.request(req)
        
        return result
    }
}
