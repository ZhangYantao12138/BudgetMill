//
//  DesignSystem.swift
//  BudgetMill
//
//  Created by 章言韬 on 2024/12/19.
//

import SwiftUI

// MARK: - 颜色主题
struct AppColors {
    // 主题色 - 蓝色系
    static let primary = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
    static let primaryLight = Color(red: 0.4, green: 0.7, blue: 1.0) // #66B3FF
    static let primaryDark = Color(red: 0.0, green: 0.35, blue: 0.8) // #0059CC
    
    // 强调色
    static let accent = Color(red: 0.0, green: 0.8, blue: 0.4) // #00CC66
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.0) // #FF9900
    static let error = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
    
    // 装饰色
    static let success = Color(red: 0.2, green: 0.78, blue: 0.35) // #34C759
    static let info = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
    
    // 中性色
    static let background = Color(red: 0.75, green: 0.84, blue: 1.0) // #BFD7FF
    static let surface = Color.white
    static let surfaceSecondary = Color(red: 0.98, green: 0.98, blue: 0.99) // #FAFAFA
    
    // 文字颜色
    static let textPrimary = Color(red: 0.0, green: 0.0, blue: 0.0) // #000000
    static let textSecondary = Color(red: 0.6, green: 0.6, blue: 0.6) // #999999
    static let textTertiary = Color(red: 0.8, green: 0.8, blue: 0.8) // #CCCCCC
    
    // 边框颜色
    static let border = Color(red: 0.9, green: 0.9, blue: 0.9) // #E5E5E5
    static let borderLight = Color(red: 0.95, green: 0.95, blue: 0.95) // #F2F2F2
}

// MARK: - 字体系统
struct AppFonts {
    // 标题字体
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)
    
    // 正文字体
    static let headline = Font.headline.weight(.semibold)
    static let body = Font.body
    static let bodyBold = Font.body.weight(.semibold)
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2
}

// MARK: - 间距系统
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - 圆角系统
struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
    static let xxlarge: CGFloat = 24
}

// MARK: - 阴影系统
struct AppShadows {
    static let small = Shadow(
        color: Color.black.opacity(0.1),
        radius: 2,
        x: 0,
        y: 1
    )
    
    static let medium = Shadow(
        color: Color.black.opacity(0.15),
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let large = Shadow(
        color: Color.black.opacity(0.2),
        radius: 8,
        x: 0,
        y: 4
    )
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - 动画系统
struct AppAnimations {
    static let quick = Animation.easeInOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.3, dampingFraction: 0.6)
}

// MARK: - 扩展Color以支持阴影
extension View {
    func appShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
