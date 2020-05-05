/*
* Class:       iPhoneCentralViewController.swift
* Authors:     Lucy Chikwetu
* Created:     04/13/20
* Description: This is a just a file for utilities. We wanna know the type of control for each uuid.
*              The charsDictArray is a helper function for the ultimate "lookupDictionary" function
*
*/

import UIKit

/* This is a helper function for the lookupDictionary function. Here we get an array of dictionaries for each
 * characteristic with 'label', 'x', 'type', 'name', 'y' as keys.
 */
func charsDictArray(_ jsonInfo: String)->[[String:String]]{
    let uuidDict:[String:String] = jsonToUuid(jsonInfo)
    var dictValues:[String]? = []
    for (_,value) in uuidDict{
        dictValues!.append(value)
    }
    let json:String = uuidToJson(service: "", characteristics: dictValues)!
    var dictSubString:Substring = ""
    
    if let dictStart = json.firstIndex(of: "["){
       if let dictEnd = json.firstIndex(of: "]"){
        dictSubString = json[dictStart...dictEnd]
            dictSubString = dictSubString.dropFirst()
            dictSubString = dictSubString.dropLast()
       }
    }

    let charsString:String = String(dictSubString)
    var chars:[String] = charsString.components(separatedBy: "}")
    var index:Int = -1
    for i in chars{
        index = index + 1
        if let charInfoStart = i.firstIndex(of: "{"){
            chars[index] = String(i[charInfoStart..<i.endIndex].dropFirst())
        }
    }

    chars = chars.dropLast()
    var charsArrays:[[String]] = [[String]]()
    for i in chars{
        let keyValArr:[String] = i.components(separatedBy: ",")
        charsArrays.append(keyValArr)
    }
  
    var charsKeyvalArrays:[[[String]]] = [[[String]]]()
    var charsDictArray:[[String:String]] = [[String:String]]()
    for i in charsArrays{
        var tempKeyVal:[[String]] = [[String]]()
        for j in i{
            let charsToRemove: Set<Character> = Set("\"")
            let trimmedStr = String(j.filter { !charsToRemove.contains($0) })
            let keyVal:[String] = trimmedStr.components(separatedBy: ":")
            tempKeyVal.append(keyVal)
        }
        charsKeyvalArrays.append(tempKeyVal)
        var charDict:[String:String] = [:]
        for i in tempKeyVal{
            charDict[i[0]] = i[1]
        }
        
        charsDictArray.append(charDict)
    }
    return charsDictArray
}

/* This is the ultimate fuction. It's a dictionary with uuids as keys and object type as value.*/
func lookupDictionary(_ jsonInfo:String)->[String:String]{
    let charsDicts:[[String:String]] = charsDictArray(jsonInfo)
    var lookupDict:[String:String] = [String:String]()
    let uuidDict:[String:String] = jsonToUuid(jsonInfo)
    
    for i in charsDicts{
        let uuid:String = i["name"]!
        let uuidStr:String = uuidDict[uuid] ?? ""
        lookupDict[uuidStr] = i["type"]!
    }
    return lookupDict
}
