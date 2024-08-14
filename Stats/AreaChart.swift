//
//  AreaChart.swift
//  Stats
//
//  Created by Deszip on 19.03.2024.
//

import SwiftUI
import Charts
import CoreData

enum ChartInterpolationMethod: Identifiable, CaseIterable {
    case linear
    case monotone
    case catmullRom
    case cardinal
    case stepStart
    case stepCenter
    case stepEnd

    var id: String { mode.description }

    var mode: InterpolationMethod {
        switch self {
        case .linear:
            return .linear
        case .monotone:
            return .monotone
        case .stepStart:
            return .stepStart
        case .stepCenter:
            return .stepCenter
        case .stepEnd:
            return .stepEnd
        case .catmullRom:
            return .catmullRom
        case .cardinal:
            return .cardinal
        }
    }
}

struct CodeValue: Equatable {
    let day: Date
    var lines: Int64
}

struct CodeValues: Equatable, Identifiable {
    var id: String { title }

    let title: String
    var values: [CodeValue]
}

struct GitContribution: Identifiable {
    let date: Date
    let level: Int64
    let id = UUID()
}

//protocol DataProvider {
//    func count() -> Int64
//    func value(index: Int64) -> Int64?
//}

//class RandomDataProvider: DataProvider {
//    func count() -> Int64 {
//        return 42
//    }
//
//    func value(index: Int64) -> Int64? {
//        return Int64.random(in: 0...10000)
//    }
//}

var firstDate: Date?

struct AreaChart: View {

    @ObservedObject var repo: STRepo

    @State private var lineWidth = 2.0
    @State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .blue
    @State private var showGradient = true
    @State private var gradientRange = 0.5

    private var gradient: Gradient {
        var colors = [chartColor]
        if showGradient {
            colors.append(chartColor.opacity(gradientRange))
        }
        return Gradient(colors: colors)
    }

    var body: some View {
        List {
            Section {
                chart
            }

            customisation
        }
        .navigationTitle(repo.name ?? "")
    }

    private func buildValues(repo: STRepo) -> [CodeValues] {
        var mainValues = CodeValues(title: "Line count", values: [])
        var additionalValues = CodeValues(title: "Tests line count", values: [])

        let samples: [STSample] = (repo.samples?.allObjects as? [STSample]) ?? []
        let sorted = samples.sorted(by: { lhs, rhs in return lhs.date ?? Date() < rhs.date ?? Date() })

        sorted.forEach {
            mainValues.values.append(CodeValue(day: $0.date ?? Date(), lines: $0.lineCount))
            additionalValues.values.append(CodeValue(day: $0.date ?? Date(), lines: $0.additionalLineCount))
        }

        return [mainValues, additionalValues]
    }
    
    private func buildContributions(repo: STRepo) -> [GitContribution] {
//        return GitHubData.contributions

        var contributions: [GitContribution] = []

        let samples: [STSample] = (repo.samples?.allObjects as? [STSample]) ?? []
        let sorted = samples.sorted(by: { lhs, rhs in return lhs.date ?? Date() < rhs.date ?? Date() })

        sorted.forEach {
            contributions.append(GitContribution(date: $0.date ?? Date(), level: $0.commitLinesCount))
        }

        return contributions
    }

    private func dayOfTheWeek(date: Date) -> Int {
        let day = (Calendar.current.dateComponents([.weekday], from: date).weekday ?? 1) - 1
        print("Day: \(day)")
        return day
    }

    private func relativeWeek(date: Date) -> Int {
//        if firstDate == nil {
//            let samples: [STSample] = (repo.samples?.allObjects as? [STSample]) ?? []
//            let sorted = samples.sorted(by: { lhs, rhs in return lhs.date ?? Date() < rhs.date ?? Date() })
//            firstDate = sorted.first?.date ?? Date()
//        }

        let firstDate = GitHubData.contributions.first?.date

        let daysApart = Calendar.current.dateComponents([.day], from: firstDate ?? Date(), to: date).day ?? 0
        
        print("Week: \(daysApart / 7)")

        return daysApart / 7
    }

    private var chart: some View {
        VStack {
            Chart(buildValues(repo: repo)) { series in
                ForEach(series.values, id: \.day) { element in
                    LineMark(
                        x: .value("Date", element.day),
                        y: .value("Sales", element.lines)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(by: .value("City", series.title))
                }
            }
            .chartXAxis(.automatic)
            .chartYAxis(.automatic)
            .chartLegend(.automatic)
            .frame(height: 300)
            
//            ContributionChartView(data: [], rows: 7, columns: 100, targetValue: 20)

            Chart(buildContributions(repo: repo)) { contribution in
                Plot {
                    RectangleMark(
                        xStart: .value("xStart", relativeWeek(date: contribution.date)),
                        xEnd: .value("xEnd", relativeWeek(date: contribution.date) + 1),
                        yStart: .value("yStart", dayOfTheWeek(date: contribution.date)),
                        yEnd: .value("yEnd", dayOfTheWeek(date: contribution.date) + 1)
                    )
                    .foregroundStyle(by: .value("Level", contribution.level))
                    .interpolationMethod(.cardinal)
                }
            }
            .chartForegroundStyleScale(range: Gradient(colors: [.white, .green]))
            .chartLegend(.hidden)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 7,
                                             roundLowerBound: false,
                                             roundUpperBound: false)) { _ in
                    AxisGridLine(stroke: .init(lineWidth: 1))
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 20,
                                             roundLowerBound: false,
                                             roundUpperBound: false)) { _ in
                    AxisGridLine(stroke: .init(lineWidth: 1))
                }
            }
            .chartYScale(domain: .automatic(reversed: true))
            .aspectRatio(20.0/7.0, contentMode: .fit)
        }
    }

    private var customisation: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Line Width: \(lineWidth, specifier: "%.1f")")
                Slider(value: $lineWidth, in: 1...20) {
                    Text("Line Width")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("20")
                }
            }

            Picker("Interpolation Method", selection: $interpolationMethod) {
                ForEach(ChartInterpolationMethod.allCases) { Text($0.mode.description).tag($0) }
            }

            ColorPicker("Color Picker", selection: $chartColor)
            Toggle("Show Gradient", isOn: $showGradient.animation())

            if showGradient {
                VStack(alignment: .leading) {
                    Text("Gradiant Opacity Range: \(String(format: "%.1f", gradientRange))")
                    Slider(value: $gradientRange) {
                        Text("Gradiant Opacity Range")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("1")
                    }
                }
            }
        }
    }
}

extension Date {
    // Used for charts where the day of the week is used: visually  M/T/W etc
    // (but we want VoiceOver to read out the full day)
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"

        return formatter.string(from: self)
    }
}
