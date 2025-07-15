//
//  HoldingsViewController.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//

import UIKit
import Foundation

class HoldingsViewController: UIViewController {

    private let viewModel = HoldingsViewModel()

    private let tableView = UITableView()
    private let portfolioSummaryView = PortfolioSummaryView()
    private var portfolioSummaryViewHeightConstraint: NSLayoutConstraint!

    private var isSummaryExpanded = false {
        didSet {
            animatePortfolioSummaryView()
        }
    }
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .gray //
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        portfolioSummaryView.isHidden = true
        //setupViewModelBindings()
        viewModel.fetchHoldings()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Portfolio"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .systemBlue

       

        // MARK: Table View Setup
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HoldingCell.self, forCellReuseIdentifier: HoldingCell.reuseIdentifier)
        tableView.tableFooterView = UIView() // Hides empty cells
        view.addSubview(tableView)

        // MARK: Constraints
        NSLayoutConstraint.activate([
            // Portfolio Summary View Constraints
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16), // Adjust as needed
        ])

       

      
        
        // MARK: Portfolio Summary View Setup
        portfolioSummaryView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(portfolioSummaryView)
        
        NSLayoutConstraint.activate([
            // Table View Constraints
            portfolioSummaryView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            portfolioSummaryView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            portfolioSummaryView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            portfolioSummaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(togglePortfolioSummary))
        portfolioSummaryView.addGestureRecognizer(tapGesture)
        portfolioSummaryView.isUserInteractionEnabled = true
        portfolioSummaryViewHeightConstraint = portfolioSummaryView.heightAnchor.constraint(equalToConstant: 60) // Adjusted for single label + padding
                portfolioSummaryViewHeightConstraint.isActive = true
        portfolioSummaryViewHeightConstraint.isActive = true
        
        
        view.addSubview(activityIndicator)
            NSLayoutConstraint.activate([
                    activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }

    private func bindViewModel() {
        viewModel.onHoldingsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onPortfolioSummaryUpdated = { [weak self] in
            self?.portfolioSummaryView.isHidden = false
            guard let summary = self?.viewModel.portfolioSummary else { return }
            self?.portfolioSummaryView.configure(with: summary)
        }

        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showAlert(for: error)
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc private func togglePortfolioSummary() {
        isSummaryExpanded.toggle()
    }

    private func animatePortfolioSummaryView() {
        portfolioSummaryView.configureExpandedState(isExpanded: isSummaryExpanded)

        portfolioSummaryViewHeightConstraint.constant = isSummaryExpanded ? 200 : 60 // Adjust expanded height as needed
        UIView.animate(withDuration: 0.3) {
            
            self.view.layoutIfNeeded()
        }
    }

    private func showAlert(for error: NetworkError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension HoldingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.holdings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HoldingCell.reuseIdentifier, for: indexPath) as? HoldingCell else {
            return UITableViewCell()
        }
        let holding = viewModel.holdings[indexPath.row]
        cell.configure(with: holding)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HoldingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Adjust row height as needed
    }
}
