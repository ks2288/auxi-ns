//
//  Codable+StringBacked.swift
//  auxi-ns
//
//

import Foundation

protocol StringRepresentable: CustomStringConvertible, Codable {
    init?(_ string: String)
}

protocol StringBacked: CustomStringConvertible, Codable {
    init?(_ string: String)
}

extension StringBacked {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        guard let value = Self(string) else {
            let description = "Failed to convert custom object type instance from \"\(string)\""
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: description)
        }
        
        self = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}
