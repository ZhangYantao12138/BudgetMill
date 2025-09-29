//
//  MainTabView.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("首页")
                }
                .tag(0)
            
            // 账单
            TransactionListView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "doc.text.fill" : "doc.text")
                    Text("账单")
                }
                .tag(1)
            
            // 图表
            StatisticsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                    Text("图表")
                }
                .tag(2)
            
            // 我的
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("我的")
                }
                .tag(3)
        }
        .accentColor(AppColors.primary)
    }
}

// MARK: - 交易列表页面
struct TransactionListView: View {
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var showFilterSheet = false
    
    enum TransactionFilter: String, CaseIterable {
        case all = "全部"
        case expense = "支出"
        case income = "收入"
        case today = "今天"
        case week = "本周"
        case month = "本月"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 搜索栏
                    VStack(spacing: AppSpacing.md) {
                        SearchInput(
                            placeholder: "搜索交易记录...",
                            text: $searchText
                        )
                        
                        // 筛选器
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.sm) {
                                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                                    FilterChip(
                                        title: filter.rawValue,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        selectedFilter = filter
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.md)
                        }
                    }
                    .padding(.top, AppSpacing.sm)
                    
                    // 交易列表
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(filteredTransactions) { transaction in
                                TransactionCard(
                                    title: transaction.title,
                                    amount: transaction.signedAmount,
                                    category: transaction.category,
                                    date: transaction.shortDate,
                                    icon: transaction.categoryIcon,
                                    color: transaction.categoryColorValue,
                                    isIncome: transaction.type == .income
                                )
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.md)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(selectedFilter: $selectedFilter)
        }
    }
    
    private var filteredTransactions: [Transaction] {
        let transactions = mockTransactions
        
        var filtered = transactions
        
        // 按类型筛选
        switch selectedFilter {
        case .expense:
            filtered = filtered.filter { $0.type == .expense }
        case .income:
            filtered = filtered.filter { $0.type == .income }
        case .today:
            filtered = filtered.filter { Calendar.current.isDateInToday($0.date) }
        case .week:
            filtered = filtered.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
        case .month:
            filtered = filtered.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        case .all:
            break
        }
        
        // 按搜索文本筛选
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.title.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.localizedCaseInsensitiveContains(searchText) ||
                (transaction.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return filtered
    }
    
    private var mockTransactions: [Transaction] {
        [
            Transaction(
                title: "午餐",
                amount: 45.0,
                type: .expense,
                category: "餐饮",
                categoryIcon: "fork.knife",
                categoryColor: AppColors.warning.toHex(),
                date: Date()
            ),
            Transaction(
                title: "地铁",
                amount: 6.0,
                type: .expense,
                category: "交通",
                categoryIcon: "car.fill",
                categoryColor: AppColors.primary.toHex(),
                date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
            ),
            Transaction(
                title: "工资",
                amount: 8000.0,
                type: .income,
                category: "工资",
                categoryIcon: "banknote.fill",
                categoryColor: AppColors.success.toHex(),
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            ),
            Transaction(
                title: "咖啡",
                amount: 28.0,
                type: .expense,
                category: "餐饮",
                categoryIcon: "cup.and.saucer.fill",
                categoryColor: AppColors.warning.toHex(),
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
            ),
            Transaction(
                title: "购物",
                amount: 299.0,
                type: .expense,
                category: "购物",
                categoryIcon: "bag.fill",
                categoryColor: AppColors.accent.toHex(),
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            )
        ]
    }
}

// MARK: - 筛选芯片
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(isSelected ? AppColors.primary : AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.large)
                        .stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
        }
        .animation(AppAnimations.quick, value: isSelected)
    }
}

// MARK: - 筛选页面
struct FilterSheetView: View {
    @Binding var selectedFilter: TransactionListView.TransactionFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.lg) {
                ForEach(TransactionListView.TransactionFilter.allCases, id: \.self) { filter in
                    FilterOptionRow(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                        dismiss()
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("筛选")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 筛选选项行
struct FilterOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.body)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(isSelected ? AppColors.primary.opacity(0.1) : AppColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
        .animation(AppAnimations.quick, value: isSelected)
    }
}

// MARK: - 统计页面
struct StatisticsView: View {
    @State private var selectedPeriod: StatisticsPeriod = .month
    
    enum StatisticsPeriod: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case year = "本年"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 周期选择
                        periodSelector
                        
                        // 支出统计
                        expenseStatistics
                        
                        // 收入统计
                        incomeStatistics
                        
                        // 分类统计
                        categoryStatistics
                        
                        // 趋势图表
                        trendCharts
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var periodSelector: some View {
        AppCard(style: .elevated) {
            Picker("统计周期", selection: $selectedPeriod) {
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private var expenseStatistics: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("支出统计")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: AppSpacing.lg) {
                    StatCard(
                        title: "总支出",
                        value: "¥2,580",
                        subtitle: "比上月减少 12%",
                        icon: "creditcard",
                        color: AppColors.error,
                        trend: .down,
                        trendValue: "12%"
                    )
                    
                    StatCard(
                        title: "平均每日",
                        value: "¥86",
                        subtitle: "比上月减少 8%",
                        icon: "calendar",
                        color: AppColors.warning,
                        trend: .down,
                        trendValue: "8%"
                    )
                }
            }
        }
    }
    
    private var incomeStatistics: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("收入统计")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: AppSpacing.lg) {
                    StatCard(
                        title: "总收入",
                        value: "¥8,000",
                        subtitle: "比上月增加 5%",
                        icon: "banknote",
                        color: AppColors.success,
                        trend: .up,
                        trendValue: "5%"
                    )
                    
                    StatCard(
                        title: "净收入",
                        value: "¥5,420",
                        subtitle: "比上月增加 15%",
                        icon: "chart.line.uptrend.xyaxis",
                        color: AppColors.primary,
                        trend: .up,
                        trendValue: "15%"
                    )
                }
            }
        }
    }
    
    private var categoryStatistics: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("分类统计")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
            }
        }
    }
    
    private var trendCharts: some View {
        VStack(spacing: AppSpacing.lg) {
            AppCard(style: .elevated) {
                LineChart(
                    data: generateTrendData(),
                    title: "支出趋势",
                    color: AppColors.error
                )
            }
            
            AppCard(style: .elevated) {
                BarChart(
                    data: [
                        ChartDataPoint(label: "1月", value: 1200, color: AppColors.primary),
                        ChartDataPoint(label: "2月", value: 1500, color: AppColors.primary),
                        ChartDataPoint(label: "3月", value: 1800, color: AppColors.primary),
                        ChartDataPoint(label: "4月", value: 1600, color: AppColors.primary)
                    ],
                    title: "月度对比"
                )
            }
        }
    }
    
    private func generateTrendData() -> [TimeSeriesDataPoint] {
        var data: [TimeSeriesDataPoint] = []
        for i in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let value = Double.random(in: 50...200)
            data.append(TimeSeriesDataPoint(date: date, value: value))
        }
        return data.reversed()
    }
}

// MARK: - 个人中心页面
struct ProfileView: View {
    @State private var isICloudSyncEnabled = false
    @State private var isBiometricUnlockEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 用户信息
                        userInfoSection
                        
                        // 账号安全
                        accountSecuritySection
                        
                        // 功能设置
                        functionSettingsSection
                        
                        // 关于
                        aboutSection
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var userInfoSection: some View {
        AppCard(style: .elevated) {
            HStack(spacing: AppSpacing.md) {
                // 头像
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(AppColors.primary)
                }
                
                // 用户信息
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text("天才的小小猪")
                            .font(AppFonts.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Button(action: {
                            // 编辑昵称
                        }) {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    
                    Text("UID: 123456789")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // 会员状态
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                    
                    Text("普通会员")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
    
    private var accountSecuritySection: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("账号安全")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                VStack(spacing: AppSpacing.sm) {
                    SecurityRow(
                        title: "修改密码",
                        hasArrow: true
                    ) {
                        // 修改密码
                    }
                    
                    Divider()
                    
                    SecurityRow(
                        title: "绑定邮箱",
                        subtitle: "example@email.com",
                        hasEditIcon: true,
                        hasArrow: true
                    ) {
                        // 绑定邮箱
                    }
                    
                    Divider()
                    
                    SecurityRow(
                        title: "绑定手机号",
                        hasArrow: true
                    ) {
                        // 绑定手机号
                    }
                    
                    Divider()
                    
                    SecurityRow(
                        title: "绑定微信",
                        hasArrow: true
                    ) {
                        // 绑定微信
                    }
                    
                    Divider()
                    
                    SecurityRow(
                        title: "绑定 Apple ID",
                        hasArrow: true
                    ) {
                        // 绑定Apple ID
                    }
                }
            }
        }
    }
    
    private var functionSettingsSection: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("功能设置")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                VStack(spacing: AppSpacing.sm) {
                    SettingRow(
                        title: "iCloud 同步",
                        hasSwitch: true,
                        isSwitchOn: $isICloudSyncEnabled
                    )
                    
                    Divider()
                    
                    SettingRow(
                        title: "数据备份与找回",
                        hasArrow: true
                    ) {
                        // 数据备份与找回
                    }
                    
                    Divider()
                    
                    SettingRow(
                        title: "默认货币",
                        subtitle: "CNY",
                        hasArrow: true
                    ) {
                        // 默认货币设置
                    }
                    
                    Divider()
                    
                    SettingRow(
                        title: "语言",
                        subtitle: "简体中文",
                        hasArrow: true
                    ) {
                        // 语言设置
                    }
                    
                    Divider()
                    
                    SettingRow(
                        title: "Face ID / Touch ID 解锁",
                        hasSwitch: true,
                        isSwitchOn: $isBiometricUnlockEnabled
                    )
                }
            }
        }
    }
    
    private var aboutSection: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("关于")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                VStack(spacing: AppSpacing.sm) {
                    AboutRow(
                        title: "App 版本信息",
                        subtitle: "v1.0.0",
                        hasArrow: true
                    ) {
                        // 版本信息
                    }
                    
                    Divider()
                    
                    AboutRow(
                        title: "帮助文档",
                        hasArrow: true
                    ) {
                        // 帮助文档
                    }
                    
                    Divider()
                    
                    AboutRow(
                        title: "用户协议",
                        hasArrow: true
                    ) {
                        // 用户协议
                    }
                    
                    Divider()
                    
                    AboutRow(
                        title: "联系我们",
                        hasArrow: true
                    ) {
                        // 联系我们
                    }
                }
            }
        }
    }
}

// MARK: - 安全设置行
struct SecurityRow: View {
    let title: String
    let subtitle: String?
    let hasEditIcon: Bool
    let hasArrow: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String? = nil, hasEditIcon: Bool = false, hasArrow: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.hasEditIcon = hasEditIcon
        self.hasArrow = hasArrow
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let subtitle = subtitle {
                    HStack(spacing: AppSpacing.xs) {
                        Text(subtitle)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        if hasEditIcon {
                            Image(systemName: "pencil")
                                .font(.caption2)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                
                if hasArrow {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(.vertical, AppSpacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 功能设置行
struct SettingRow: View {
    let title: String
    let subtitle: String?
    let hasSwitch: Bool
    let hasArrow: Bool
    let isSwitchOn: Binding<Bool>?
    let action: (() -> Void)?
    
    init(title: String, subtitle: String? = nil, hasSwitch: Bool = false, hasArrow: Bool = false, isSwitchOn: Binding<Bool>? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.hasSwitch = hasSwitch
        self.hasArrow = hasArrow
        self.isSwitchOn = isSwitchOn
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if hasSwitch, let isSwitchOn = isSwitchOn {
                Toggle("", isOn: isSwitchOn)
                    .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
            }
            
            if hasArrow {
                Button(action: action ?? {}) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

// MARK: - 关于行
struct AboutRow: View {
    let title: String
    let subtitle: String?
    let hasArrow: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String? = nil, hasArrow: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.hasArrow = hasArrow
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if hasArrow {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding(.vertical, AppSpacing.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预览
#Preview {
    MainTabView()
}
