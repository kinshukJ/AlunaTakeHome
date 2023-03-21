//
//  ContentView.swift
//  AppleWatchSmoothWalker Watch App
//
//  Created by Kinshuk Juneja on 3/20/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    private var healthStore = HKHealthStore()
    private let averageWalkingSpeedQuantity = HKUnit(from: "mi/hr")
    private let walkingSpeedIdentifier = HKQuantityTypeIdentifier.walkingSpeed.rawValue
    let dateFormatter = DateFormatter()
    
    @State var dataValues: [HealthDataTypeValue] = []
    
    var body: some View {
            VStack {
                List {
                    Text("🚶🏼‍♀️Last Week's Walking Speed")
                        .padding()
                        .font(.headline)
    
                    ForEach(dataValues) { dataValue in
                        HStack {
                            Text(formattedValue(dataValue.value, typeIdentifier: walkingSpeedIdentifier) ?? "0.00")
                            Text(dateFormatter.string(from: dataValue.startDate))
                        }
                    }
                }
            }
        .padding()
        .onAppear(perform: start)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func start() {
        autorizeHealthKit()
        getData()
        dateFormatter.dateStyle = .short
    }
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: walkingSpeedIdentifier))!]

        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    func getData() {
        let startDate = getStartDate(for: DateRange.week)
        let endDate = Date()
        
        let predicate = createPredicate(for: DateRange.week, from: endDate)
        let dateInterval = DateComponents(day: 1)
        
        self.dataValues = []
        var healthDataValues: [HealthDataTypeValue] = []
        // Process data.
        let statisticsOptions = getStatisticsOptions(for: walkingSpeedIdentifier)
        let initialResultsHandler: (HKStatisticsCollection) -> Void = { (statisticsCollection) in
            
            statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                
                var dataValue = HealthDataTypeValue(startDate: statistics.startDate,
                                                    endDate: statistics.endDate,
                                                    value: 0)

                if let quantity = getStatisticsQuantity(for: statistics, with: statisticsOptions),
                   let unit = preferredUnit(for: walkingSpeedIdentifier) {
                    let value = quantity.doubleValue(for: unit)
                    dataValue.value = value
                    healthDataValues.append(dataValue)
                }
                
            }
            self.dataValues = healthDataValues.reversed()
        }
        
        // Fetch statistics.
        HealthData.fetchStatistics(with: HKQuantityTypeIdentifier(rawValue: walkingSpeedIdentifier),
                                   predicate: predicate,
                                   options: statisticsOptions,
                                   startDate: startDate,
                                   interval: dateInterval,
                                   completion: initialResultsHandler)
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
