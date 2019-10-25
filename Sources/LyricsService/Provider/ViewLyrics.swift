//
//  ViewLyrics.swift
//
//  This file is part of LyricsX - https://github.com/ddddxxx/LyricsX
//  Copyright (C) 2017  Xander Deng
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import LyricsCore
import CXShim

private let viewLyricsSearchURL = URL(string: "http://search.crintsoft.com/searchlyrics.htm")!
private let viewLyricsItemBaseURL = URL(string: "http://viewlyrics.com/")!

extension LyricsProviders {
    public final class ViewLyrics {}
}

extension LyricsProviders.ViewLyrics: _LyricsProvider {
    
    public static let source: LyricsProviderSource = .viewLyrics
    
    func assembleQuery(artist: String, title: String, page: Int = 0) -> Data {
        let watermark = "Mlv1clt4.0"
        let queryForm = "<?xml version='1.0' encoding='utf-8'?><searchV1 artist='\(artist)' title='\(title)' OnlyMatched='1' client='MiniLyrics' RequestPage='\(page)'/>"
        let queryhash = md5(queryForm + watermark)
        let header = Data([2, 0, 4, 0, 0, 0])
        return header + queryhash + queryForm.data(using: .utf8)!
    }
    
    func lyricsSearchPublisher(request: LyricsSearchRequest) -> AnyPublisher<ViewLyricsResponseSearchResult, Never> {
        guard case let .info(title, artist) = request.searchTerm else {
            // cannot search by keyword
            return Empty().eraseToAnyPublisher()
        }
        var req = URLRequest(url: viewLyricsSearchURL)
        req.httpMethod = "POST"
        req.addValue("MiniLyrics", forHTTPHeaderField: "User-Agent")
        req.httpBody = assembleQuery(artist: artist, title: title)
        return sharedURLSession.cx.dataTaskPublisher(for: req)
            .tryMap {
                guard $0.data.count > 22 else { throw NilError.error }
                let magic = $0.data[1]
                let decrypted = Data($0.data[22...].map { $0 ^ magic })
                let parser = ViewLyricsResponseXMLParser()
                try parser.parseResponse(data: decrypted)
                return parser.result
            }
            .replaceError(with: [])
            .flatMap(Publishers.Sequence.init)
            .eraseToAnyPublisher()
    }
    
    func lyricsFetchPublisher(token: ViewLyricsResponseSearchResult) -> AnyPublisher<Lyrics, Never> {
        guard let url = URL(string: token.link, relativeTo: viewLyricsItemBaseURL) else {
            return Empty().eraseToAnyPublisher()
        }
        return sharedURLSession.cx.dataTaskPublisher(for: url)
            .compactMap {
                guard let lrcContent = String(data: $0.data, encoding: .utf8),
                    let lrc = Lyrics(lrcContent) else {
                        return nil
                }
                lrc.metadata.remoteURL = url
                lrc.metadata.source = .viewLyrics
                lrc.metadata.providerToken = token.link
                if let length = token.timelength, lrc.length == nil {
                    lrc.length = TimeInterval(length)
                }
                return lrc
            }.catch()
            .eraseToAnyPublisher()
    }
}

private enum NilError: Error {
    case error
}

private class ViewLyricsResponseXMLParser: NSObject, XMLParserDelegate {
    
    var result: [ViewLyricsResponseSearchResult] = []
    
    func parseResponse(data: Data) throws {
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            throw parser.parserError!
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        guard elementName == "fileinfo" else {
            return
        }
        guard let link = attributeDict["link"],
            let artist = attributeDict["artist"],
            let title = attributeDict["title"],
            let album = attributeDict["album"] else {
                return
        }
        let uploader = attributeDict["uploader"]
        var timelength: Int?
        if let lenStr = attributeDict["timelength"], let len = Int(lenStr), len != 65535 {
            timelength = len
        }
        let rate = attributeDict["rate"].flatMap(Double.init)
        let ratecount = attributeDict["ratecount"].flatMap(Int.init)
        let downloads = attributeDict["downloads"].flatMap(Int.init)
        let item = ViewLyricsResponseSearchResult(link: link, artist: artist, title: title, album: album, uploader: uploader, timelength: timelength, rate: rate, ratecount: ratecount, downloads: downloads)
        result.append(item)
    }
}