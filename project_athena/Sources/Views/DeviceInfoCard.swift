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
        VStack(spacing: 0) {
            // En-tête de l'appareil
            headerView
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            Divider()
                .background(Color(.separator))
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            
            // Grille d'informations
            infoGridView
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 6)
    }
    
    // MARK: - En-tête
    
    private var headerView: some View {
        HStack(spacing: 15) {
            // Icône de l'appareil
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.2),
                                Color.blue.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: "iphone.gen3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 36)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            // Nom et version
            VStack(alignment: .leading, spacing: 4) {
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
        VStack(spacing: 12) {
            // Ligne 1
            HStack(spacing: 12) {
                InfoItem(
                    icon: "cpu",
                    iconColor: .blue,
                    label: "Puce",
                    value: chip
                )
                
                InfoItem(
                    icon: "memorychip",
                    iconColor: .purple,
                    label: "Modèle",
                    value: model
                )
            }
            
            // Ligne 2
            HStack(spacing: 12) {
                InfoItem(
                    icon: "memorychip.fill",
                    iconColor: .orange,
                    label: "Mémoire",
                    value: memory
                )
                
                InfoItem(
                    icon: "internaldrive",
                    iconColor: .pink,
                    label: "Stockage",
                    value: storage
                )
            }
            
            // Ligne 3
            HStack(spacing: 12) {
                InfoItem(
                    icon: "clock",
                    iconColor: .green,
                    label: "Temps de fonctionnement",
                    value: uptime
                )
                
                InfoItem(
                    icon: "arrow.clockwise",
                    iconColor: .cyan,
                    label: "Dernier redémarrage",
                    value: lastReboot
                )
            }
        }
    }
}

// MARK: - Composant InfoItem

struct InfoItem: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icône avec fond
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Valeur
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}
