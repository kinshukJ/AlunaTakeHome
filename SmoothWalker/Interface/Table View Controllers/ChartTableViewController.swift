/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A table view controller that displays health data with a chart header view.
*/

import UIKit
import CareKitUI
import HealthKit

private extension CGFloat {
    static let inset: CGFloat = 20
    static let itemSpacing: CGFloat = 12
    static let itemSpacingWithTitle: CGFloat = 0
}

/// A `DataTableViewController` with a chart header view.
class ChartTableViewController: DataTableViewController {
    
    // MARK: - UI Properties
    
    var showDateRangeOptions = false
    
    lazy var headerView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
        
    lazy var chartView: OCKCartesianChartView = {
        let chartView = OCKCartesianChartView(type: .bar)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.applyHeaderStyle()
        
        return chartView
    }()
    
    var selectedDateRange = DateRange.week
    
    lazy var segmentControl: UISegmentedControl = {
        let segmentItems = [DateRange.day.rawValue, DateRange.week.rawValue, DateRange.month.rawValue]
        let control = UISegmentedControl(items: segmentItems)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        control.selectedSegmentIndex = 1
        return control
    }()
    
    // MARK: - View Life Cycle Overrides
    
    override func updateViewConstraints() {
        stackViewBottomConstraint?.constant = showGroupedTableViewTitle ? .itemSpacingWithTitle : .itemSpacing
        
        super.updateViewConstraints()
    }
    
    override func setUpViewController() {
        super.setUpViewController()
        
        setUpHeaderView()
        setUpConstraints()
    }
    
    override func setUpTableView() {
        super.setUpTableView()
        
        showGroupedTableViewTitle = true
    }
    
    @objc private func segmentControl(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            selectedDateRange = .day
        case 1:
            selectedDateRange = .week
        case 2:
            selectedDateRange = .month
        default:
            break
        }
    }
    
    private func setUpHeaderView() {
        if showDateRangeOptions {
            stackView.addArrangedSubview(segmentControl)
        }
        
        stackView.addArrangedSubview(chartView)

        headerView.addSubview(stackView)
        
        // headerView.addSubview(testLabel)
        tableView.tableHeaderView = headerView
    }

    private func setUpConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        constraints += createHeaderViewConstraints()
        constraints += createStackViewConstraints()
        
        chartView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        chartView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        segmentControl.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = showDateRangeOptions
        segmentControl.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = showDateRangeOptions
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func createHeaderViewConstraints() -> [NSLayoutConstraint] {
        let leading = headerView.leadingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.leadingAnchor, constant: .inset)
        let trailing = headerView.trailingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.trailingAnchor, constant: -.inset)
        let top = headerView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: .itemSpacing)
        let centerX = headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        
        return [leading, trailing, top, centerX]
    }
    
    private var stackViewBottomConstraint: NSLayoutConstraint?
    private func createStackViewConstraints() -> [NSLayoutConstraint] {
        let leading = stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor)
        let top = stackView.topAnchor.constraint(equalTo: headerView.topAnchor)
        let trailing = stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        let bottomConstant: CGFloat = showGroupedTableViewTitle ? .itemSpacingWithTitle : .itemSpacing
        let bottom = stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -bottomConstant)
        
        stackViewBottomConstraint = bottom
        
        trailing.priority -= 1
        bottom.priority -= 1

        return [leading, top, trailing, bottom]
    }
}
