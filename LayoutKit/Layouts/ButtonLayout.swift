// Copyright 2016 LinkedIn Corp.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import UIKit

/**
 Layout for a UIButton.
 */
open class ButtonLayout<Button: UIButton>: BaseLayout<Button>, ConfigurableLayout {

    private let type: UIButtonType
    private let title: Text
    private let font: UIFont?

    public init(type: UIButtonType,
                title: Text,
                font: UIFont? = nil,
                alignment: Alignment = defaultAlignment,
                flexibility: Flexibility = defaultFlexibility,
                viewReuseId: String? = nil,
                config: ((Button) -> Void)? = nil) {

        self.type = type
        self.title = title
        self.font = font
        super.init(alignment: alignment, flexibility: flexibility, viewReuseId: viewReuseId, config: config)
    }

    open func measurement(within maxSize: CGSize) -> LayoutMeasurement {
        let titleSize = sizeOfTitle(within: maxSize)

        // This is observed padding behavior of UIButton.
        let width: CGFloat
        let height: CGFloat
        switch type {
        case .custom:
            width = ceil(max(titleSize.width, 30))
            height = ceil(titleSize.height + 12)
        case .system:
            width = ceil(max(titleSize.width, 30))
            height = ceil(titleSize.height + 12)
        case .contactAdd, .infoLight, .infoDark, .detailDisclosure:
            width = 22 + ceil(titleSize.width)
            height = 22
        default:
            // This case will get triggered if a new UIButtonType is created.
            // If this happens, we need to update this code with the new type!
            width = 0
            height = 0
        }

        let size = CGSize(width: width, height: height).decreasedToSize(maxSize)
        return LayoutMeasurement(layout: self, size: size, maxSize: maxSize, sublayouts: [])
    }

    /// Unlike UILabel, UIButton has nonzero height when the title is empty.
    private func sizeOfTitle(within maxSize: CGSize) -> CGSize {
        switch title {
        case .attributed(let text):
            if text.string == "" {
                let attributedText = NSMutableAttributedString(attributedString: text)
                attributedText.mutableString.setString(" ")
                return CGSize(width: 0, height: sizeOf(text: .attributed(attributedText), maxSize: maxSize).height)
            } else {
                return sizeOf(text: title, maxSize: maxSize)
            }
        case .unattributed(let text):
            if text == "" {
                return CGSize(width: 0, height: sizeOf(text: .unattributed(" "), maxSize: maxSize).height)
            } else {
                return sizeOf(text: title, maxSize: maxSize)
            }
        }
    }

    private func sizeOf(text: Text, maxSize: CGSize) -> CGSize {
        return LabelLayout(text: text, font: fontForMeasurement, numberOfLines: 0).measurement(within: maxSize).size
    }

    /**
     The font that should be used to measure the button's title.
     This is based on observed behavior of UIButton.
     */
    private var fontForMeasurement: UIFont {
        switch type {
        case .custom:
            return font ?? UIFont.systemFont(ofSize: 18)
        case .system:
            return font ?? UIFont.systemFont(ofSize: 15)
        case .contactAdd, .infoLight, .infoDark, .detailDisclosure:
            // Setting a custom font has no effect in this case.
            return UIFont.systemFont(ofSize: 15)
        default:
            // Unknown type that is not supported.
            return UIFont.systemFont(ofSize: 0)
        }
    }

    open func arrangement(within rect: CGRect, measurement: LayoutMeasurement) -> LayoutArrangement {
        let frame = alignment.position(size: measurement.size, in: rect)
        return LayoutArrangement(layout: self, frame: frame, sublayouts: [])
    }

    open override func makeView() -> View {
        return Button(type: type)
    }

    open override func configure(view: Button) {
        config?(view)
        if let font = font {
            view.titleLabel?.font = font
        }
        switch title {
        case .unattributed(let text):
            view.setTitle(text, for: .normal)
        case .attributed(let text):
            view.setAttributedTitle(text, for: .normal)
        }

    }
}

private let defaultAlignment = Alignment.topLeading
private let defaultFlexibility = Flexibility.flexible
