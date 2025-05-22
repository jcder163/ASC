//
//  ASC.Config.swift
//  ASC
//
//  Created by cocoa on 2024/3/13.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

extension ASC {
        
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
        @Option(name: .shortAndLong, help: "默认提测小组 ID")
        var groupId: String?
        
        mutating func run() async throws {
            guard let project = project else { throw NSError(domain: "project is empty", code: 997) }
            ASCConfiger.save(
                project: project,
                issuser_id: issuesrID ?? ASCConfiger.issuser_id(project),
                key_id: keyID ?? ASCConfiger.key_id(project),
                token: token ?? ASCConfiger.token(project),
                appId: appId ?? ASCConfiger.appId(project),
                groupId: groupId ?? ASCConfiger.groupId(project)
            )
            print("配置存储完成")
            print("Project: \(project)")
            print("App ID: \(project)")
            print("Issuser ID: \(ASCConfiger.issuser_id(project))")
            print("Key ID: \(ASCConfiger.key_id(project))")
            print("Key(token): \(ASCConfiger.token(project))")
            print("Group ID: \(ASCConfiger.groupId(project))")
        }
    }
    
  
}
