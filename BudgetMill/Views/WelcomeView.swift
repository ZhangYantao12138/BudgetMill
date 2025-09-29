//
//  WelcomeView.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showUserAgreement = false
    @State private var isAgreedToTerms = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var contentOffset: CGFloat = 50
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [
                    AppColors.primary.opacity(0.1),
                    AppColors.primaryLight.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                // Logo 区域
                VStack(spacing: AppSpacing.lg) {
                    // App Logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primary, AppColors.primaryLight]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                        
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                    }
                    
                    // App 名称
                    VStack(spacing: AppSpacing.sm) {
                        Text("BudgetMill")
                            .font(AppFonts.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                            .opacity(logoOpacity)
                        
                        Text("最省心的记账助手！")
                            .font(AppFonts.title3)
                            .foregroundColor(AppColors.primary)
                            .opacity(logoOpacity)
                    }
                }
                .offset(y: contentOffset)
                
                Spacer()
                
                // 底部内容
                VStack(spacing: AppSpacing.lg) {
                    // 欢迎语
                    VStack(spacing: AppSpacing.sm) {
                        Text("欢迎使用 BudgetMill")
                            .font(AppFonts.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("让记账变得简单高效，助你轻松管理财务")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                    .opacity(logoOpacity)
                    
                    // 用户协议确认
                    VStack(spacing: AppSpacing.md) {
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
                                    showUserAgreement = true
                                }) {
                                    Text("《用户协议》")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.primary)
                                        .underline()
                                }
                                
                                Text("和")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Button(action: {
                                    showUserAgreement = true
                                }) {
                                    Text("《隐私政策》")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.primary)
                                        .underline()
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // 开始使用按钮
                        Button(action: {
                            if isAgreedToTerms {
                                // 完成首次启动，跳转到认证页面
                                withAnimation(AppAnimations.standard) {
                                    appState.isFirstLaunch = false
                                }
                            }
                        }) {
                            Text("开始使用")
                                .font(AppFonts.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: isAgreedToTerms ? 
                                            [AppColors.primary, AppColors.primaryLight] : 
                                            [AppColors.textTertiary, AppColors.textTertiary]
                                        ),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
                                .appShadow(AppShadows.medium)
                        }
                        .disabled(!isAgreedToTerms)
                        .padding(.horizontal, AppSpacing.lg)
                        .animation(AppAnimations.quick, value: isAgreedToTerms)
                    }
                    .opacity(logoOpacity)
                }
                .offset(y: contentOffset)
                
                Spacer()
            }
        }
        .onAppear {
            // 启动动画
            withAnimation(AppAnimations.spring.delay(0.3)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(AppAnimations.standard.delay(0.5)) {
                contentOffset = 0
            }
        }
        .sheet(isPresented: $showUserAgreement) {
            UserAgreementView()
        }
    }
}

// MARK: - 用户协议弹窗
struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 分段控制器
                Picker("协议类型", selection: $selectedTab) {
                    Text("用户协议").tag(0)
                    Text("隐私政策").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                
                // 协议内容
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        if selectedTab == 0 {
                            userAgreementContent
                        } else {
                            privacyPolicyContent
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.lg)
                }
            }
            .navigationTitle("法律条款")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var userAgreementContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("用户协议")
                .font(AppFonts.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                agreementSection(
                    title: "1. 服务说明",
                    content: "BudgetMill 是一款个人财务管理应用，为用户提供记账、预算管理、数据分析等服务。"
                )
                
                agreementSection(
                    title: "2. 用户责任",
                    content: "用户应确保提供信息的真实性，合理使用应用功能，不得进行违法或损害他人利益的行为。"
                )
                
                agreementSection(
                    title: "3. 数据安全",
                    content: "我们承诺保护用户数据安全，采用行业标准的安全措施保护您的隐私信息。"
                )
                
                agreementSection(
                    title: "4. 服务变更",
                    content: "我们保留随时修改或终止服务的权利，重大变更将提前通知用户。"
                )
                
                agreementSection(
                    title: "5. 免责声明",
                    content: "用户因使用本应用而产生的任何损失，我们不承担赔偿责任。"
                )
            }
            
            Text("最后更新时间：2024年12月19日")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, AppSpacing.lg)
        }
    }
    
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("隐私政策")
                .font(AppFonts.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                agreementSection(
                    title: "1. 信息收集",
                    content: "我们仅收集必要的用户信息，包括账户信息、财务数据等，用于提供更好的服务体验。"
                )
                
                agreementSection(
                    title: "2. 信息使用",
                    content: "收集的信息仅用于应用功能实现、服务改进和用户支持，不会用于其他商业目的。"
                )
                
                agreementSection(
                    title: "3. 信息保护",
                    content: "我们采用加密技术保护用户数据，建立完善的安全防护体系，防止数据泄露。"
                )
                
                agreementSection(
                    title: "4. 信息共享",
                    content: "未经用户同意，我们不会与第三方共享您的个人信息，除非法律要求或保护用户安全需要。"
                )
                
                agreementSection(
                    title: "5. 用户权利",
                    content: "用户有权查看、修改、删除个人信息，如有疑问可随时联系我们。"
                )
            }
            
            Text("最后更新时间：2024年12月19日")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, AppSpacing.lg)
        }
    }
    
    private func agreementSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text(content)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 预览
#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
