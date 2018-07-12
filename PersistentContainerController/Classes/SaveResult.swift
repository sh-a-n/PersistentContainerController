//
//  SaveResult.swift
//  PersistentContainerController
//
//  Created by Aleksey Shabrov on 12.07.2018.
//

import Foundation

/// Enum for save operation result
public enum SaveResult {
    /// saved successfully
    case success
    /// error occured
    ///
    /// - parameter error: error occured while saving
    case error(Error)
}
