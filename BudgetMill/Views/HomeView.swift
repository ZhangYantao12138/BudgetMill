//
//  HomeView.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var showAddTransaction = false
    @State private var showBudgetManagement = false
    @State private var refreshTrigger = false
    
    // 模拟数据 - 根据原型图调整
    @State private var monthlyExpense: Double = 2150.0
    @State private var monthlyBudget: Double = 3000.0
    @State private var budgetRemaining: Double = 850.0
    @State private var todayExpense: Double = 125.0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: AppSpacing.lg) {
                        // 头部摘要区域
                        headerSummarySection
                        
                        // 支出分类区域
                        expenseCategoriesSection
                        
                        // 最近交易区域
                        recentTransactionsSection
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                }
                .refreshable {
                    await refreshData()
                }
                
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
        .sheet(isPresented: $showBudgetManagement) {
            BudgetManagementView()
        }
    }
    
    // MARK: - 头部摘要区域
    private var headerSummarySection: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // 日期
                Text("2025年9月27日")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // 本月支出
                        Text("本月支出")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("¥\(String(format: "%.2f", monthlyExpense))")
                            .font(AppFonts.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        // 进度条
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.border)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.primary)
                                    .frame(width: geometry.size.width * budgetProgress, height: 8)
                                    .animation(AppAnimations.standard, value: budgetProgress)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: AppSpacing.sm) {
                        // 预算剩余
                        Text("预算剩余")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("¥\(String(format: "%.2f", budgetRemaining))")
                            .font(AppFonts.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        // 管理目标按钮
                        Button(action: {
                            showBudgetManagement = true
                        }) {
                            Text("管理目标")
                                .font(AppFonts.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 支出分类区域
    private var expenseCategoriesSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                HStack {
                    Text("支出分类")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        // 切换图表类型
                    }) {
                        HStack(spacing: AppSpacing.xs) {
                            Text("环状图")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                    }
                }
                
                // 环形图
                DonutChart(
                    data: [
                        ChartDataPoint(label: "餐饮", value: 1850, color: Color.purple),
                        ChartDataPoint(label: "购物", value: 750.75, color: Color.orange),
                        ChartDataPoint(label: "交通", value: 250, color: Color.blue)
                    ],
                    centerText: "中间数据",
                    centerSubtext: nil,
                    size: 180
                )
                
                // 图例
                VStack(spacing: AppSpacing.sm) {
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                        
                        Text("餐饮")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text("¥1,850.00")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        
                        Text("购物")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text("¥750.75")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text("交通")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text("¥250.00")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
    
    
    // MARK: - 最近交易区域
    private var recentTransactionsSection: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // 筛选器行
                HStack {
                    // 本月筛选
                    Button(action: {
                        // 筛选本月
                    }) {
                        HStack(spacing: AppSpacing.xs) {
                            Text("本月")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                    }
                    
                    // 全部类别筛选
                    Button(action: {
                        // 筛选类别
                    }) {
                        HStack(spacing: AppSpacing.xs) {
                            Text("全部类别")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                    }
                    
                    // 列表视图按钮
                    Button(action: {
                        // 切换列表视图
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.caption)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColors.primary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small))
                    }
                    
                    Spacer()
                    
                    // 添加按钮
                    Button(action: {
                        showAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(AppColors.primary)
                            .clipShape(Circle())
                    }
                }
                
                // 交易列表
                VStack(spacing: AppSpacing.sm) {
                    ForEach(prototypeTransactions) { transaction in
                        TransactionRow(
                            title: transaction.title,
                            amount: transaction.amount,
                            category: transaction.category,
                            icon: transaction.icon,
                            color: transaction.color
                        )
                    }
                    
                    // 更多指示器
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                    }
                    .padding(.top, AppSpacing.xs)
                }
            }
        }
    }
    
    
    // MARK: - 计算属性
    
    private var budgetProgress: Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(monthlyExpense / monthlyBudget, 1.0)
    }
    
    // MARK: - 模拟数据
    private var prototypeTransactions: [PrototypeTransaction] {
        [
            PrototypeTransaction(
                title: "午餐",
                amount: "¥25.00",
                category: "餐饮",
                icon: "fork.knife",
                color: AppColors.primary
            ),
            PrototypeTransaction(
                title: "购买衣服",
                amount: "¥150.00",
                category: "购物",
                icon: "bag.fill",
                color: AppColors.primary
            ),
            PrototypeTransaction(
                title: "公交",
                amount: "¥5.00",
                category: "交通",
                icon: "bus.fill",
                color: AppColors.primary
            )
        ]
    }
    
    // MARK: - 方法
    private func refreshData() async {
        // 模拟数据刷新
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        refreshTrigger.toggle()
    }
}

// MARK: - 原型图数据模型
struct PrototypeTransaction: Identifiable {
    let id = UUID()
    let title: String
    let amount: String
    let category: String
    let icon: String
    let color: Color
}

// MARK: - 交易行组件
struct TransactionRow: View {
    let title: String
    let amount: String
    let category: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // 图标
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            
            // 交易信息
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(category)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // 金额
            Text(amount)
                .font(AppFonts.body)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}


// MARK: - 预览
#Preview {
    HomeView()
}
