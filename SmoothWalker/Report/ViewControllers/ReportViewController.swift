//
//  ReportViewController.swift
//  SmoothWalker
//
//  Created by Kinshuk Juneja on 3/19/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit
import HealthKit
import CareKitUI


/// Protocol describing how view model talks to the view
protocol ReportViewInput: AnyObject {
    
    /// Asks the view to refresh itself
    func refresh()
}

final class ReportViewController: ChartTableViewController {
    
    override init(dataTypeIdentifier: String) {
        super.init(dataTypeIdentifier: dataTypeIdentifier)
        super.showDateRangeOptions = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewModel: ReportViewOutput!
    
    // Any change to data range selection updates the view model
    override var selectedDateRange: DateRange {
        didSet {
            viewModel.selectedDateRange = selectedDateRange
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Authorization
        if !dataValues.isEmpty { return }
        
        HealthData.requestHealthDataAccessIfNeeded(dataTypes: [dataTypeIdentifier]) { (success) in
            if success {
                // Ask the view model to load data
                self.viewModel.loadData()
            }
        }
        
        setupViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We initialize the view model
        viewModel = ReportViewModel(view: self, dataTypeIdentifier: dataTypeIdentifier)
    }
    
    private func setupViews() {
       
        navigationItem.title = viewModel.title
    }
}

//VM -> V related methods
extension ReportViewController: ReportViewInput {
    
    func refresh() {
        
        // Update data for table
        dataValues = viewModel.dataValues
        
        // Update data for chart
        updateChartView(with: dataTypeIdentifier, values: viewModel.chartValues)
        
        reloadData()
    }
    
    private func updateChartView(with dataTypeIdentifier: String, values: [Double]) {
        
        // Update headerView
        chartView.headerView.titleLabel.text = getDataTypeName(for: dataTypeIdentifier) ?? "Data"
        chartView.headerView.detailLabel.text = createChartDateRangeLabel(for: selectedDateRange, lastDate: Date())
        
        // Update graphView
        chartView.applyDefaultConfiguration()
        chartView.graphView.horizontalAxisMarkers = createHorizontalAxisMarkers(for: viewModel.selectedDateRange ,lastDate: Date())
        
        // Update graphView dataSeries
        let dataPoints: [CGFloat] = values.map { CGFloat($0) }
        
        guard
            let unit = preferredUnit(for: dataTypeIdentifier),
            let unitTitle = getUnitDescription(for: unit)
        else {
            return
        }
        
        chartView.graphView.dataSeries = [
            OCKDataSeries(values: dataPoints, title: unitTitle)
        ]
    }
}
