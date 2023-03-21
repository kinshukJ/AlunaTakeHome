/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A collection of utility functions used for charting and visualizations.
 */

import Foundation
import CareKitUI

// MARK: - Chart Date UI

/// Return a label describing the date range of the chart for the last week. Example: "Jun 3 - Jun 10, 2020"
func createChartDateRangeLabel(for dateRange: DateRange = .week, lastDate: Date = Date()) -> String {
    let calendar: Calendar = .current
    
    let endOfWeekDate = lastDate
    let startOfWeekDate = getStartDate(for: dateRange, from: endOfWeekDate)
    
    let monthDayDateFormatter = DateFormatter()
    monthDayDateFormatter.dateFormat = "MMM d"
    let monthDayYearDateFormatter = DateFormatter()
    monthDayYearDateFormatter.dateFormat = "MMM d, yyyy"
    
    var startDateString = monthDayDateFormatter.string(from: startOfWeekDate)
    var endDateString = monthDayYearDateFormatter.string(from: endOfWeekDate)
    
    // If the start and end dates are in the same month.
    if calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .month) {
        let dayYearDateFormatter = DateFormatter()
        
        dayYearDateFormatter.dateFormat = "d, yyyy"
        endDateString = dayYearDateFormatter.string(from: endOfWeekDate)
    }
    
    // If the start and end dates are in different years.
    if !calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .year) {
        startDateString = monthDayYearDateFormatter.string(from: startOfWeekDate)
    }
    
    return String(format: "%@–%@", startDateString, endDateString)
}

private func createMonthDayDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "MM/dd"
    
    return dateFormatter
}

func createChartDateLastUpdatedLabel(_ dateLastUpdated: Date) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateStyle = .medium
    
    return "last updated on \(dateFormatter.string(from: dateLastUpdated))"
}

/// Returns an array of horizontal axis markers based on the desired time frame, where the last axis marker corresponds to `lastDate`
/// `useWeekdays` will use short day abbreviations (e.g. "Sun, "Mon", "Tue") instead.
/// Defaults to showing the current day as the last axis label of the chart and going back one week.
func createHorizontalAxisMarkers(for dateRange: DateRange = .week, lastDate: Date = Date()) -> [String] {
    let calendar: Calendar = .current
    let weekdayTitles = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    let weekday = calendar.component(.weekday, from: lastDate)
    let weekdaysArray = Array(weekdayTitles[weekday..<weekdayTitles.count]) + Array(weekdayTitles[0..<weekday])
    
    switch dateRange {
    case .day:
        let lastTwoDays = weekdaysArray.suffix(2)
        return Array(lastTwoDays)
    case .week:
        return weekdaysArray
    case .month:
        let endDate = lastDate
        let startDate = getStartDate(for: dateRange, from: endDate)
        let midDate = Calendar.current.date(byAdding: .day, value: 15, to: startDate)!
        
        let dateFormatter = createMonthDayDateFormatter()
        
        let startDateFormatted = dateFormatter.string(from: startDate)
        let midDateFormatted = dateFormatter.string(from: midDate)
        let endDateFormatted = dateFormatter.string(from: endDate)
        
        return [startDateFormatted, midDateFormatted, endDateFormatted]
    }
}

func createHorizontalAxisMarkers(for dates: [Date]) -> [String] {
    let dateFormatter = createMonthDayDateFormatter()
    
    return dates.map { dateFormatter.string(from: $0) }
}
