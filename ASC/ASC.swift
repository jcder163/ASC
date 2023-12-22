//
//  ASC.swift
//  ASC
//
//  Created by cocoa on 2023/5/17.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

@main
struct ASC: AsyncParsableCommand {
    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: " 创建版本，更新whats new，提交审核，检查审核状态，发布审核完成版本 ",

        // Commands can define a version for automatic '--version' support.
        version: "1.0.1",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Version.self, Config.self, Show.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Version.self)

}


extension ASC {
    

    struct Version: AsyncParsableCommand {
        
        // Customize your command's help and subcommands by implementing the
        // `configuration` property.
        static var configuration = CommandConfiguration(
            // Optional abstracts and discussions are used for help output.
            abstract: " 版本信息管理 ",

            // Commands can define a version for automatic '--version' support.
            version: "1.0.0",

            // Pass an array to `subcommands` to set up a nested tree of subcommands.
            // With language support for type-level introspection, this could be
            // provided by automatically finding nested `ParsableCommand` types.
            subcommands: [Create.self, Update.self],

            // A default subcommand, when provided, is automatically selected if a
            // subcommand is not given on the command line.
            defaultSubcommand: Update.self)
        
       
    }
    
    

    struct Config: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: "Configure running parameters")
        
        @Option(name: .shortAndLong, help: "Project 名称")
        var project: String?
        
        @Option(name: .shortAndLong, help: "Issuser ID")
        var issuesrID: String?
        
        @Option(name: .shortAndLong, help: "Key ID")
        var keyID: String?
        
        @Option(name: .shortAndLong, help: "Key Content (token)")
        var token: String?
        
        @Option(name: .shortAndLong, help: "app id")
        var appId: String?
        
        mutating func run() async throws {
            guard let project = project else { throw NSError(domain: "project is empty", code: 997) }
            ASCConfiger.save(project: project,
                             issuser_id: issuesrID ?? ASCConfiger.issuser_id(project),
                             key_id: keyID ?? ASCConfiger.key_id(project),
                             token: token ?? ASCConfiger.token(project),
                             appId: appId ?? ASCConfiger.appId(project))
            print("配置存储完成")
            print("Project: \(project)")
            print("App ID: \(project)")
            print("Issuser ID: \(ASCConfiger.issuser_id(project))")
            print("Key ID: \(ASCConfiger.key_id(project))")
            print("Key(token): \(ASCConfiger.token(project))")
        }
    }
    
    struct Show: AsyncParsableCommand {
        
        @Option(help: "Scan Project")
        var project: String?

        mutating func run() async throws {
            
            if let project = project {
                print("***********************")
                print("Project: \(project)")
                print("App ID: \(ASCConfiger.appId(project))")
                print("Issuser ID: \(ASCConfiger.issuser_id(project))")
                print("Key ID: \(ASCConfiger.key_id(project))")
                print("Key(token): \(ASCConfiger.token(project))")
            } else {
                let projects = ASCConfiger.projects()
                projects.forEach { project in
                    print("***********************")
                    print("Project: \(project)")
                    print("App ID: \(ASCConfiger.appId(project))")
                    print("Issuser ID: \(ASCConfiger.issuser_id(project))")
                    print("Key ID: \(ASCConfiger.key_id(project))")
                    print("Key(token): \(ASCConfiger.token(project))")
                }
            }
            
        }
    }
}

extension ASC.Version {
    
    struct Create: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " 创建提审版本 ")

        @Option(name: .shortAndLong, help: "项目")
        var project: String?
        
        @Option(name: .shortAndLong, help: "版本号")
        var version: String?
        
        @Option(name: .shortAndLong, help: "whats new，每种语言最少十个字。‘,’分割不同语言，语言信息和内容以‘:’分割，参考'en-US:1234567890,zh-Hans:1234567890'")
        var whatsnew: String?
        
        func run() async throws {
            print("----------------- create")
            guard let project = project,
                    let version = version else {
                
                fatalError("Project, Version 不可为空")
            }
            
            // 查找对应app
            let manager = try ASCManager.project(project)
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 根据版本号创建版本
            let versionInfo = try await manager.createVersion(app: app, versionString: version)
            // 创建完成版本则修改为灰度发布
            let phased = try await manager.createPhasedRelease(appVersion: versionInfo)
            if let whatsnew = whatsnew {
                // 获取对应版本的本地化语言
                let localInfos = try await manager.fetchLocalize(version: versionInfo)
                for info in localInfos {
                    let finalInfo = ASCWhatsNew.fetchWhasNew(locale: info.attributes?.locale ?? "",
                                                            whatsNewStr: whatsnew)?.whatsNew ?? whatsnew
                    // 修改whatsnew
                    let localInfo = try await manager.update(whatsNew: finalInfo,
                                                       localize: info)
                    // 校验是否修改完成
                    if localInfo.attributes?.whatsNew == finalInfo {
                        
                    } else {
                        fatalError("修改whatsnew 失败")
                    }
                }
            } else {
                
            }
            print(version)
            print(phased.attributes!.phasedReleaseState?.rawValue ?? "分阶段发布状态不正确")
        }

    }
    
    struct Update: AsyncParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: " 更新版本信息 ")

        @Option(name:.shortAndLong, help: "项目")
        var project: String?
        
        @Option(name: .shortAndLong,help: "版本号")
        var version: String?
        
        @Option(name: .shortAndLong, help: "whats new，每种语言最少十个字。‘,’分割不同语言，语言信息和内容以‘:’分割，参考'en-US:1234567890,zh-Hans:1234567890'")
        var whatsnew: String?


        mutating func run() async throws {
            print("------------ update begin")
            
            guard let project = project,
                    let version = version else {
                fatalError("Project, Version 不可为空")
            }

            
            let manager = try ASCManager.project(project)
            // 查找对应app
            let app = try await manager.fetchApp(with: ASCConfiger.appId(project))
            // 根据版本号查询
            let versionInfo = try await manager.fetchAppVerion(app: app, versionString: version)
            // 获取app 分阶段发布状态
            let phaseRelease = try await manager.readPhasedRelease(appversion: versionInfo)
            // 默认改为分阶段发布
            if phaseRelease.attributes?.phasedReleaseState == .none || phaseRelease.attributes?.phasedReleaseState == nil {
                
                let phasedReleaseState: PhasedReleaseState? = phaseRelease.attributes?.phasedReleaseState
                let releaseType: AppStoreVersion.Attributes.ReleaseType? = versionInfo.attributes?.releaseType
                let phased = try await manager.createPhasedRelease(appVersion: versionInfo)
                let phasedReleaseState1: PhasedReleaseState? = phased.attributes?.phasedReleaseState
                print("版本: \(version), 发布方式: \(releaseType?.rawValue ?? "Nill"), 灰度状态: \(phasedReleaseState?.rawValue ?? "Nill") -> \(phasedReleaseState1?.rawValue ?? "Nill")")
            }
            if let whatsnew = whatsnew {
                // 获取对应版本的本地化语言
                let localInfos = try await manager.fetchLocalize(version: versionInfo)
                for info in localInfos {
                    let finalInfo = ASCWhatsNew.fetchWhasNew(locale: info.attributes?.locale ?? "",
                                                            whatsNewStr: whatsnew)?.whatsNew ?? whatsnew
                    // 修改whatsnew
                    print("localInfo: \(info.attributes?.locale ?? ""), whatsNew: \(finalInfo)")
                    let localInfo = try await manager.update(whatsNew: finalInfo,
                                                       localize: info)
                    // 校验是否修改完成
                    if localInfo.attributes?.whatsNew == finalInfo {
                        
                    } else {
                        fatalError("修改whatsnew 失败")
                    }
                }
            } else {
                print("whatsnew 不存在")
            }
        
        }
    }
    
}

