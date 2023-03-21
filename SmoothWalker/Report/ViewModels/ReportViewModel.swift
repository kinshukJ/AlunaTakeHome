//
//  ReportViewModel.swift
//  SmoothWalker
//
//  Created by Kinshuk Juneja on 3/19/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import HealthKit


/// Protocol describing how view  talks to the view model
protocol ReportViewOutput: AnyObject {
    /// Returns the title for the view controller
    var title: String { get }
    
    /// Manages the date range for a report. Eg: Day, week or month
    var selectedDateRange: DateRange { get set }
    
    /// Returns data values of the type [HealthDataTypeValue]. Usually used in tables
    var dataValues: [HealthDataTypeValue] { get }
    
    /// Returns data values of the type [Double]. Usually used in charts
    var chartValues: [Double] { get }
    
    /// Fetches the data to update dataValues and chartValues
    func loadData()
}

final class ReportViewModel: ReportViewOutput {
        
    private var dataTypeIdentifier = HKQuantityTypeIdentifier.walkingSpeed.rawValue
    
    weak private var view: ReportViewInput?
    
    init(view: ReportViewInput, dataTypeIdentifier: String) {
        self.view = view
        self.dataTypeIdentifier = dataTypeIdentifier
    }
    
    // ReportViewOutput related properties and functions
    
    var title: String {
        "🚶🏼‍♀️Avg Walking Speed"
    }
    
    // Load data anytime date range changes
    var selectedDateRange: DateRange = .week {
        didSet {
            loadData()
        }
    }
    
    var dataValues: [HealthDataTypeValue] = []
    
    var chartValues: [Double] = []
  
    func loadData() {
        performQuery {
            DispatchQueue.main.async {
                self.view?.refresh()
            }
        }
    }
}

extension ReportViewModel {
    
    // MARK: Data Functions
    
    // This should ideally be in a protocol based ReportDataService struct. That way we can mock it for unit testing. 
    private func performQuery(completion: @escaping () -> Void) {
        // Set dates
        let startDate = getStartDate(for: selectedDateRange)
        let endDate = Date()
        
        let predicate = createPredicate(for: selectedDateRange, from: endDate)
        let dateInterval = DateComponents(day: 1)
        
        self.dataValues = []
        self.chartValues = []
        
        // Process data.
        let statisticsOptions = getStatisticsOptions(for: dataTypeIdentifier)
        let initialResultsHandler: (HKStatisticsCollection) -> Void = { (statisticsCollection) in
            
            statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                
                var dataValue = HealthDataTypeValue(startDate: statistics.startDate,
                                                    endDate: statistics.endDate,
                                                    value: 0)

                if let quantity = getStatisticsQuantity(for: statistics, with: statisticsOptions),
                   let unit = preferredUnit(for: self.dataTypeIdentifier) {
                    let value = quantity.doubleValue(for: unit)
                    dataValue.value = value
                    self.dataValues.append(dataValue)
                }
                
                self.chartValues.append(dataValue.value)
            }
                        
            completion()
        }
        
        // Fetch statistics.
        HealthData.fetchStatistics(with: HKQuantityTypeIdentifier(rawValue: dataTypeIdentifier),
                                   predicate: predicate,
                                   options: statisticsOptions,
                                   startDate: startDate,
                                   interval: dateInterval,
                                   completion: initialResultsHandler)
        
    }
}
