//
//  Keyy.swift
//  Oasis
//
//  Created by WU Yifan on 2/10/22.
//

import Foundation

struct Keyy : Hashable {
    let queryIndex : Int
    let resultIndex : Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(queryIndex)
        hasher.combine(resultIndex)
    }
    
    static func ==(lhs: Keyy, rhs: Keyy) -> Bool{
        return lhs.queryIndex == rhs.queryIndex && lhs.resultIndex == rhs.resultIndex
    }

}

