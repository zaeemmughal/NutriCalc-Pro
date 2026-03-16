# 💪 NutriCalc Pro — Smart Health & Diet Calculator
 
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Health](https://img.shields.io/badge/Health-App-red?style=for-the-badge)
 
> Calculate your BMI, BMR, and IBW — then get a personalized diet plan based on your AMR.
 
---
 
## 📌 About The Project
 
**NutriCalc Pro** is a smart health and nutrition calculator built with Flutter. It goes beyond a basic BMI calculator — users get a full health snapshot including their Body Mass Index, Basal Metabolic Rate, and Ideal Body Weight. Based on their Active Metabolic Rate (AMR), the app then recommends personalized daily diet proportions for proteins, carbs, and fats. Patient data is persistently managed using a **Singleton database pattern**, allowing multiple patient profiles to be saved and retrieved across sessions.
 
---
 
## ✨ Features
 
- ⚖️ **BMI Calculator** — Body Mass Index with health category (Underweight / Normal / Overweight / Obese)
- 🔥 **BMR Calculator** — Basal Metabolic Rate using Mifflin-St Jeor formula
- 📏 **IBW Calculator** — Ideal Body Weight based on height and gender
- 🥗 **Diet Proportion Recommender** — Personalized macronutrient breakdown based on AMR values
- 🗄️ **Patient Database** — Save and manage multiple patient profiles using Singleton pattern
- 📊 Clean visual results with health insights
- 📱 Smooth and responsive Flutter UI
 
---
 
## 🛠️ Technologies Used
 
| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile UI framework |
| Dart | Programming language |
| Singleton Design Pattern | Single-instance patient data management |
| Health Formulas | BMI, BMR, IBW, AMR calculations |
| Flutter Widgets | Visual results and UI components |
 
---
 
## 📐 Formulas Used
 
| Metric | Formula |
|---|---|
| BMI | Weight (kg) / Height² (m) |
| BMR (Male) | 10×weight + 6.25×height − 5×age + 5 |
| BMR (Female) | 10×weight + 6.25×height − 5×age − 161 |
| IBW (Male) | 50 + 2.3 × (height in inches − 60) |
| IBW (Female) | 45.5 + 2.3 × (height in inches − 60) |
| AMR | BMR × Activity Factor |
 
---
 
## 🗄️ Singleton Database Pattern
 
Patient data is managed through a **Singleton class** (`PatientDatabase`) ensuring only one instance of the database exists throughout the app lifecycle. This allows patient profiles and their health records to be saved, updated, and accessed from anywhere in the app without redundant data or conflicts.
 
```dart
// Single instance accessible app-wide
PatientDatabase db = PatientDatabase();
db.addPatient(patient);
db.getAllPatients();
```
 
---
 
## 🚀 Installation & Setup
 
### Prerequisites
- Flutter SDK installed ([flutter.dev](https://flutter.dev))
- Dart SDK (comes with Flutter)
- Android Studio or VS Code with Flutter extension
- Android/iOS emulator or physical device
 
### Steps
 
```bash
# 1. Clone the repository
git clone https://github.com/zaeemmughal/nutricaclc-pro.git
 
# 2. Navigate to the project folder
cd nutricaclc-pro
 
# 3. Install dependencies
flutter pub get
 
# 4. Run the app
flutter run
```
 
> 💡 Make sure your emulator is running or a device is connected before `flutter run`.
 
---
 
## 📁 Project Structure
 
```
nutricaclc-pro/
├── lib/
│   ├── main.dart               # App entry point
│   ├── custom_splash.dart      # Splash screen
│   ├── home_page.dart          # Main dashboard
│   ├── patient_database.dart   # Singleton database for patient data
│   └── patient_page.dart       # Patient profile & health results
├── pubspec.yaml
└── README.md
```
 
---
 
## 👨‍💻 Developer
 
**Muhammad Zaeem**
BS Software Engineering — University of Sargodha
GitHub: [zaeemmughal](https://github.com/zaeemmughal)
 
---
 
## 📜 License
 
This project is open source and available under the [MIT License](LICENSE).
