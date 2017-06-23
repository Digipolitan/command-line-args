//
//  CommandLineError.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 19/06/2017.
//

import Foundation

public enum CommandLineError: Error {

    case missingRequiredArgument(node: CommandNode)
    case groupCommand(node: CommandNode)
    case commandNotFound
}
