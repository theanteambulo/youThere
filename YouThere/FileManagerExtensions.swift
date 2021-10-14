//
//  FileManagerExtensions.swift
//  YouThere
//
//  Created by Jake King on 09/09/2021.
//
//  Credit: https://medium.com/@sdrzn/swift-4-codable-lets-make-things-even-easier-c793b6cf29e1

import Foundation

public class Storage {
    
    init() { }
    
    enum Directory {
        // user-generated documents and data, or data that cannot otherwise be recreated by the application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud
        case documents
        
        // data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory, e.g. database cache files and downloadable content
        case caches
    }
    
    // returns URL constructed from specified directory
    static func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory
        
        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }
        
        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }
    
    // store an encodable struct to the specified directory on disk
    static func store<T: Encodable>(_ object: T, // the encodable struct to store
                                    to directory: Directory, // where to store the struct
                                    as fileName: String) { // filename where the struct data is stored
        let url = getURL(for: directory).appendingPathComponent(fileName,
                                                                isDirectory: false)
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(object)
        
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            
            FileManager.default.createFile(atPath: url.path,
                                           contents: data,
                                           attributes: nil)
            
            print("\(fileName) was successfully saved to \(directory)")
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    // retrieve and convert a struct from a file on disk. returns the decoded struct model(s) of the data
    static func retrieve<T: Decodable>(_ fileName: String, // name of the file where the struct data is stored
                                       from directory: Directory, // the directory where the struct data is stored
                                       as type: T.Type) -> T { // the struct type
        let url = getURL(for: directory).appendingPathComponent(fileName,
                                                                isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File at path \(url.path) does not exist!")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)!")
        }
    }
    
    // remove all files at specified directory
    static func clear(_ directory: Directory) {
        let url = getURL(for: directory)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    // remove specified file from specified directory
    static func remove(_ fileName: String,
                       from directory: Directory) {
        let url = getURL(for: directory).appendingPathComponent(fileName,
                                                                isDirectory: false)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // return Boolean indicating whether a file exists at a specified directory with a specified filename
    static func fileExists(_ fileName: String,
                           in directory: Directory) -> Bool {
        let url = getURL(for: directory).appendingPathComponent(fileName,
                                                                isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
}
