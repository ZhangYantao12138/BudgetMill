//
//  AppCharts.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI
import Charts

// MARK: - 图表数据模型
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
}

struct TimeSeriesDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - 环形图组件
struct DonutChart: View {
    let data: [ChartDataPoint]
    let centerText: String
    let centerSubtext: String?
    let size: CGFloat
    
    init(
        data: [ChartDataPoint],
        centerText: String,
        centerSubtext: String? = nil,
        size: CGFloat = 200
    ) {
        self.data = data
        self.centerText = centerText
        self.centerSubtext = centerSubtext
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // 图表
            Chart(data) { item in
                SectorMark(
                    angle: .value("Value", item.value),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
            }
            .frame(width: size, height: size)
            
            // 中心文字
            VStack(spacing: 4) {
                Text(centerText)
                    .font(AppFonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                if let centerSubtext = centerSubtext {
                    Text(centerSubtext)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - 柱状图组件
struct BarChart: View {
    let data: [ChartDataPoint]
    let title: String?
    let showValues: Bool
    
    init(
        data: [ChartDataPoint],
        title: String? = nil,
        showValues: Bool = true
    ) {
        self.data = data
        self.title = title
        self.showValues = showValues
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if let title = title {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Chart(data) { item in
                BarMark(
                    x: .value("Category", item.label),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(AppFonts.caption)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(AppColors.border)
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("¥\(Int(doubleValue))")
                                .font(AppFonts.caption)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 折线图组件
struct LineChart: View {
    let data: [TimeSeriesDataPoint]
    let title: String?
    let color: Color
    let showPoints: Bool
    
    init(
        data: [TimeSeriesDataPoint],
        title: String? = nil,
        color: Color = AppColors.primary,
        showPoints: Bool = true
    ) {
        self.data = data
        self.title = title
        self.color = color
        self.showPoints = showPoints
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if let title = title {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Chart(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                if showPoints {
                    PointMark(
                        x: .value("Date", item.date),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(color)
                    .symbolSize(50)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, style: .date)
                                .font(AppFonts.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(AppColors.border)
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("¥\(Int(doubleValue))")
                                .font(AppFonts.caption)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 预算对比图
struct BudgetComparisonChart: View {
    let data: [BudgetComparisonData]
    let title: String?
    
    struct BudgetComparisonData: Identifiable {
        let id = UUID()
        let category: String
        let spent: Double
        let budget: Double
        let color: Color
    }
    
    init(
        data: [BudgetComparisonData],
        title: String? = nil
    ) {
        self.data = data
        self.title = title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if let title = title {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(data) { item in
                    BudgetComparisonRow(
                        category: item.category,
                        spent: item.spent,
                        budget: item.budget,
                        color: item.color
                    )
                }
            }
        }
    }
}

// MARK: - 预算对比行
struct BudgetComparisonRow: View {
    let category: String
    let spent: Double
    let budget: Double
    let color: Color
    
    private var progress: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1.0)
    }
    
    private var isOverBudget: Bool {
        return spent > budget
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack {
                Text(category)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("¥\(Int(spent))/¥\(Int(budget))")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.border)
                        .frame(height: 6)
                    
                    // 进度
                    RoundedRectangle(cornerRadius: 2)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(AppAnimations.standard, value: progress)
                }
            }
            .frame(height: 6)
        }
    }
    
    private var progressColor: Color {
        if isOverBudget {
            return AppColors.error
        } else if progress > 0.8 {
            return AppColors.warning
        } else {
            return color
        }
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
        VStack(spacing: AppSpacing.xl) {
            // 环形图
            DonutChart(
                data: [
                    ChartDataPoint(label: "餐饮", value: 800, color: AppColors.warning),
                    ChartDataPoint(label: "交通", value: 300, color: AppColors.primary),
                    ChartDataPoint(label: "购物", value: 500, color: AppColors.accent),
                    ChartDataPoint(label: "其他", value: 200, color: AppColors.textSecondary)
                ],
                centerText: "¥1,800",
                centerSubtext: "本月支出"
            )
            
            // 柱状图
            BarChart(
                data: [
                    ChartDataPoint(label: "1月", value: 1200, color: AppColors.primary),
                    ChartDataPoint(label: "2月", value: 1500, color: AppColors.primary),
                    ChartDataPoint(label: "3月", value: 1800, color: AppColors.primary),
                    ChartDataPoint(label: "4月", value: 1600, color: AppColors.primary)
                ],
                title: "月度支出趋势"
            )
            
            // 折线图
            LineChart(
                data: [
                    TimeSeriesDataPoint(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, value: 100),
                    TimeSeriesDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, value: 150),
                    TimeSeriesDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, value: 120),
                    TimeSeriesDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, value: 200),
                    TimeSeriesDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, value: 180),
                    TimeSeriesDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, value: 220),
                    TimeSeriesDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, value: 190)
                ],
                title: "最近7天支出"
            )
            
            // 预算对比图
            BudgetComparisonChart(
                data: [
                    BudgetComparisonChart.BudgetComparisonData(category: "餐饮", spent: 1200, budget: 1500, color: AppColors.warning),
                    BudgetComparisonChart.BudgetComparisonData(category: "交通", spent: 400, budget: 500, color: AppColors.primary),
                    BudgetComparisonChart.BudgetComparisonData(category: "购物", spent: 800, budget: 600, color: AppColors.accent)
                ],
                title: "预算执行情况"
            )
        }
        .padding()
    }
    .background(AppColors.background)
}
