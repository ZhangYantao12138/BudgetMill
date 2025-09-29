//
//  Transaction.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import Foundation
import SwiftUI

// MARK: - 交易类型
enum TransactionType: String, CaseIterable, Codable {
    case expense = "expense"
    case income = "income"
    
    var displayName: String {
        switch self {
        case .expense:
            return "支出"
        case .income:
            return "收入"
        }
    }
    
    var color: Color {
        switch self {
        case .expense:
            return AppColors.error
        case .income:
            return AppColors.success
        }
    }
    
    var icon: String {
        switch self {
        case .expense:
            return "minus.circle.fill"
        case .income:
            return "plus.circle.fill"
        }
    }
}

// MARK: - 交易模型
struct Transaction: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var type: TransactionType
    var category: String
    var categoryIcon: String
    var categoryColor: String
    var date: Date
    var note: String?
    var isRecurring: Bool
    var recurringInterval: RecurringInterval?
    
    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        type: TransactionType,
        category: String,
        categoryIcon: String,
        categoryColor: String,
        date: Date = Date(),
        note: String? = nil,
        isRecurring: Bool = false,
        recurringInterval: RecurringInterval? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.type = type
        self.category = category
        self.categoryIcon = categoryIcon
        self.categoryColor = categoryColor
        self.date = date
        self.note = note
        self.isRecurring = isRecurring
        self.recurringInterval = recurringInterval
    }
    
    // 格式化金额显示
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }
    
    // 带符号的金额显示
    var signedAmount: String {
        let sign = type == .expense ? "-" : "+"
        return "\(sign)\(formattedAmount)"
    }
    
    // 格式化日期显示
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 简短日期显示
    var shortDate: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.timeStyle = .short
            return "今天 \(formatter.string(from: date))"
        } else if Calendar.current.isDateInYesterday(date) {
            formatter.timeStyle = .short
            return "昨天 \(formatter.string(from: date))"
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
    
    // 分类颜色
    var categoryColorValue: Color {
        return Color(hex: categoryColor) ?? AppColors.primary
    }
}

// MARK: - 重复间隔
enum RecurringInterval: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "每日"
        case .weekly:
            return "每周"
        case .monthly:
            return "每月"
        case .yearly:
            return "每年"
        }
    }
}

// MARK: - 分类模型
struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var type: TransactionType
    var budget: Double?
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String,
        type: TransactionType,
        budget: Double? = nil,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.type = type
        self.budget = budget
        self.isDefault = isDefault
    }
    
    var colorValue: Color {
        return Color(hex: color) ?? AppColors.primary
    }
    
    var formattedBudget: String? {
        guard let budget = budget else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: budget))
    }
}

// MARK: - 预设分类
extension Category {
    static let defaultExpenseCategories: [Category] = [
        Category(name: "餐饮", icon: "fork.knife", color: "#FF9500", type: .expense, isDefault: true),
        Category(name: "交通", icon: "car.fill", color: "#007AFF", type: .expense, isDefault: true),
        Category(name: "购物", icon: "bag.fill", color: "#34C759", type: .expense, isDefault: true),
        Category(name: "娱乐", icon: "gamecontroller.fill", color: "#AF52DE", type: .expense, isDefault: true),
        Category(name: "医疗", icon: "cross.fill", color: "#FF3B30", type: .expense, isDefault: true),
        Category(name: "教育", icon: "book.fill", color: "#5AC8FA", type: .expense, isDefault: true),
        Category(name: "住房", icon: "house.fill", color: "#FFCC00", type: .expense, isDefault: true),
        Category(name: "其他", icon: "ellipsis.circle.fill", color: "#8E8E93", type: .expense, isDefault: true)
    ]
    
    static let defaultIncomeCategories: [Category] = [
        Category(name: "工资", icon: "banknote.fill", color: "#34C759", type: .income, isDefault: true),
        Category(name: "奖金", icon: "gift.fill", color: "#FF9500", type: .income, isDefault: true),
        Category(name: "投资", icon: "chart.line.uptrend.xyaxis", color: "#007AFF", type: .income, isDefault: true),
        Category(name: "兼职", icon: "briefcase.fill", color: "#AF52DE", type: .income, isDefault: true),
        Category(name: "其他", icon: "ellipsis.circle.fill", color: "#8E8E93", type: .income, isDefault: true)
    ]
}

// MARK: - 预算模型
struct Budget: Identifiable, Codable {
    let id: UUID
    var categoryId: UUID
    var amount: Double
    var period: BudgetPeriod
    var startDate: Date
    var endDate: Date
    var spent: Double
    
    init(
        id: UUID = UUID(),
        categoryId: UUID,
        amount: Double,
        period: BudgetPeriod,
        startDate: Date,
        endDate: Date,
        spent: Double = 0
    ) {
        self.id = id
        self.categoryId = categoryId
        self.amount = amount
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.spent = spent
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }
    
    var formattedSpent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: spent)) ?? "¥0.00"
    }
    
    var progress: Double {
        guard amount > 0 else { return 0 }
        return min(spent / amount, 1.0)
    }
    
    var isOverBudget: Bool {
        return spent > amount
    }
    
    var remaining: Double {
        return max(amount - spent, 0)
    }
    
    var formattedRemaining: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        return formatter.string(from: NSNumber(value: remaining)) ?? "¥0.00"
    }
}

// MARK: - 预算周期
enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .weekly:
            return "每周"
        case .monthly:
            return "每月"
        case .yearly:
            return "每年"
        }
    }
}

// MARK: - Color扩展
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
