//
//  BudgetMillApp.swift
//  BudgetMill
//
//  Created by 章言韬 on 2025/9/27.
//

import SwiftUI

@main
struct BudgetMillApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - 应用状态管理
class AppState: ObservableObject {
    @Published var isFirstLaunch: Bool = true
    @Published var isAuthenticated: Bool = false
    
    init() {
        // 检查是否是首次启动
        checkFirstLaunch()
        // 检查用户认证状态
        checkAuthenticationStatus()
    }
    
    private func checkFirstLaunch() {
        // 暂时总是显示欢迎页面，用于测试
        isFirstLaunch = true
        // 实际应用中应该使用以下逻辑：
        // isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        // if isFirstLaunch {
        //     UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        // }
    }
    
    private func checkAuthenticationStatus() {
        // 这里可以检查用户的登录状态
        // 暂时设置为未认证状态，需要用户登录
        isAuthenticated = false
    }
    
    func completeAuthentication() {
        isAuthenticated = true
    }
    
    func logout() {
        isAuthenticated = false
    }
}

// MARK: - 主内容视图
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isFirstLaunch {
                WelcomeView()
            } else if appState.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .animation(AppAnimations.standard, value: appState.isAuthenticated)
        .animation(AppAnimations.standard, value: appState.isFirstLaunch)
    }
}
