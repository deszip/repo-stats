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

protocol DataProvider {
    func count() -> Int64
    func value(index: Int64) -> Int64?
}

class RandomDataProvider: DataProvider {
    func count() -> Int64 {
        return 42
    }

    func value(index: Int64) -> Int64? {
        return Int64.random(in: 0...10000)
    }
}

//class StoreDataProvider: DataProvider {
////    @FetchRequest (sortDescriptors: [NSSortDescriptor(keyPath: \STSample.date, ascending: true)], animation: . default)
////    var samples: FetchedResults<STSample>
//
//    @ObservedObject var repo: STRepo
//    
//    func count() -> Int64 {
//        return Int64(repo.samples.coun1t)
//    }
//
//    func value(index: Int64) -> Int64? {
//        if index < repo.samples.count {
//            return repo.samples?.allObjects.enumerated()[Int(index)].lineCount
//        }
//
//        return nil
//    }
//}


struct AreaChart: View {
    @ObservedObject var repo: STRepo

//    private let dataProvider: DataProvider
//    @FetchRequest (sortDescriptors: [NSSortDescriptor(keyPath: \STSample.date, ascending: true)], animation: . default)
//    var samples: FetchedResults<STSample>

    @State var data: [CodeValue] = []
    @State private var lineWidth = 2.0
    @State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .blue
    @State private var showGradient = true
    @State private var gradientRange = 0.5

//    init(dataProvider: DataProvider) {
//        self.dataProvider = dataProvider
//    }

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
        .navigationTitle("Title")
//        .onAppear {
//            let delay = 1.0
//            for index in 0...dataProvider.count() {
//                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * delay) {
//                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
//                        // Load data
//                        if let value = dataProvider.value(index: index) {
//                            data.append(CodeValue(day: Date(), lines: value))
//                        }
//                    }
//                }
//            }
//        }
    }

    private var chart: some View {
//        Chart(data, id: \.day) {
        Chart((repo.samples?.allObjects as? [STSample] ?? [])
            .map { CodeValue(day: $0.date ?? Date(), lines: $0.lineCount) }
            .sorted(by: { lhs, rhs in return lhs.day < rhs.day }),
              id: \.day) {
            AreaMark(
                x: .value("Date", $0.day),
                y: .value("LOC", $0.lines)
            )
            .foregroundStyle(gradient)
            .interpolationMethod(interpolationMethod.mode)

            LineMark(
                x: .value("Date", $0.day),
                y: .value("LOC", $0.lines)
            )
            .lineStyle(StrokeStyle(lineWidth: lineWidth))
            .interpolationMethod(interpolationMethod.mode)
            .foregroundStyle(chartColor)
        }
        .chartYAxis(.automatic)
        .chartXAxis(.automatic)
        .frame(height: 300)
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
