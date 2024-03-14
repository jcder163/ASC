//
//  ASC.Version.Submission.swift
//  ASC
//
//  Created by cocoa on 2024/3/13.
//

import Foundation
import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.Version {
    
    /// 提交审核命令
    struct Submission: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " 提交审核 ")

        @Option(name:.shortAndLong, help: "项目")
        var project: String?
        
        @Option(name: .shortAndLong,help: "版本号")
        var version: String?
        
        @Option(name: .shortAndLong, help: "whats new，每种语言最少十个字。‘,’分割不同语言，语言信息和内容以‘:’分割，参考'en-US:1234567890,zh-Hans:1234567890'")
        var whatsnew: String?
        
        @Option(name: .shortAndLong,help: "build号")
        var buildNum: String?

        mutating func run() async throws {
            LogInfo("开始提交版本审核")
            guard let project = project,
                    let version = version,
                  let buildNum = buildNum else {
                fatalError("Project, Version, BuildNum 不可为空")
            }
  
            let manager = try ASCManager.project(project)
            // 查找对应app
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 查询版本信息
            let versionInfo = try await manager.fetchAppVerion(appID: app.id, versionString: version)
            // 有whats new时更新whas new
            if let whatsNew = whatsnew {
                try await manager.updateWhatsNew(whatsNew, versionId: versionInfo.id)
            }
            // 构建build号不对，则重新设置构建，对应build号，不存在时直接抛错
            if let buildInfo = try await manager.fetchBuilds(appID: app.id, versionString: version, buildNumber: buildNum).first {
                
             
                if versionInfo.relationships?.build?.data?.id != buildInfo.id {
                    // 更新构建信息
                    _ = try await manager.updateVersion(appID: app.id,
                                       versionID: versionInfo.id,
                                       buildID: buildInfo.id)
                }
                // 提交审核
                let _ = try await manager.submit(versionID: versionInfo.id)
                print("提交成功")
                
            } else {
                fatalError("\(app.id) \(version) 不存在build: \(buildNum)")

            }
        }
    }

}

private extension ASCManager {
    /// 版本提审
    /// - Parameter versionID: 版本ID
    /// - Returns: 提审结果
    func submit(versionID: String) async throws -> AppStoreVersionSubmission {
        let req = APIEndpoint.v1.appStoreVersionSubmissions.post(AppStoreVersionSubmissionCreateRequest(data: AppStoreVersionSubmissionCreateRequest.Data(type: .appStoreVersionSubmissions, relationships: AppStoreVersionSubmissionCreateRequest.Data.Relationships(appStoreVersion: AppStoreVersionSubmissionCreateRequest.Data.Relationships.AppStoreVersion(data: AppStoreVersionSubmissionCreateRequest.Data.Relationships.AppStoreVersion.Data(type: .appStoreVersions, id: versionID))))))
        
        let data = try await provider.request(req).data
        
        return data
    }
    
}
