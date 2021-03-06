//
//  MockMediaProvider.swift
//  Pods
//
//  Created by Admin on 08/11/2016.
//
//

import UIKit
import SwiftyJSON



public class MockMediaEntryProvider: MediaEntryProvider {
  

    
    
   public enum MockError: Error {
        case invalidParam(paramName:String)
        case fileIsEmptyOrNotFound
        case unableToParseJSON
        case mediaNotFound
        
    }
    
    
    public var id: String?
    public var url: URL?
    public var content: Any?
    
    @discardableResult
    public func set(id: String?) -> Self {
        self.id = id
        return self
    }
    
    @discardableResult
    public func set(url: URL?) -> Self {
        self.url = url
        return self
    }
    
    @discardableResult
    public func set(content: Any?) -> Self {
        self.content = content
        return self
    }
    
    public init(){
        
    }
    

    struct LoaderInfo {
         var id: String
         var content: JSON
    }

    
    public func loadMedia(callback: @escaping (Result<MediaEntry>) -> Void){
        
        
        guard let id = self.id else {
            callback(Result(data: nil, error: MockError.invalidParam(paramName: "id")))
            return
        }
        
        var json: JSON? = nil
        if self.content != nil {
            json = JSON(self.content)
        }else if self.url != nil{
            guard let stringPath = self.url?.absoluteString else {
                 callback(Result(data: nil, error: MockError.invalidParam(paramName: "url")))
                return
            }
            guard  let data = NSData(contentsOfFile: stringPath)  else {
                 callback(Result(data: nil, error: MockError.fileIsEmptyOrNotFound))
                return
            }
            json = JSON(data: data as Data)
        }
        
        
        guard  let jsonContent = json else {
            callback(Result(data: nil, error: MockError.unableToParseJSON))
            return
        }
        
        let loderInfo = LoaderInfo(id: id, content: jsonContent)
        
        guard  loderInfo.content != .null  else {
            callback(Result(data: nil, error: MockError.unableToParseJSON))
            return
        }
        
        let jsonObject: JSON = loderInfo.content[loderInfo.id]
        guard jsonObject != .null else {
            callback(Result(data: nil, error:MockError.mediaNotFound))
            return
        }
        
        let mediaEntry : MediaEntry? = MediaEntry(json: jsonObject.object)
        callback(Result(data: mediaEntry, error: nil))
    }
    
    public func cancel() {
        
    }
    
}
