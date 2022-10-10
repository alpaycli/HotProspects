//
//  FileManager.swift
//  HotProspects
//
//  Created by Alpay Calalli on 09.10.22.
//

import Foundation

extension FileManager{
    static var documentsDirectory: URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
