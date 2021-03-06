//
//  TracksHandler.swift
//  Pods
//
//  Created by Eliza Sapir on 05/12/2016.
//
//

import Foundation
import AVFoundation

class TracksManager: NSObject {
    let audioTypeKey: String = "soun"
    let textOffDisplay: String = "Off"
    
    private var audioTracks: [Track]?
    private var textTracks: [Track]?
    
    public func handleTracks(item: AVPlayerItem?, block: @escaping(_ tracks: PKTracks)->Void) {
        guard let playerItem = item else {
            PKLog.error("AVPlayerItem is nil")
            return
        }
        
        PKLog.trace("item:: \(playerItem)")
        
        self.audioTracks = nil
        self.textTracks = nil
        self.handleAudioTracks(item: playerItem)
        self.handleTextTracks(item: playerItem)
        
        
        if self.audioTracks != nil || self.textTracks != nil {
            PKLog.debug("audio tracks:: \(self.audioTracks), text tracks:: \(self.textTracks)")
            block(PKTracks(audioTracks: self.audioTracks, textTracks: self.textTracks))
        } else {
            PKLog.debug("no audio/ text tracks")
        }
        
    }
    
    public func selectTrack(item: AVPlayerItem, trackId: String) {
        PKLog.trace("selectTrack")
        
        let idArr : [String] = trackId.components(separatedBy: ":")
        let type: String = idArr[0]
        let index: Int = Int(idArr[1])!
        
        if type == audioTypeKey {
            self.selectAudioTrack(item: item, index: index)
        } else {
            self.selectTextTrack(item: item, type: type, index: index)
        }
    }
    
    public func currentAudioTrack(item: AVPlayerItem) -> String? {
        if let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible), let option = item.selectedMediaOption(in: group) {
            return self.audioTracks?.filter{($0.title! == option.displayName)}.first?.id
        }
        return nil
    }
    
    public func currentTextTrack(item: AVPlayerItem) -> String? {
        if let group = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible) {
            var displayName: String
            if let option = item.selectedMediaOption(in: group) {
                displayName = option.displayName
            } else {
                displayName = textOffDisplay
            }
            return self.textTracks?.filter{($0.title! == displayName)}.first?.id
        }
        return nil
    }
    
    private func handleAudioTracks(item: AVPlayerItem) {
        PKLog.trace("handleAudioTracks")
        
        item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible)?.options.forEach { (option) in
            
            PKLog.trace("option:: \(option)")
            
            var index = 0
            
            if let tracks = self.audioTracks {
                index = tracks.count
            } else {
                self.audioTracks = [Track]()
            }
            
            let trackId = "\(option.mediaType):\(String(index))"
            let track = Track(id: trackId, title: option.displayName, language: option.extendedLanguageTag)
            
            self.audioTracks?.append(track)
        }
    }
    
    private func selectAudioTrack(item: AVPlayerItem, index: Int) {
        PKLog.trace("selectAudioTrack")
        
        let audioSelectionGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicAudible)
        var trackIndex = 0
        audioSelectionGroup?.options.forEach { (option) in
            
            if trackIndex == index {
                PKLog.trace("option:: \(option)")
                item.select(option, in: audioSelectionGroup!)
            }
            
            trackIndex += 1
        }
    }
    
    private func handleTextTracks(item: AVPlayerItem) {
        PKLog.trace("handleTextTracks")
        
        var optionMediaType = ""
        item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible)?.options.forEach { (option) in
            
            PKLog.trace("option:: \(option)")
            
            var index = 0
            
            if let tracks = self.textTracks {
                index = tracks.count
            } else {
                self.textTracks = [Track]()
            }
            
            optionMediaType = option.mediaType
            let trackId = "\(optionMediaType):\(String(index))"
            let track = Track(id: trackId, title: option.displayName, language: option.extendedLanguageTag)
            
            self.textTracks?.append(track)
        }
        if optionMediaType != "" {
            self.textTracks?.insert(Track(id: "\(optionMediaType):-1", title: textOffDisplay, language: nil), at: 0)
        }
    }
    
    private func selectTextTrack(item: AVPlayerItem, type: String, index: Int) {
        PKLog.trace("selectTextTrack")
        
        let textSelectionGroup = item.asset.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristicLegible)
        
        if index == -1 {
            item.select(nil, in: textSelectionGroup!)
        } else {
            var trackIndex = 0
            textSelectionGroup?.options.forEach { (option) in
                
                if trackIndex == index {
                    PKLog.trace("option:: \(option)")
                    
                    if option.mediaType == type {
                        item.select(option, in: textSelectionGroup!)
                    }
                }
                
                trackIndex += 1
            }
        }
    }
}
