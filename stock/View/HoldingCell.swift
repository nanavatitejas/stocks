//
//  HoldingCell.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//

import Foundation
import UIKit

class HoldingCell: UITableViewCell {
    static let reuseIdentifier = "HoldingCell"

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        return label
    }()

    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .gray
        return label
    }()

    private let ltpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    private let pnlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(symbolLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(ltpLabel)
        contentView.addSubview(pnlLabel)

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        ltpLabel.translatesAutoresizingMaskIntoConstraints = false
        pnlLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: ltpLabel.leadingAnchor, constant: -8),

            quantityLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor, constant: 4),
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quantityLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            ltpLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            ltpLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ltpLabel.widthAnchor.constraint(equalToConstant: 150),

            pnlLabel.topAnchor.constraint(equalTo: ltpLabel.bottomAnchor, constant: 4),
            pnlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pnlLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    func configure(with holding: UserHolding) {
        symbolLabel.text = holding.symbol
        quantityLabel.text = "NET QTY: \(holding.quantity)"
        ltpLabel.text = "LTP: ₹\(String(format: "%.2f", holding.ltp))"

        let pnl = (holding.ltp - holding.avgPrice) * Double(holding.quantity)
        pnlLabel.text = "P&L: ₹\(String(format: "%.2f", pnl))"
        pnlLabel.textColor = pnl >= 0 ? .systemGreen : .systemRed
    }
}
