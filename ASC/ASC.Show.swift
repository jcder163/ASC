//
//  ASC.Show.swift
//  ASC
//
//  Created by cocoa on 2024/3/13.
//

import Foundation
import ArgumentParser
import AppStoreConnect_Swift_SDK

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
