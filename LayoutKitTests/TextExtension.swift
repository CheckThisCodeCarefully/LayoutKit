//
//  TextExtension.swift
//  LayoutKit
//
//  Created by Nick Snyder on 10/18/16.
//
//

import UIKit
import LayoutKit

extension Text {
    struct TestCase {
        let text: Text
        let font: UIFont?
    }

    static var testCases: [TestCase] {
        let fontNames: [String?] = [
            nil,
            "Helvetica",
            "Helvetica Neue"
        ]

        let texts: [Text] = [
            .unattributed(""),
            .unattributed( " "),
            .unattributed("Hi"),
            .unattributed("Hello world"),
            .unattributed("Hello! 😄😄😄")
        ]

        let fontSizes = 0...100

        var tests = [TestCase]()
        for fontName in fontNames {
            for fontSize in fontSizes {
                let font = fontName.flatMap({ (fontName) -> UIFont? in
                    return UIFont(name: fontName, size: CGFloat(fontSize))
                })
                for text in texts {
                    tests.append(TestCase(text: text, font: font))
                }
            }

        }
        return tests
    }
}
