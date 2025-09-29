//
//  AppCard.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

// MARK: - 卡片样式枚举
enum AppCardStyle {
    case standard
    case elevated
    case outlined
    case filled
}

// MARK: - 主卡片组件
struct AppCard<Content: View>: View {
    let style: AppCardStyle
    let padding: CGFloat
    let cornerRadius: CGFloat
    let content: Content
    
    init(
        style: AppCardStyle = .standard,
        padding: CGFloat = AppSpacing.md,
        cornerRadius: CGFloat = AppCornerRadius.large,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .appShadow(shadow)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .standard, .elevated:
            return AppColors.surface
        case .outlined:
            return AppColors.surface
        case .filled:
            return AppColors.surfaceSecondary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .standard, .elevated, .filled:
            return Color.clear
        case .outlined:
            return AppColors.border
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return 1
        default:
            return 0
        }
    }
    
    private var shadow: Shadow {
        switch style {
        case .standard:
            return AppShadows.small
        case .elevated:
            return AppShadows.medium
        case .outlined, .filled:
            return Shadow(color: .clear, radius: 0, x: 0, y: 0)
        }
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let color: Color
    let trend: TrendDirection?
    let trendValue: String?
    
    enum TrendDirection {
        case up, down, neutral
    }
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        color: Color = AppColors.primary,
        trend: TrendDirection? = nil,
        trendValue: String? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.trend = trend
        self.trendValue = trendValue
    }
    
    var body: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    if let trend = trend, let trendValue = trendValue {
                        HStack(spacing: 2) {
                            Image(systemName: trendIcon)
                                .font(.caption)
                                .foregroundColor(trendColor)
                            Text(trendValue)
                                .font(AppFonts.caption)
                                .foregroundColor(trendColor)
                        }
                    }
                }
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(AppFonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private var trendIcon: String {
        switch trend {
        case .up:
            return "arrow.up"
        case .down:
            return "arrow.down"
        case .neutral:
            return "minus"
        case .none:
            return ""
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up:
            return AppColors.success
        case .down:
            return AppColors.error
        case .neutral:
            return AppColors.textSecondary
        case .none:
            return AppColors.textSecondary
        }
    }
}

// MARK: - 交易记录卡片
struct TransactionCard: View {
    let title: String
    let amount: String
    let category: String
    let date: String
    let icon: String
    let color: Color
    let isIncome: Bool
    
    init(
        title: String,
        amount: String,
        category: String,
        date: String,
        icon: String,
        color: Color = AppColors.primary,
        isIncome: Bool = false
    ) {
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.icon = icon
        self.color = color
        self.isIncome = isIncome
    }
    
    var body: some View {
        AppCard(style: .standard) {
            HStack(spacing: AppSpacing.md) {
                // 图标
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                // 内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(category)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // 金额和日期
                VStack(alignment: .trailing, spacing: 4) {
                    Text(amount)
                        .font(AppFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(isIncome ? AppColors.success : AppColors.textPrimary)
                    
                    Text(date)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
}

// MARK: - 预算进度卡片
struct BudgetProgressCard: View {
    let category: String
    let spent: Double
    let budget: Double
    let icon: String
    let color: Color
    
    private var progress: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1.0)
    }
    
    private var isOverBudget: Bool {
        return spent > budget
    }
    
    var body: some View {
        AppCard(style: .standard) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                    
                    Text(category)
                        .font(AppFonts.body)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("¥\(Int(spent))/¥\(Int(budget))")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.border)
                            .frame(height: 8)
                        
                        // 进度
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor)
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(AppAnimations.standard, value: progress)
                    }
                }
                .frame(height: 8)
                
                // 状态文本
                HStack {
                    Text(progressText)
                        .font(AppFonts.caption)
                        .foregroundColor(progressColor)
                    
                    Spacer()
                    
                    if isOverBudget {
                        Text("超支 ¥\(Int(spent - budget))")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.error)
                    }
                }
            }
        }
    }
    
    private var progressColor: Color {
        if isOverBudget {
            return AppColors.error
        } else if progress > 0.8 {
            return AppColors.warning
        } else {
            return AppColors.success
        }
    }
    
    private var progressText: String {
        if isOverBudget {
            return "已超支"
        } else if progress > 0.8 {
            return "即将超支"
        } else {
            return "正常"
        }
    }
}

// MARK: - 预览
#Preview {
    ScrollView {
        VStack(spacing: AppSpacing.lg) {
            // 基础卡片
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("基础卡片")
                        .font(AppFonts.headline)
                    Text("这是一个基础的卡片组件")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            // 统计卡片
            StatCard(
                title: "本月支出",
                value: "¥2,580",
                subtitle: "比上月减少 12%",
                icon: "creditcard",
                color: AppColors.primary,
                trend: .down,
                trendValue: "12%"
            )
            
            // 交易记录卡片
            TransactionCard(
                title: "午餐",
                amount: "-¥45",
                category: "餐饮",
                date: "今天 12:30",
                icon: "fork.knife",
                color: AppColors.warning
            )
            
            // 预算进度卡片
            BudgetProgressCard(
                category: "餐饮",
                spent: 1200,
                budget: 1500,
                icon: "fork.knife",
                color: AppColors.warning
            )
        }
        .padding()
    }
    .background(AppColors.background)
}
