//
//  BudgetManagementView.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

struct BudgetManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var showAddBudget = false
    @State private var searchText = ""
    
    // 模拟预算数据
    @State private var budgets: [Budget] = [
        Budget(
            categoryId: UUID(),
            amount: 1000,
            period: .monthly,
            startDate: Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date(),
            endDate: Calendar.current.dateInterval(of: .month, for: Date())?.end ?? Date(),
            spent: 800
        ),
        Budget(
            categoryId: UUID(),
            amount: 500,
            period: .monthly,
            startDate: Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date(),
            endDate: Calendar.current.dateInterval(of: .month, for: Date())?.end ?? Date(),
            spent: 300
        ),
        Budget(
            categoryId: UUID(),
            amount: 600,
            period: .monthly,
            startDate: Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date(),
            endDate: Calendar.current.dateInterval(of: .month, for: Date())?.end ?? Date(),
            spent: 650
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部统计
                    headerSection
                    
                    // 搜索栏
                    searchSection
                    
                    // 预算列表
                    budgetListSection
                }
            }
            .navigationTitle("预算管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddBudget = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddBudget) {
            AddBudgetView()
        }
    }
    
    // MARK: - 顶部统计区域
    private var headerSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                // 周期选择
                HStack {
                    Text("预算周期")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Picker("周期", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 200)
                }
                
                Divider()
                
                // 统计信息
                HStack(spacing: AppSpacing.lg) {
                    StatItem(
                        title: "总预算",
                        value: "¥\(Int(totalBudget))",
                        color: AppColors.primary
                    )
                    
                    StatItem(
                        title: "已支出",
                        value: "¥\(Int(totalSpent))",
                        color: AppColors.warning
                    )
                    
                    StatItem(
                        title: "剩余",
                        value: "¥\(Int(totalRemaining))",
                        color: totalRemaining >= 0 ? AppColors.success : AppColors.error
                    )
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
    }
    
    // MARK: - 搜索区域
    private var searchSection: some View {
        VStack(spacing: AppSpacing.md) {
            SearchInput(
                placeholder: "搜索预算分类...",
                text: $searchText
            )
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(.top, AppSpacing.md)
    }
    
    // MARK: - 预算列表
    private var budgetListSection: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(filteredBudgets) { budget in
                    BudgetCard(
                        budget: budget,
                        category: getCategory(for: budget.categoryId)
                    )
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
        }
    }
    
    // MARK: - 计算属性
    private var totalBudget: Double {
        budgets.reduce(0) { $0 + $1.amount }
    }
    
    private var totalSpent: Double {
        budgets.reduce(0) { $0 + $1.spent }
    }
    
    private var totalRemaining: Double {
        totalBudget - totalSpent
    }
    
    private var filteredBudgets: [Budget] {
        if searchText.isEmpty {
            return budgets
        } else {
            return budgets.filter { budget in
                let category = getCategory(for: budget.categoryId)
                return category.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - 方法
    private func getCategory(for categoryId: UUID) -> Category {
        // 模拟获取分类信息
        let categories = Category.defaultExpenseCategories
        return categories.first { $0.id == categoryId } ?? categories[0]
    }
}

// MARK: - 统计项
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFonts.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 预算卡片
struct BudgetCard: View {
    let budget: Budget
    let category: Category
    @State private var showEditSheet = false
    
    var body: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                // 头部信息
                HStack {
                    HStack(spacing: AppSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(category.colorValue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: category.icon)
                                .font(.title3)
                                .foregroundColor(category.colorValue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.name)
                                .font(AppFonts.body)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(budget.period.displayName)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showEditSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // 金额信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("预算")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(budget.formattedAmount)
                            .font(AppFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("已支出")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(budget.formattedSpent)
                            .font(AppFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(budget.isOverBudget ? AppColors.error : AppColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("剩余")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(budget.formattedRemaining)
                            .font(AppFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(budget.remaining >= 0 ? AppColors.success : AppColors.error)
                    }
                }
                
                // 进度条
                VStack(spacing: AppSpacing.xs) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.border)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor)
                                .frame(width: geometry.size.width * budget.progress, height: 8)
                                .animation(AppAnimations.standard, value: budget.progress)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text(progressText)
                            .font(AppFonts.caption)
                            .foregroundColor(progressColor)
                        
                        Spacer()
                        
                        Text("\(Int(budget.progress * 100))%")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditBudgetView(budget: budget, category: category)
        }
    }
    
    private var progressColor: Color {
        if budget.isOverBudget {
            return AppColors.error
        } else if budget.progress > 0.8 {
            return AppColors.warning
        } else {
            return category.colorValue
        }
    }
    
    private var progressText: String {
        if budget.isOverBudget {
            return "已超支"
        } else if budget.progress > 0.8 {
            return "即将超支"
        } else {
            return "正常"
        }
    }
}

// MARK: - 添加预算页面
struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: Category?
    @State private var amount = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    @State private var showCategoryPicker = false
    
    private let categories = Category.defaultExpenseCategories
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 分类选择
                        categorySection
                        
                        // 金额输入
                        amountSection
                        
                        // 周期选择
                        periodSection
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationTitle("添加预算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveBudget()
                    }
                    .foregroundColor(AppColors.primary)
                    .disabled(!isFormValid)
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(
                categories: categories,
                selectedCategory: $selectedCategory
            )
        }
    }
    
    private var categorySection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("分类")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    showCategoryPicker = true
                }) {
                    HStack {
                        if let selectedCategory = selectedCategory {
                            HStack(spacing: AppSpacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(selectedCategory.colorValue.opacity(0.1))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: selectedCategory.icon)
                                        .font(.body)
                                        .foregroundColor(selectedCategory.colorValue)
                                }
                                
                                Text(selectedCategory.name)
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                            }
                        } else {
                            HStack {
                                Text("选择分类")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }
            }
        }
    }
    
    private var amountSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("预算金额")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                AmountInput(
                    amount: $amount
                )
            }
        }
    }
    
    private var periodSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("预算周期")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("周期", selection: $selectedPeriod) {
                    ForEach(BudgetPeriod.allCases, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    private var isFormValid: Bool {
        return selectedCategory != nil && !amount.isEmpty && Double(amount) != nil
    }
    
    private func saveBudget() {
        // 保存预算逻辑
        dismiss()
    }
}

// MARK: - 编辑预算页面
struct EditBudgetView: View {
    let budget: Budget
    let category: Category
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 分类信息（只读）
                        categoryInfoSection
                        
                        // 金额编辑
                        amountSection
                        
                        // 周期编辑
                        periodSection
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationTitle("编辑预算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveBudget()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear {
            amount = String(Int(budget.amount))
            selectedPeriod = budget.period
        }
    }
    
    private var categoryInfoSection: some View {
        AppCard(style: .elevated) {
            HStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(category.colorValue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundColor(category.colorValue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(AppFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("分类信息")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var amountSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("预算金额")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                AmountInput(
                    amount: $amount
                )
            }
        }
    }
    
    private var periodSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("预算周期")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Picker("周期", selection: $selectedPeriod) {
                    ForEach(BudgetPeriod.allCases, id: \.self) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    private func saveBudget() {
        // 保存预算逻辑
        dismiss()
    }
}

// MARK: - 预览
#Preview {
    BudgetManagementView()
}
