# Arion

Arion est une plateforme de suivi de financements adossés à des actifs (Asset-Backed Financing) dédiée aux PME et aux financeurs. Elle permet de visualiser la valorisation des actifs mis en garantie, de suivre les engagements financiers et d’assurer un ratio de couverture à jour grâce à des synchronisations régulières ou des imports de données.

## 🚀 Objectifs

- Offrir aux financeurs une vue consolidée des financements et de la couverture des actifs.
- Permettre aux entreprises financées d’importer ou de synchroniser leurs données facilement.
- Automatiser les calculs de ratio de couverture pour chaque financement.
- Faciliter l’onboarding des courtiers, financeurs et entreprises.

## ✨ Fonctionnalités principales

- 🔄 Import CSV ou synchronisation automatique des données d’actifs
- 📈 Suivi des valorisations par date
- 📊 Calcul du ratio de couverture des financements
- 👥 Gestion des rôles : entreprise, financeur, courtier
- 🏢 Récupération des informations d’entreprise via l’API Papers (via SIRET)
- 💳 Intégration Stripe pour la gestion des abonnements
- 🔐 Authentification sécurisée avec Devise
- 📬 Invitations par email et système d’onboarding simplifié

## 🛠️ Technologies utilisées

- **Ruby on Rails** 7
- **PostgreSQL**
- **StimulusJS**, **Turbo**
- **TailwindCSS**
- **Devise**, **Pundit**
- **Sidekiq** (pour les traitements asynchrones)
- **Stripe API**
- **Papers API**
- **Synth API**

## 📦 Installation

```bash
git clone https://github.com/ton-utilisateur/arion.git
cd arion
bundle install
yarn install
rails db:migrate

