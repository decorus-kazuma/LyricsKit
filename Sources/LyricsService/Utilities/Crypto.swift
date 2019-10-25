//
//  CommonCrypto+Extension.swift
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
import CommonCrypto

func md5(_ string: String) -> Data {
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    digestData.withUnsafeMutableBytes { digestBytes in
        let digestBytes = digestBytes.bindMemory(to: UInt8.self)
        messageData.withUnsafeBytes { messageBytes in
            _ = CC_MD5(messageBytes.baseAddress, CC_LONG(messageBytes.count), digestBytes.baseAddress)
        }
    }
    return digestData
}