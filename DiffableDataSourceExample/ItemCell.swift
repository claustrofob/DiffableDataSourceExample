//
//  ItemCell.swift
//  DiffableDataSourceExample
//
//  Created by Mikalai Zmachynski on 23/09/2021.
//

import UIKit

class ItemCell: UITableViewCell {
    let label: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let guides = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: guides.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: guides.trailingAnchor),
            label.topAnchor.constraint(equalTo: guides.topAnchor),
            label.bottomAnchor.constraint(equalTo: guides.bottomAnchor)
        ])
    }
}
