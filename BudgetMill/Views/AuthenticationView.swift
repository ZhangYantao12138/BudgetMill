//
//  AuthenticationView.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedAuthMethod: AuthMethod? = nil
    @State private var showInputForm = false
    @State private var isAgreedToTerms = false
    
    enum AuthMethod: String, CaseIterable {
        case apple = "使用 AppleID 继续"
        case email = "使用电子邮箱 继续"
        case wechat = "使用微信继续"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo 和标题
                    VStack(spacing: AppSpacing.lg) {
                        // Logo
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.primary, AppColors.primaryLight]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        // 标题
                        Text("登录XX记账")
                            .font(AppFonts.title1)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    // 登录方式选择
                    VStack(spacing: AppSpacing.md) {
                        // Apple ID 登录
                        AuthMethodButton(
                            title: "使用 AppleID 继续",
                            icon: "applelogo",
                            iconColor: .black,
                            backgroundColor: .white,
                            borderColor: AppColors.border
                        ) {
                            selectedAuthMethod = .apple
                            handleAuthMethodSelection(.apple)
                        }
                        
                        // 分割线
                        Text("Or")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.vertical, AppSpacing.sm)
                        
                        // 邮箱登录
                        AuthMethodButton(
                            title: "使用电子邮箱 继续",
                            icon: "envelope.fill",
                            iconColor: .white,
                            backgroundColor: Color(red: 0.26, green: 0.52, blue: 0.96), // Google Blue
                            borderColor: .clear
                        ) {
                            selectedAuthMethod = .email
                            showInputForm = true
                        }
                        
                        // 微信登录
                        AuthMethodButton(
                            title: "使用微信继续",
                            icon: "message.fill",
                            iconColor: .white,
                            backgroundColor: Color(red: 0.07, green: 0.69, blue: 0.33), // WeChat Green
                            borderColor: .clear
                        ) {
                            selectedAuthMethod = .wechat
                            handleAuthMethodSelection(.wechat)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    Spacer()
                    
                    // 用户协议
                    VStack(spacing: AppSpacing.sm) {
                        HStack(spacing: AppSpacing.sm) {
                            Button(action: {
                                isAgreedToTerms.toggle()
                            }) {
                                Image(systemName: isAgreedToTerms ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundColor(isAgreedToTerms ? AppColors.primary : AppColors.textSecondary)
                            }
                            
                            HStack(spacing: 0) {
                                Text("我已阅读并同意")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Button(action: {
                                    // 显示用户协议
                                }) {
                                    Text("用户协议")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.primary)
                                        .underline()
                                }
                                
                                Text("和")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Button(action: {
                                    // 显示隐私政策
                                }) {
                                    Text("隐私政策")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.primary)
                                        .underline()
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showInputForm) {
            if let method = selectedAuthMethod {
                AuthInputFormView(authMethod: method, isAgreedToTerms: $isAgreedToTerms)
                    .environmentObject(appState)
            }
        }
    }
    
    // MARK: - 方法
    private func handleAuthMethodSelection(_ method: AuthMethod) {
        switch method {
        case .apple:
            // 直接使用 Apple ID 登录
            print("Apple ID 登录")
            withAnimation(AppAnimations.standard) {
                appState.completeAuthentication()
            }
        case .wechat:
            // 直接使用微信登录
            print("微信登录")
            withAnimation(AppAnimations.standard) {
                appState.completeAuthentication()
            }
        case .email:
            // 邮箱需要输入表单
            break
        }
    }
}

// MARK: - 认证方式按钮
struct AuthMethodButton: View {
    let title: String
    let icon: String
    let iconColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(AppFonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(iconColor)
                
                Spacer()
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
            .appShadow(AppShadows.small)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 认证输入表单
struct AuthInputFormView: View {
    let authMethod: AuthenticationView.AuthMethod
    @Binding var isAgreedToTerms: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // 头部
                        VStack(spacing: AppSpacing.lg) {
                            Text(isLoginMode ? "邮箱登录" : "邮箱注册")
                                .font(AppFonts.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(isLoginMode ? "使用邮箱登录您的账户" : "创建新的邮箱账户")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, AppSpacing.xl)
                        
                        // 登录/注册切换
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(AppAnimations.quick) {
                                    isLoginMode = true
                                    clearForm()
                                }
                            }) {
                                Text("登录")
                                    .font(AppFonts.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isLoginMode ? AppColors.primary : AppColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .fill(isLoginMode ? AppColors.primary.opacity(0.1) : Color.clear)
                                    )
                            }
                            
                            Button(action: {
                                withAnimation(AppAnimations.quick) {
                                    isLoginMode = false
                                    clearForm()
                                }
                            }) {
                                Text("注册")
                                    .font(AppFonts.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(!isLoginMode ? AppColors.primary : AppColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                            .fill(!isLoginMode ? AppColors.primary.opacity(0.1) : Color.clear)
                                    )
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                                .fill(AppColors.surfaceSecondary)
                                .appShadow(AppShadows.small)
                        )
                        
                        // 表单
                        VStack(spacing: AppSpacing.lg) {
                            AuthInputField(
                                title: "邮箱",
                                placeholder: "请输入邮箱地址",
                                text: $email,
                                keyboardType: .emailAddress,
                                icon: "envelope"
                            )
                            
                            AuthInputField(
                                title: "密码",
                                placeholder: "请输入密码",
                                text: $password,
                                isSecure: true,
                                icon: "lock"
                            )
                            
                            if !isLoginMode {
                                AuthInputField(
                                    title: "确认密码",
                                    placeholder: "请再次输入密码",
                                    text: $confirmPassword,
                                    isSecure: true,
                                    icon: "lock.fill"
                                )
                            }
                            
                            // 登录/注册按钮
                            Button(action: {
                                if isLoginMode {
                                    login()
                                } else {
                                    register()
                                }
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    }
                                    
                                    Text(isLoginMode ? "登录" : "注册")
                                        .font(AppFonts.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.primary, AppColors.primaryLight]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
                                .appShadow(AppShadows.medium)
                            }
                            .disabled(isLoading || !isFormValid)
                            .opacity(isFormValid ? 1.0 : 0.6)
                            
                            // 忘记密码
                            if isLoginMode {
                                Button(action: {
                                    // 忘记密码
                                }) {
                                    Text("忘记密码？")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .navigationBarHidden(true)
        }
        .overlay(
            // 关闭按钮
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(AppColors.surface)
                            .clipShape(Circle())
                            .appShadow(AppShadows.small)
                    }
                    .padding(.top, AppSpacing.md)
                    .padding(.leading, AppSpacing.md)
                    
                    Spacer()
                }
                Spacer()
            }
        )
    }
    
    // MARK: - 表单验证
    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && password == confirmPassword
        }
    }
    
    // MARK: - 方法
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    private func login() {
        isLoading = true
        
        // 模拟登录请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            // 登录成功，跳转到主界面
            dismiss()
            withAnimation(AppAnimations.standard) {
                appState.completeAuthentication()
            }
        }
    }
    
    private func register() {
        isLoading = true
        
        // 模拟注册请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            // 注册成功，跳转到主界面
            dismiss()
            withAnimation(AppAnimations.standard) {
                appState.completeAuthentication()
            }
        }
    }
}

// MARK: - 认证输入框
struct AuthInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFonts.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(AppFonts.body)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .font(AppFonts.body)
                        .keyboardType(keyboardType)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
        }
    }
}

// MARK: - 预览
#Preview {
    AuthenticationView()
        .environmentObject(AppState())
}
