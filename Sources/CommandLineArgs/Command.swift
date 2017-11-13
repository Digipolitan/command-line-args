//
//  Command.swift
//  CommandLineArgs
//
//  Created by Benoit BRIATTE on 19/06/2017.
//

import Foundation

public typealias CommandHandler = ([String: Any]) throws -> Void

public protocol Command {

    func run(_ arguments: [String: Any]) throws

    var definition: CommandDefinition { get }
}
