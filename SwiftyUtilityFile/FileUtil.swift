//
//  FileUtil.swift
//  RehrigPacific
//
//  Created by Sugam Kalra on 24.01.16.
//  Copyright (c) 2016 Sugam Kalra, Inc. All rights reserved.
//

import Foundation

// Subdirectory name for saved files
let CONTENT_DIR = "content"

/**
 * Utility for accessing local files (save/load)
 *
 * @author Sugam
 * @version 1.0
 */
class FileUtil {
    
    /**
     Saves content file with given id and data. Returns url to local file or nil if error occur
     
     - parameter fileName: the file name
     - parameter data:     the data
     
     - returns: the URL of the file
     */
    class func saveContentFile(fileName: String, data: NSData) -> NSURL? {
        if saveDataToDocumentsDirectory(data, path: fileName, subdirectory: CONTENT_DIR) {
            return FileUtil.getLocalFileURL(fileName)
        }
        return nil
    }
    
    /**
     Saves data on the given path in subdirectory in Documents
     
     - parameter fileData:     the data
     - parameter path:         the main path
     - parameter subdirectory: the subdirectory name
     
     - returns: true - if successfully saved, false - else
     */
    class func saveDataToDocumentsDirectory(fileData: NSData, path: String, subdirectory: String?) -> Bool {
        
        // Create generic beginning to file save path
        var savePath = self.applicationDocumentsDirectory().path!+"/"
        
        // Subdirectory
        if let dir = subdirectory {
            savePath += dir
            self.createSubDirectory(savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += path
        
        // Save the file and see if it was successful
        let ok: Bool = NSFileManager.defaultManager().createFileAtPath(savePath, contents:fileData, attributes:nil)
        
        // Return status of file save
        return ok
    }
    
    /**
     Returns url to local file by fileNames
     
     - parameter fileName: the file name
     
     - returns: the URL
     */
    class func getLocalFileURL(fileName: String) -> NSURL {
        return NSURL(fileURLWithPath: "\(self.applicationDocumentsDirectory().path!)/\(CONTENT_DIR)/\(fileName)")
    }
    
    /**
     Returns url to Documents directory of the current app
     
     - returns: the URL
     */
    class func applicationDocumentsDirectory() -> NSURL {
        
        var documentsDirectory:String?
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true);
        if paths.count > 0 {
            if let pathString = paths[0] as? NSString {
                documentsDirectory = pathString as String
            }
        }
        return NSURL(string: documentsDirectory!)!
    }
    
    /**
     Creates directory is not exists
     
     - parameter subdirectoryPath: the subdirectoty name
     
     - returns: true - if created successfully or exists, false - else
     */
    class func createSubDirectory(subdirectoryPath: String) -> Bool {
        var isDir: ObjCBool = false;
        let exists = NSFileManager.defaultManager().fileExistsAtPath(subdirectoryPath as String, isDirectory:&isDir)
        if exists {
            // a file of the same name exists, we don't care about this so won't do anything
            if isDir {
                // subdirectory already exists, don't create it again
                return true
            }
        }
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(subdirectoryPath,
                withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch {
            print("ERROR: \(error)")
        }
        return false
    }
}

/**
 * Extension adds methods for reading and writing into a local file
 *
 * @author Sugam
 * @version 1.0
 */
extension JSON {
    
    /**
     Save JSON object into given file
     
     - parameter fileName: the file name
     
     - returns: the URL of the saved file
     */
    func saveFile(fileName: String) -> NSURL? {
        do {
            let data = try self.rawData()
            return FileUtil.saveContentFile(fileName, data: data)
        } catch {
            return nil
        }
    }
    
    /**
     Get JSON object from given file
     
     - parameter fileName: the file name
     
     - returns: JSONObject
     */
    static func contentOfFile(fileName: String) -> JSON? {
        let url = FileUtil.getLocalFileURL(fileName)
        if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            if let data = NSData(contentsOfFile: url.path!) {
                return JSON(data: data)
            }
        }
        return nil
    }
    
    /**
     Get JSON from resource file
     
     - parameter name:    resource name
     */
    static func fetchJSONResourceWithName(name: String) -> JSON? {
        let resourceUrl = NSBundle.mainBundle().URLForResource(name, withExtension: "json")
        if resourceUrl == nil {
            fatalError("Could not find resource \(name)")
        }
        
        // create data from the resource content
        var data: NSData
        do {
            data = try NSData(contentsOfURL: resourceUrl!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error {
            print("ERROR: \(error)")
            return nil
        }
        
        // reading the json
        return JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
    }
}