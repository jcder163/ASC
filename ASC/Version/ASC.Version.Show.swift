//
//  ASC.Version.Show.swift
//  ASC
//
//  Created by cocoa on 2024/3/14.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC.Version {
    
    /// 展示版本信息命令，入参项目，版本号
    struct Show: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " 展示版本信息 ")

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
            
            if versionInfo.relationships?.appStoreVersionPhasedRelease?.data == nil {
                _ = try await manager.createPhasedRelease(versionID: versionInfo.id)
            }
            
            print("项目: \(project), ID:\(app.id)")
            LogInfo("版本信息")
            print("版本号: \(version), 版本状态: \(versionInfo.attributes?.appStoreState?.rawValue ?? ""), 发布方式: \(versionInfo.attributes?.releaseType?.rawValue ?? "")")
            print("版本ID: \(versionInfo.id)")
            LogInfo("构建信息")
            if let buildID = versionInfo.relationships?.build?.data?.id {
                let build = try await manager.fetchBuild(with: buildID)
                print("构建号: \(build.attributes?.version ?? ""), 构建状态: \(build.attributes?.processingState?.rawValue ?? "")")
                print("构建ID: \(build.id)")

            } else {
                print("没有构建版本")
            }
            
            // 查询灰度信息
            let phased = try await manager.fetchPhasedRelease(versionID: versionInfo.id)
            LogInfo("灰度信息")
            print("灰度状态: \(phased.attributes?.phasedReleaseState?.rawValue ?? "")")
            print("灰度开始时间: \(phased.attributes?.startDate?.formatted() ?? "Empty")")
            print("灰度当前天数: \(phased.attributes?.currentDayNumber ?? -1)")
            print("灰度ID: \(phased.id)")
        
            
            

        }
    }

}

private extension ASCManager {
    
    /// 根据buildID获取构建详情
    /// - Parameter buildID: 构建ID
    /// - Returns: 构建
    func fetchBuild(with buildID: String) async throws -> Build {
        
        let req = APIEndpoint.v1.builds.id(buildID).get()
        
        let result = try await provider.request(req).data
        
        return result
    }
    
    /// 获取灰度状态
    /// - Parameter appversion: 版本
    /// - Returns: 灰度信息
    func fetchPhasedRelease(versionID: String) async throws -> AppStoreVersionPhasedRelease {
        let req = APIEndpoint.v1.appStoreVersions.id(versionID).appStoreVersionPhasedRelease.get()
        do {
            let result = try await provider.request(req).data
            return result

        } catch let error {
            throw error
        }
    }
}
