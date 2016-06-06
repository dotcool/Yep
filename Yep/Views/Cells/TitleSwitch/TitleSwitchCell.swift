//
//  TitleSwitchCell.swift
//  Yep
//
//  Created by NIX on 16/6/6.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import UIKit

class TitleSwitchCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blackColor()
        label.font = UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        return label
    }()

    lazy var toggleSwitch: UISwitch = {
        let s = UISwitch()
        return s
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeUI() {

        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false

        let views = [
            "titleLable": titleLabel,
            "toggleSwitch": toggleSwitch,
        ]

        let constraintsH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[titleLable]-[toggleSwitch]-15-|", options: [.AlignAllCenterY], metrics: nil, views: views)

        let centerY = titleLabel.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor)

        NSLayoutConstraint.activateConstraints(constraintsH)
        NSLayoutConstraint.activateConstraints([centerY])
    }
}

