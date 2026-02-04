# 🏛️ Project Athena

**Dashboard de monitoring système pour iPhone** — Une application native SwiftUI élégante qui affiche les performances de votre appareil en temps réel.

---

## ✨ Fonctionnalités

- 📊 **Métriques système** — CPU, RAM, stockage et batterie en un coup d'œil
- 📡 **Monitoring réseau** — Graphique temps réel du débit download/upload
- 📱 **Widgets iOS** — Petits, moyens et grands widgets pour l'écran d'accueil
- 🌙 **Mode sombre** — Interface optimisée pour le dark mode
- 🔄 **Actualisation automatique** — Données rafraîchies toutes les 2 secondes

---

## 📱 Aperçu

L'application affiche un tableau de bord complet avec :

| Métrique | Description |
|----------|-------------|
| **Device Info** | Nom, modèle, puce, mémoire et uptime |
| **CPU** | Utilisation du processeur en % |
| **RAM** | Mémoire utilisée / totale |
| **Stockage** | Espace disque utilisé |
| **Batterie** | Niveau et état de charge |
| **Réseau** | Courbe de débit avec légende |

---

## 🛠️ Installation

### Prérequis

- Xcode 15+
- iOS 17+
- macOS Sonoma+

### Étapes

1. **Cloner le projet**
   ```bash
   git clone https://github.com/votre-username/project_athena.git
   ```

2. **Ouvrir dans Xcode**
   ```bash
   open project_athena.xcodeproj
   ```

3. **Sélectionner votre iPhone** et lancer le build (`Cmd + R`)

---

## 📁 Structure du projet

```
project_athena/
├── project_athena/                 # App principale
│   ├── Sources/
│   │   ├── Models/                 # ViewModels et modèles de données
│   │   ├── Views/                  # Composants SwiftUI
│   │   ├── Utils/                  # Helpers et utilitaires
│   │   ├── ContentView.swift       # Vue principale
│   │   └── Constants.swift         # Design System
│   └── Assets.xcassets/
│
└── project_athena_widget/          # Extension Widget iOS
    ├── project_athena_widget.swift # Widgets (small, medium, large)
    └── Assets.xcassets/
```

---

## 🎨 Design System

L'app utilise un système de design cohérent :

- **Couleurs** — Palette système iOS avec accents bleu/vert/orange
- **Espacement** — Grille de 4/8/12/16/20/24 pts
- **Composants** — Cards réutilisables avec ombres et bordures subtiles
- **Typographie** — SF Rounded pour les métriques

---

## 👤 Auteur

**Thomas Boisaubert**

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.
