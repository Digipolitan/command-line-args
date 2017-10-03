//
//  CommandLineError.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 19/06/2017.
//

import Foundation

public enum CommandLineError: Error {

    case command(node: CommandNode, missingParameters: [String])
    case commandNotFound
    case unimplementedCommand
}
