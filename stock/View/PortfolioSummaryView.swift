//
//  PortfolioSummaryView.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//


import UIKit

class PortfolioSummaryView: UIView {

    private let currentValueKeyLabel = UILabel()
    private let totalInvestmentKeyLabel = UILabel()
    private let todayPNLKeyLabel = UILabel()
    private let totalPNLKeyLabel = UILabel()

    private let currentValueValueLabel = UILabel()
    private let totalInvestmentValueLabel = UILabel()
    private let todayPNLValueLabel = UILabel()
    private let totalPNLValueLabel = UILabel()

    let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.up")
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Set a fixed width/height for the arrow if needed
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        return imageView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        clipsToBounds = true

        [currentValueKeyLabel, totalInvestmentKeyLabel, todayPNLKeyLabel, totalPNLKeyLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.textAlignment = .left
        }

        [currentValueValueLabel, totalInvestmentValueLabel, todayPNLValueLabel, totalPNLValueLabel].forEach {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.textAlignment = .right
        }

        let createHorizontalStackView = { (keyView: UIView, valueLabel: UILabel) -> UIStackView in
            let stack = UIStackView(arrangedSubviews: [keyView, valueLabel])
            stack.axis = .horizontal
            stack.distribution = .fillProportionally // Allows content to size
            stack.spacing = 8 // Spacing between the key view and the value label
            return stack
        }

        let currentValueStack = createHorizontalStackView(currentValueKeyLabel, currentValueValueLabel)
        let totalInvestmentStack = createHorizontalStackView(totalInvestmentKeyLabel, totalInvestmentValueLabel)
        let todayPNLStack = createHorizontalStackView(todayPNLKeyLabel, todayPNLValueLabel)

        let totalPNLKeyWithArrowStack: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [totalPNLKeyLabel, arrowImageView])
            stack.axis = .horizontal
            stack.alignment = .leading
            stack.spacing = 0
            return stack
        }()

        let totalPNLStack = createHorizontalStackView(totalPNLKeyWithArrowStack, totalPNLValueLabel)


        contentStackView.addArrangedSubview(currentValueStack)
        contentStackView.addArrangedSubview(totalInvestmentStack)
        contentStackView.addArrangedSubview(todayPNLStack)
        contentStackView.addArrangedSubview(totalPNLStack)


        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        configureExpandedState(isExpanded: false)
    }

    func configure(with summary: PortfolioSummary) {
        currentValueKeyLabel.text = "Current Value:"
        currentValueValueLabel.text = "₹\(String(format: "%.2f", summary.currentValue))"

        totalInvestmentKeyLabel.text = "Total Investment:"
        totalInvestmentValueLabel.text = "₹\(String(format: "%.2f", summary.totalInvestment))"

        todayPNLKeyLabel.text = "Today's P&L:"
        todayPNLValueLabel.text = "₹\(String(format: "%.2f", summary.todayPNL))"

        totalPNLKeyLabel.text = "Profit & Loss:"
        totalPNLValueLabel.text = "₹\(String(format: "%.2f", summary.totalPNL)) (\(String(format: "%.2f", summary.totalPNLPercentage))%)"

        // Set colors for P&L values
        totalPNLValueLabel.textColor = summary.totalPNL >= 0 ? .systemGreen : .systemRed
        todayPNLValueLabel.textColor = summary.todayPNL >= 0 ? .systemGreen : .systemRed
    }

    func configureExpandedState(isExpanded: Bool) {
        currentValueKeyLabel.superview?.isHidden = !isExpanded
        totalInvestmentKeyLabel.superview?.isHidden = !isExpanded
        todayPNLKeyLabel.superview?.isHidden = !isExpanded
        if isExpanded {
            arrowImageView.image = UIImage(systemName: "chevron.down")

        } else {
            arrowImageView.image = UIImage(systemName: "chevron.up")
        }
    }
}
