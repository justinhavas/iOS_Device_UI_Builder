//
//  DataModel.swift
//  UIBuilderProject
//
//  Created by Lakshya Bakshi on 4/5/20.
//  Copyright © 2020 DeviceUIBuilder. All rights reserved.
//

import Foundation
import UIKit
/**
 Struct to represent buildproject
 */
struct build : Codable {
    var name : String
    var chars : [[String:String]]
    init() {
        self.name = ""
        self.chars = []
    }
    /**
     begins a new build
     */
    init(_ name:String, _ chars:[[String:String]]) {
        self.name = name
        self.chars = chars
    }
    /*
     checks whether two builds are equal; assumption that names are unique
     */
    func equals(_ otherBuild:build) -> Bool {
        return self.name == otherBuild.name
    }
}
/*
 class to manage the construction, editing, and generation of build structs
 */
class Builder {
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("builderJSON")
    var UUIDmap : [String: String]
    var toolMap : [UIView: [String:String]]
    var projectName : String
    var project : build?
    /*
     initializes a fresh builder to begin on the iPad app
     */
    init(_ title : String) {
        projectName = title
        toolMap = [:]
        UUIDmap = [:]
    }
    /*
     initializes a builder from a json description
     */
    init(json:String) {
        projectName = ""
        toolMap = [:]
        UUIDmap = jsonToUuid(json)
        loadData(json)
        projectName = project!.name
        populateTools(from: self.project!)
    }
    /*
     initializes a builder from an existing build struct
     */
    init(from:build) {
        projectName = from.name
        project = from
        toolMap = [:]
        UUIDmap = [:]
        let _ = buildToJson()
        populateTools(from: from)
    }
    /*
     returns the build struct of the current builder
     */
    func getBuild() -> build? {
        return project
    }
    /*
     takes a view, label, and name as an argument and edits/adds it in the backend
     */
    func edit(_ view: UIView, _ name:String, _ label:String) {
        let origin = view.frame.origin
        let tool = ["type":getViewType(view), "name":name, "x":origin.x.description, "y":origin.y.description, "label":label]
        toolMap[view] = tool
    }
    /*
     function to check if the map contains a view, primarily useful for seeing if a UILabel is an associated item or its own bluetooth output information
     */
    func contains(_ view: UIView) -> Bool {
        return (toolMap[view] != nil)
    }
    /*
     deletes an existing tool from the project
     */
    func delete(_ view:UIView) {
        toolMap.removeValue(forKey: view)
    }
    /*
     populates the tools map with an existing build
     */
    func populateTools(from:build) {
        for characteristic in from.chars {
            let rawtype = characteristic["type"] ?? ""
            var type = (rawtype=="output") ? "Label" : rawtype
            type.capitalizeFirst()
            let tempView = self.getInstantiation(draggedType: type,theLabel: characteristic["label"] ?? "",name: characteristic["name"] ?? "",dropViewFrame: nil)
            let x = Double(characteristic["x"] ?? "0") ?? 0.0
            let y = Double(characteristic["y"] ?? "0") ?? 0.0
            let orig = CGPoint(x:x, y:y)
            tempView.frame = CGRect(origin: orig, size: tempView.frame.size)
            self.edit(tempView, characteristic["name"] ?? "0", characteristic["label"] ?? "0")
        }
    }
    /*
     takes a type object and makes a UIView with the appropriate default properties
     */
    func getInstantiation(draggedType: String,theLabel: String,name: String,dropViewFrame: CGRect?) -> UIView {
        let dragdropview = DragDropView()
        dragdropview.buildView(actionView: ActionViewUtilities.getActionViewFromString(string: draggedType),label: theLabel,name: name,dropViewFrame: dropViewFrame)
        return dragdropview
    }
    /*
     generates an array of UIViews of both bluetooth objects and associated labels to populate the frontend. Assumes that the project has been initialized. Returns a map of the view to a tuple, where the tuple contains the type of the view and the associated UUID
     */
    func generateTools() -> [UIView:(String,String)] {
        if self.project == nil {
            return [:]
        }
        var out : [UIView:(String,String)] = [:]
        for tool in self.project!.chars {
            //set type
            let rawtype = tool["type"] ?? ""
            var type = (rawtype=="output") ? "Label" : rawtype
            type.capitalizeFirst()
            let tempView = self.getInstantiation(draggedType: type,theLabel: tool["label"] ?? "",name: tool["name"] ?? "",dropViewFrame: nil)
            //set x and y
            let x = Double(tool["x"] ?? "0") ?? 0.0
            let y = Double(tool["y"] ?? "0") ?? 0.0
            let orig = CGPoint(x:x, y:y)
            tempView.frame = CGRect(origin: orig, size: tempView.frame.size)
            //package with UUID
            let name = tool["name"] ?? ""
            let UUID = self.UUIDmap[name] ?? ""
            out[tempView] = (rawtype, UUID)
        }
        return out
    }
    /*
     accepts a view and checks it's type, converting it to string
     */
    func getViewType(_ view:UIView) -> String {
        if (view as? DragDropView)?.actionView is UILabel {
            return "output"
        }
        if (view as? DragDropView)?.actionView is UISlider {
            return "slider"
        }
        if (view as? DragDropView)?.actionView is UISwitch {
            return "switch"
        }
        return "ERROR"
    }
    /*
     converts the existing build into a json string format, additionally building the UUID map in the process
     */
    func buildToJson() -> String {
        let encoder = JSONEncoder()
        var jsonText : String = ""
        if let encoded = try? encoder.encode(self.project) {
            if let json = String(data: encoded, encoding: .utf8) {
                jsonText=json
                UUIDmap = jsonToUuid(jsonText)
            }
        }
        return jsonText
    }
    /*
     saves the project
     */
    func save() -> [String:String]{
        self.project = build(projectName, Array(toolMap.values))
        var outputData = Data()
        let encoder = JSONEncoder()
        var jsonText : String = ""
        if let encoded = try? encoder.encode(project) {
            if let json = String(data: encoded, encoding: .utf8) {
                outputData = encoded
                jsonText=json
            } else { print("Store failed") }
            do {
                try outputData.write(to: Builder.ArchiveURL)
            } catch let error as NSError {
                print(error)
                print("Store failed")
            }
            print("Store Succeeded")
            UUIDmap = jsonToUuid(jsonText)
            return UUIDmap
        }
        else {
            print("Store failed")
            return [:]
        }
    }
    /*
     loads a builder from a specified JSON string
     */
    func loadData(_ jsonString:String) {
        let data = jsonString.data(using: .utf8)
        let decoder = JSONDecoder()
        var proj = build()
        if let decoded = try? decoder.decode(build.self, from: data!) {
            proj = decoded
        }
        self.project = proj
    }
    /*
     DEPRECATED: loads the project from JSON storage
     */
    func loadData() -> build? {
        let decoder = JSONDecoder()
        var proj = build()
        let tempData: Data
        do {
            tempData = try Data(contentsOf: Builder.ArchiveURL)
        } catch let error as NSError {
            print(error)
            return proj
        }
        if let decoded = try? decoder.decode(build.self, from: tempData) {
            proj = decoded
        }
        self.project = proj
        return proj
    }
    
}
