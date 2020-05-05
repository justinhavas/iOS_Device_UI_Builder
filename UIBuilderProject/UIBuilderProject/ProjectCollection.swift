//
//  ProjectCollection.swift
//  UIBuilderProject
//
//  Created by Lakshya Bakshi on 4/18/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//

import Foundation
/*
 class to handle the collection of build structs the user has established, including storage, loading, modifying, and accessing
 */
class ProjectCollection:Codable {
    var projectArr:[build] = []
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("builderCollectionJSON")
    
    init() {
    }
    /*
     updates a build from the interface builder into the collection
     */
    func update(_ newBuild: build) {
        self.delete(newBuild)
        projectArr.insert(newBuild, at: 0)
    }
    /*
     deletes a build from the interface builder
     */
    func delete(_ buildToDelete: build) {
        projectArr.removeAll(where: {$0.equals(buildToDelete)})
    }
    /*
     returns the names of all projects that have been store to the collection
     */
    func getAllProjectNames() -> [String] {
        return projectArr.map({$0.name})
    }
    /*
     loads the list of structs from local storage
     */
    static func load() -> ProjectCollection? {
        let decoder = JSONDecoder()
        var projColl = ProjectCollection()
        let tempData: Data
        do {
            tempData = try Data(contentsOf: ArchiveURL)
        } catch let error as NSError {
            print(error)
            return projColl
        }
        if let decoded = try? decoder.decode(ProjectCollection.self, from: tempData) {
            projColl = decoded
        }
        return projColl
    }
    /*
     saves the current list to local storage
     */
    static func save(_ dataArr: ProjectCollection) -> Bool {
        var outputData = Data()
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dataArr) {
            if String(data: encoded, encoding: .utf8) != nil {
                outputData = encoded
                print(outputData)
            } else { return false }
            do {
                try outputData.write(to: ArchiveURL)
            } catch let error as NSError {
                print(error)
                return false
            }
            return true
        }
        else { return false }
    }
}
