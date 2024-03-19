//
//  AreaChart.swift
//  Stats
//
//  Created by Deszip on 19.03.2024.
//

import SwiftUI
import Charts

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
    var lines: Int
}

class DataProvider {
    func count() -> Int {
        return 42
    }

    func value(index: Int) -> Int {
        return Int.random(in: 0...10000)
    }
}

struct AreaChart: View {
    private let dataProvider: DataProvider

    @State var data: [CodeValue] = []
    @State private var lineWidth = 2.0
    @State private var interpolationMethod: ChartInterpolationMethod = .cardinal
    @State private var chartColor: Color = .blue
    @State private var showGradient = true
    @State private var gradientRange = 0.5

    init(dataProvider: DataProvider) {
        self.dataProvider = dataProvider
    }

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
        .onAppear {
            for index in 0...dataProvider.count() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {
                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
                        // Load data
                        data.append(CodeValue(day: Date(), lines: dataProvider.value(index: index)))
                    }
                }
            }
        }
    }

    private var chart: some View {
        Chart(data, id: \.day) {
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
