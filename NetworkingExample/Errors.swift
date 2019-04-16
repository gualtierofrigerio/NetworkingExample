//
//  File.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 16/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

enum DatasourceErrors : Error {
    case networkError
    case wrongURL
    case decodingError
}

extension DatasourceErrors : LocalizedError {
    var errorDescription : String? {
        switch self {
        case .networkError:
            return NSLocalizedString("NetworkError", comment: "")
        case .wrongURL:
            return NSLocalizedString("WrongURL", comment: "")
        case .decodingError:
            return NSLocalizedString("DecodingError", comment: "")
        }
    }
}
