//
//  Environment.swift
//  SpectaLocks
//
//  Created by Szilárd Sebők on 2022. 07. 31..
//

import Foundation

protocol Environment {
    var localizationsUrl: String { get }
    var appInfoUrl: String { get }
}

class GistUrlEnvironment: Environment {
    var localizationsUrl = "https://gist.githubusercontent.com/szilardcodes/2171232df9660ed7762f81b71d9f535c/raw"
    let appInfoUrl = "https://gist.githubusercontent.com/szilardcodes/f4c6964292c47d693412b5e504b11520/raw"
}

