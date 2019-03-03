//
//  UIColor+Name.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 28/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit

extension UIColor {
    var name: String {
        switch self {
        case .black:
            return "black"
        case .darkGray:
            return "darkGray"
        case .lightGray:
            return "lightGray"
        case .white:
            return "white"
        case .gray:
            return "gray"
        case .red:
            return "red"
        case .green:
            return "green"
        case .blue:
            return "blue"
        case .cyan:
            return "cyan"
        case .yellow:
            return "yellow"
        case .magenta:
            return "magenta"
        case .orange:
            return "orange"
        case .purple:
            return "purple"
        case .brown:
            return "brown"
        case .clear:
            return "clear"
        default:
            return ""
        }
    }
    
    static func fromName(_ name: String) -> UIColor {
        switch name {
        case "black":
            return UIColor.black
        case "darkGray":
            return UIColor.darkGray
        case "lightGray":
            return UIColor.lightGray
        case "white":
            return UIColor.white
        case "gray":
            return UIColor.gray
        case "red":
            return UIColor.red
        case "green":
            return UIColor.green
        case "blue":
            return UIColor.blue
        case "cyan":
            return UIColor.cyan
        case "yellow":
            return UIColor.yellow
        case "magenta":
            return UIColor.magenta
        case "orange":
            return UIColor.orange
        case "purple":
            return UIColor.purple
        case "brown":
            return UIColor.brown
        case "clear":
            return UIColor.clear
        default:
            return UIColor()
        }
    }
}
