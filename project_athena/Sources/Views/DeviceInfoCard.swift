//
//  DeviceInfoCard.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import SwiftUI

struct DeviceInfoCard: View {
    let deviceName: String
    let iosVersion: String
    let model: String
    let chip: String
    let memory: String
    let storage: String
    let uptime: String
    let lastReboot: String

    var body: some View {
        CardContainer(padding: 0) {
            VStack(spacing: 0) {
                // En-tête
                headerView
                    .padding(.horizontal, DesignSystem.spacing20)
                    .padding(.top, DesignSystem.spacing20)
                
                Divider()
                    .background(Color(.separator))
                    .padding(.horizontal, DesignSystem.spacing20)
                    .padding(.vertical, DesignSystem.spacing16)
                
                // Grille d'informations
                infoGridView
                    .padding(.horizontal, DesignSystem.spacing20)
                    .padding(.bottom, DesignSystem.spacing20)
            }
        }
        .padding(.horizontal, 6)
    }
    
    // MARK: - En-tête
    
    private var headerView: some View {
        HStack(spacing: DesignSystem.spacing16) {
            IconContainer(
                icon: "iphone.gen3",
                color: .blue,
                size: DesignSystem.iconSizeLarge
            )
            
            VStack(alignment: .leading, spacing: DesignSystem.spacing4) {
                Text(deviceName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("iOS \(iosVersion)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Grille d'informations
    
    private var infoGridView: some View {
        VStack(spacing: DesignSystem.spacing12) {
            HStack(spacing: DesignSystem.spacing12) {
                InfoCell(icon: "cpu", color: .blue, label: "Puce", value: chip)
                InfoCell(icon: "memorychip", color: .purple, label: "Modèle", value: model)
            }
            
            HStack(spacing: DesignSystem.spacing12) {
                InfoCell(icon: "memorychip.fill", color: .orange, label: "Mémoire", value: memory)
                InfoCell(icon: "internaldrive", color: .pink, label: "Stockage", value: storage)
            }
            
            HStack(spacing: DesignSystem.spacing12) {
                InfoCell(icon: "clock", color: .green, label: "Uptime", value: uptime)
                InfoCell(icon: "arrow.clockwise", color: .cyan, label: "Redémarrage", value: lastReboot)
            }
        }
    }
}

// MARK: - InfoCell Component

struct InfoCell: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.spacing8) {
            HStack(spacing: DesignSystem.spacing8) {
                IconContainer(icon: icon, color: color, size: DesignSystem.iconSizeSmall)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.spacing12)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusSmall, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}
