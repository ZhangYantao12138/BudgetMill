//
//  AppInput.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

// MARK: - 输入框样式枚举
enum AppInputStyle {
    case standard
    case filled
    case outlined
}

// MARK: - 主输入框组件
struct AppInput: View {
    let title: String?
    let placeholder: String
    let style: AppInputStyle
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let isEnabled: Bool
    let errorMessage: String?
    let leadingIcon: String?
    let trailingIcon: String?
    let onTrailingIconTap: (() -> Void)?
    
    @Binding var text: String
    @State private var isFocused = false
    
    init(
        title: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        style: AppInputStyle = .standard,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        isEnabled: Bool = true,
        errorMessage: String? = nil,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        onTrailingIconTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.style = style
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.isEnabled = isEnabled
        self.errorMessage = errorMessage
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.onTrailingIconTap = onTrailingIconTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // 标题
            if let title = title {
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // 输入框
            HStack(spacing: AppSpacing.sm) {
                // 前导图标
                if let leadingIcon = leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.body)
                        .foregroundColor(iconColor)
                }
                
                // 输入内容
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(keyboardType)
                .disabled(!isEnabled)
                .onTapGesture {
                    isFocused = true
                }
                
                // 后置图标
                if let trailingIcon = trailingIcon {
                    Button(action: {
                        onTrailingIconTap?()
                    }) {
                        Image(systemName: trailingIcon)
                            .font(.body)
                            .foregroundColor(iconColor)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            .animation(AppAnimations.quick, value: isFocused)
            .animation(AppAnimations.quick, value: errorMessage)
            
            // 错误信息
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.error)
                    Text(errorMessage)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.error)
                }
            }
        }
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return AppColors.surfaceSecondary
        }
        
        switch style {
        case .standard:
            return AppColors.surface
        case .filled:
            return AppColors.surfaceSecondary
        case .outlined:
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if let _ = errorMessage {
            return AppColors.error
        } else if isFocused {
            return AppColors.primary
        } else {
            return AppColors.border
        }
    }
    
    private var borderWidth: CGFloat {
        if isFocused || errorMessage != nil {
            return 2
        } else {
            return 1
        }
    }
    
    private var iconColor: Color {
        if !isEnabled {
            return AppColors.textTertiary
        } else if let _ = errorMessage {
            return AppColors.error
        } else if isFocused {
            return AppColors.primary
        } else {
            return AppColors.textSecondary
        }
    }
}

// MARK: - 金额输入框
struct AmountInput: View {
    let title: String?
    let placeholder: String
    let isEnabled: Bool
    let errorMessage: String?
    
    @Binding var amount: String
    @State private var isFocused = false
    
    init(
        title: String? = "金额",
        placeholder: String = "0.00",
        amount: Binding<String>,
        isEnabled: Bool = true,
        errorMessage: String? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self._amount = amount
        self.isEnabled = isEnabled
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if let title = title {
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            HStack(spacing: AppSpacing.sm) {
                Text("¥")
                    .font(AppFonts.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
                
                TextField(placeholder, text: $amount)
                    .font(AppFonts.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .keyboardType(.decimalPad)
                    .disabled(!isEnabled)
                    .onTapGesture {
                        isFocused = true
                    }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
            .background(AppColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            .animation(AppAnimations.quick, value: isFocused)
            .animation(AppAnimations.quick, value: errorMessage)
            
            if let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.error)
                    Text(errorMessage)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.error)
                }
            }
        }
    }
    
    private var borderColor: Color {
        if let _ = errorMessage {
            return AppColors.error
        } else if isFocused {
            return AppColors.primary
        } else {
            return AppColors.border
        }
    }
    
    private var borderWidth: CGFloat {
        if isFocused || errorMessage != nil {
            return 2
        } else {
            return 1
        }
    }
}

// MARK: - 搜索框
struct SearchInput: View {
    let placeholder: String
    let onSearchButtonClicked: (() -> Void)?
    
    @Binding var text: String
    @State private var isFocused = false
    
    init(
        placeholder: String = "搜索...",
        text: Binding<String>,
        onSearchButtonClicked: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onSearchButtonClicked = onSearchButtonClicked
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .onSubmit {
                    onSearchButtonClicked?()
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
    }
}

// MARK: - 预览
#Preview {
    VStack(spacing: AppSpacing.lg) {
        // 基础输入框
        AppInput(
            title: "用户名",
            placeholder: "请输入用户名",
            text: .constant(""),
            leadingIcon: "person"
        )
        
        // 密码输入框
        AppInput(
            title: "密码",
            placeholder: "请输入密码",
            text: .constant(""),
            isSecure: true,
            leadingIcon: "lock",
            trailingIcon: "eye"
        )
        
        // 金额输入框
        AmountInput(
            amount: .constant("")
        )
        
        // 搜索框
        SearchInput(
            text: .constant("")
        )
        
        // 错误状态
        AppInput(
            title: "邮箱",
            placeholder: "请输入邮箱",
            text: .constant("invalid-email"),
            keyboardType: .emailAddress,
            errorMessage: "请输入有效的邮箱地址",
            leadingIcon: "envelope"
        )
        
        // 禁用状态
        AppInput(
            title: "禁用输入框",
            placeholder: "此输入框已禁用",
            text: .constant(""),
            isEnabled: false,
            leadingIcon: "lock.fill"
        )
    }
    .padding()
    .background(AppColors.background)
}
