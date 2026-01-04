# 💰 Expense Tracker

A Flutter-based expense tracking application for managing expenses, budgets, savings, and spending insights. Developed using Claude Code to learn more about the process of mobile application development.

⚠️ Currently available for Android devices only. Web/IOS version only available for my personal use 🙂 

---

## ✨ Features

### 📊 Expense Management
- **Add & Track Expenses**: Record expenses with name, category, amount, description, and date
- **Recurring Expenses**: Set expenses to automatically recur every month (e.g., subscriptions, rent)
- **Monthly View**: Navigate between months to see historical spending
- **Category Organization**: Organize expenses into predefined categories:


### 💼 Budget Planning
- **Monthly Budgets**: Set separate budgets for each month
- **Category Budgets**: Create budgets for specific spending categories
- **Recurring Budgets**: Automatically apply budgets to future months
- **Budget Tracking**: Visual indicators show spending progress (green/orange/red)
- **Over-Budget Alerts**: Clear warnings when spending exceeds budget

### 💵 Income Tracking
- **Monthly Income**: Set different income amounts for each month
- **Budget Overview**: See remaining budget after expenses
- **Income vs Spending**: Compare income against total monthly spending

### 💎 Savings Tracking
- **Track Savings**: Record savings as expenses in the "Savings" category
- **Cumulative Growth**: View total savings over time
- **Monthly Trends**: See how much you saved each month
- **Visual Charts**: Line graphs showing savings growth

### 📈 Data Visualization
- **Pie Charts**: Spending breakdown by category
- **Bar Charts**: Weekly spending trends within a month
- **Line Charts**: Monthly spending trends over 6 months
- **Savings Graphs**: Track savings accumulation over time

### 🔄 Features
- **Month Navigation**: Easily switch between months with prev/next buttons
- **Auto-Recurring**: Recurring expenses and budgets automatically copy to new months
- **Edit & Delete**: Full CRUD operations on all data
- **Persistent Storage**: Data saved locally (SQLite on Android, Firestore on Web)

---

## 📱 Installation

### Android APK
1. Download `expensetracker.apk` from the [GitHub releases](https://github.com/dillonchong01/ExpenseTracker_Android/releases/)
2. Enable "Install from Unknown Sources" in your Android settings
3. Open the APK file and follow installation prompts
4. Launch the app and start tracking your expenses!

---

## 🏗️ Technology Stack
- **Framework**: Flutter
- **Language**: Dart
- **Local Database (Android)**: SQLite (via sqflite)