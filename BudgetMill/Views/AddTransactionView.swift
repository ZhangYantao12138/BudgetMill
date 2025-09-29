//
//  AddTransactionView.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var title = ""
    @State private var note = ""
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: Category?
    @State private var selectedDate = Date()
    @State private var isRecurring = false
    @State private var selectedRecurringInterval: RecurringInterval = .monthly
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    @State private var showRecurringPicker = false
    @State private var isSaving = false
    
    private let categories: [Category]
    
    init() {
        self.categories = Category.defaultExpenseCategories + Category.defaultIncomeCategories
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // 金额输入
                        amountSection
                        
                        // 交易类型选择
                        typeSection
                        
                        // 分类选择
                        categorySection
                        
                        // 标题和备注
                        detailsSection
                        
                        // 日期选择
                        dateSection
                        
                        // 重复设置
                        recurringSection
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.top, AppSpacing.sm)
                }
            }
            .navigationTitle("添加交易")
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
                        saveTransaction()
                    }
                    .foregroundColor(AppColors.primary)
                    .disabled(!isFormValid || isSaving)
                }
            }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(
                categories: categories.filter { $0.type == selectedType },
                selectedCategory: $selectedCategory
            )
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerView(selectedDate: $selectedDate)
        }
        .sheet(isPresented: $showRecurringPicker) {
            RecurringPickerView(
                isRecurring: $isRecurring,
                selectedInterval: $selectedRecurringInterval
            )
        }
    }
    
    // MARK: - 金额输入区域
    private var amountSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("金额")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                AmountInput(
                    amount: $amount
                )
            }
        }
    }
    
    // MARK: - 交易类型选择
    private var typeSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("类型")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: AppSpacing.md) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        TypeSelectionButton(
                            type: type,
                            isSelected: selectedType == type
                        ) {
                            withAnimation(AppAnimations.quick) {
                                selectedType = type
                                selectedCategory = nil // 重置分类选择
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 分类选择
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
    
    // MARK: - 详情输入
    private var detailsSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("详情")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: AppSpacing.md) {
                    AppInput(
                        title: "标题",
                        placeholder: "请输入交易标题",
                        text: $title,
                        leadingIcon: "textformat"
                    )
                    
                    AppInput(
                        title: "备注",
                        placeholder: "添加备注（可选）",
                        text: $note,
                        leadingIcon: "note.text"
                    )
                }
            }
        }
    }
    
    // MARK: - 日期选择
    private var dateSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("日期")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    showDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.body)
                            .foregroundColor(AppColors.primary)
                        
                        Text(selectedDate, style: .date)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
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
    
    // MARK: - 重复设置
    private var recurringSection: some View {
        AppCard(style: .elevated) {
            VStack(spacing: AppSpacing.md) {
                Text("重复设置")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {
                    showRecurringPicker = true
                }) {
                    HStack {
                        Image(systemName: "repeat")
                            .font(.body)
                            .foregroundColor(AppColors.primary)
                        
                        Text(isRecurring ? "\(selectedRecurringInterval.displayName)重复" : "不重复")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
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
    
    // MARK: - 计算属性
    private var isFormValid: Bool {
        return !amount.isEmpty && 
               Double(amount) != nil && 
               !title.isEmpty && 
               selectedCategory != nil
    }
    
    // MARK: - 方法
    private func saveTransaction() {
        isSaving = true
        
        // 模拟保存延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - 类型选择按钮
struct TypeSelectionButton: View {
    let type: TransactionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: type.icon)
                    .font(.body)
                    .foregroundColor(isSelected ? .white : type.color)
                
                Text(type.displayName)
                    .font(AppFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(isSelected ? type.color : AppColors.surfaceSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(isSelected ? type.color : AppColors.border, lineWidth: isSelected ? 0 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
        .animation(AppAnimations.quick, value: isSelected)
    }
}

// MARK: - 分类选择器
struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: AppSpacing.md) {
                    ForEach(categories) { category in
                        CategorySelectionButton(
                            category: category,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            selectedCategory = category
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("选择分类")
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

// MARK: - 分类选择按钮
struct CategorySelectionButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.colorValue : category.colorValue.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? .white : category.colorValue)
                }
                
                Text(category.name)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, AppSpacing.sm)
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AppAnimations.quick, value: isSelected)
    }
}

// MARK: - 日期选择器
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "选择日期",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("选择日期")
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

// MARK: - 重复设置选择器
struct RecurringPickerView: View {
    @Binding var isRecurring: Bool
    @Binding var selectedInterval: RecurringInterval
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.lg) {
                // 是否重复开关
                HStack {
                    Text("重复交易")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $isRecurring)
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                
                if isRecurring {
                    // 重复间隔选择
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("重复间隔")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal, AppSpacing.lg)
                        
                        VStack(spacing: AppSpacing.sm) {
                            ForEach(RecurringInterval.allCases, id: \.self) { interval in
                                RecurringIntervalButton(
                                    interval: interval,
                                    isSelected: selectedInterval == interval
                                ) {
                                    selectedInterval = interval
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("重复设置")
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

// MARK: - 重复间隔按钮
struct RecurringIntervalButton: View {
    let interval: RecurringInterval
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(interval.displayName)
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

// MARK: - 预览
#Preview {
    AddTransactionView()
}
