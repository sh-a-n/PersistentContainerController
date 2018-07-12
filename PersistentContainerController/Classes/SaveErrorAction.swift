//
//  SaveErrorAction.swift
//  PersistentContainerController
//
//  Created by Aleksey Shabrov on 12.07.2018.
//  Copyright © 2018 High Technologies Center. All rights reserved.
//

import Foundation

/// Enum for action to perform when error occured while saving
public enum SaveErrorAction {
    /// Do nothing
    case none
    /// Removes everything from the undo stack, discards all insertions and deletions, and restores updated objects to their last committed values.
    case rollback
}
