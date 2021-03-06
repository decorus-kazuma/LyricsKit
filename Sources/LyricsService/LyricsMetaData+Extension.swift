//
//  LyricsMetaData+Extension.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng. Licensed under GPLv3.
//

import Foundation
import LyricsCore

extension Lyrics.MetaData.Key {
    public static var source        = Lyrics.MetaData.Key("source")
    public static var request       = Lyrics.MetaData.Key("request")
    public static var searchIndex   = Lyrics.MetaData.Key("searchIndex")
    public static var remoteURL     = Lyrics.MetaData.Key("remoteURL")
    public static var artworkURL    = Lyrics.MetaData.Key("artworkURL")
    public static var providerToken = Lyrics.MetaData.Key("providerToken")
    static var quality              = Lyrics.MetaData.Key("quality")
}

extension Lyrics.MetaData {
    
    public var source: LyricsProviderSource? {
        get { return data[.source] as? LyricsProviderSource }
        set { data[.source] = newValue }
    }
    
    public var request: LyricsSearchRequest? {
        get { return data[.request] as? LyricsSearchRequest }
        set { data[.request] = newValue }
    }
    
    public var searchIndex: Int {
        get { return data[.searchIndex] as? Int ?? 0 }
        set { data[.searchIndex] = newValue }
    }
    
    public var remoteURL: URL? {
        get { return data[.remoteURL] as? URL }
        set { data[.remoteURL] = newValue }
    }
    
    public var artworkURL: URL? {
        get { return data[.artworkURL] as? URL }
        set { data[.artworkURL] = newValue }
    }
    
    public var providerToken: String? {
        get { return data[.providerToken] as? String }
        set { data[.providerToken] = newValue }
    }
    
    var quality: Double? {
        get { return data[.quality] as? Double }
        set { data[.quality] = newValue }
    }
}
