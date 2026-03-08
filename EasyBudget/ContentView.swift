//
//  ContentView.swift
//  iBudget
//
//  Created by Kiko on 2023-03-02.
//

import SwiftUI

enum LanguageCurrency: String, CaseIterable, Identifiable {
    case swedish = "Svenska Kr"
    case english = "English USD"
    case norwegian = "Norwegian NOK"
    case euro = "Euro EUR"

    var id: String { self.rawValue }

    var flag: String {
        switch self {
        case .swedish: return "🇸🇪"
        case .english: return "🇺🇸"
        case .norwegian: return "🇳🇴"
        case .euro: return "🇪🇺"
        }
    }

    var displayName: String {
        return "\(flag) \(rawValue)"
    }

    var languageCode: String {
        switch self {
        case .swedish: return "sv"
        case .english: return "en"
        case .norwegian: return "nb"
        case .euro: return "en"
        }
    }

    var currencySymbol: String {
        switch self {
        case .swedish: return "kr"
        case .english: return "$"
        case .norwegian: return "NOK"
        case .euro: return "€"
        }
    }

    var currencyCode: String {
        switch self {
        case .swedish: return "SEK"
        case .english: return "USD"
        case .norwegian: return "NOK"
        case .euro: return "EUR"
        }
    }
}

struct ExpenseCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol name or emoji
}

let predefinedCategories: [ExpenseCategory] = [
    ExpenseCategory(name: "Rent", icon: "house.fill"),
    ExpenseCategory(name: "Insurance", icon: "shield.fill"),
    ExpenseCategory(name: "Fitness", icon: "figure.strengthtraining.traditional"),
    ExpenseCategory(name: "Electricity", icon: "bolt.fill"),
    ExpenseCategory(name: "Food", icon: "cart.fill"),
    ExpenseCategory(name: "Car", icon: "car.fill"),
    ExpenseCategory(name: "Phone", icon: "iphone.gen3"),
    ExpenseCategory(name: "Internet", icon: "wifi"),
    ExpenseCategory(name: "Transportation", icon: "bus.fill"),
    ExpenseCategory(name: "Healthcare", icon: "cross.case.fill"),
    ExpenseCategory(name: "Entertainment", icon: "film.fill"),
    ExpenseCategory(name: "Shopping", icon: "bag.fill"),
    ExpenseCategory(name: "Education", icon: "book.fill"),
    ExpenseCategory(name: "Travel", icon: "airplane"),
    ExpenseCategory(name: "Pets", icon: "pawprint.fill"),
    ExpenseCategory(name: "Gifts", icon: "gift.fill"),
    ExpenseCategory(name: "Subscriptions", icon: "creditcard.fill"),
    ExpenseCategory(name: "Savings", icon: "banknote.fill"),
    ExpenseCategory(name: "Other", icon: "ellipsis.circle.fill")
]

struct ContentView: View {
    // MARK: - State Variables
    @State private var expenses = UserDefaults.standard.object(forKey: "listan") as? [String:Int] ?? [String:Int]()
    @State private var income: Float = UserDefaults.standard.float(forKey: "inkomst")
    @State private var showMainView = true
    @State private var showSecondView = false
    @State private var showEditView = false
    @State private var showAddView = false
    @State private var inputKey = ""
    @State private var inputValue = ""
    @State private var animationEffect = false
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var selectedLanguageCurrency: LanguageCurrency = {
        if let savedRawValue = UserDefaults.standard.string(forKey: "languageCurrency"),
           let saved = LanguageCurrency(rawValue: savedRawValue) {
            return saved
        }
        return .english
    }()

    // MARK: - Computed Properties
    private var totalExpenses: Int {
        expenses.values.reduce(0, +)
    }

    private var savings: Int {
        Int(income) - totalExpenses
    }

    private var yearlySavings: Int {
        savings * 12
    }

    var body: some View {
        Group {
            if showMainView {
                WelcomeView(
                    income: $income,
                    showMainView: $showMainView,
                    showSecondView: $showSecondView,
                    userName: $userName,
                    selectedLanguageCurrency: $selectedLanguageCurrency
                )
            } else if showSecondView {
                BudgetView(
                    income: $income,
                    expenses: expenses,
                    showEditView: $showEditView,
                    showAddView: $showAddView,
                    inputKey: $inputKey,
                    inputValue: $inputValue,
                    onDelete: deleteExpense,
                    onSave: saveExpense,
                    userName: $userName,
                    selectedLanguageCurrency: $selectedLanguageCurrency
                )
            }
        }
    }

    // MARK: - Helper Methods
    private func saveExpense() {
        if let value = Int(inputValue) {
            expenses[inputKey] = value
            UserDefaults.standard.set(expenses, forKey: "listan")
            inputKey = ""
            inputValue = ""
            showAddView = false
        }
    }

    private func deleteExpense(at offsets: IndexSet) {
        if let index = offsets.first {
            let item = expenses.sorted { $0.1 > $1.1 }[index]
            expenses.removeValue(forKey: item.key)
            UserDefaults.standard.set(expenses, forKey: "listan")
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @Binding var income: Float
    @Binding var showMainView: Bool
    @Binding var showSecondView: Bool
    @Binding var userName: String
    @Binding var selectedLanguageCurrency: LanguageCurrency
    @State private var animationEffect = false
    @State private var pulseScale: CGFloat = 1.0
    #if os(iOS)
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    #endif

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Background circles
            Circle()
                .foregroundColor(Color.blue.opacity(0.4))
                .padding(-150)
                .scaleEffect(pulseScale)
            Circle()
                .foregroundColor(Color.blue.opacity(0.6))
                .padding(-90)
                .scaleEffect(pulseScale)
            Circle()
                .foregroundColor(Color.blue)
                .padding(-20)
                .shadow(radius: 10)
                .scaleEffect(pulseScale)
            Circle()
                .scale(animationEffect ? 3 : 0)
                .offset(y: 100)
                .foregroundColor(Color.black)

            VStack(spacing: 10) {
                Text(localizedString("Welcome", languageCode: selectedLanguageCurrency.languageCode))
                    .scaleEffect(animationEffect ? 0 : 1)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                // User input Name prompt --------------
                CustomTextField(placeholder: "Enter your name", text: $userName, languageCode: selectedLanguageCurrency.languageCode)
                    .frame(width: 250)
                    .padding(.bottom, 10)
                    .scaleEffect(animationEffect ? 0 : 1)

                // User input Income prompt --------------
                CustomTextField(placeholder: "Set your income", text: Binding(
                    get: { income > 0 ? String(Int(income)) : "" },
                    set: { newValue in
                        if let value = Float(newValue) {
                            income = value
                        } else if newValue.isEmpty {
                            income = 0
                        }
                    }
                ), suffix: selectedLanguageCurrency.currencySymbol, languageCode: selectedLanguageCurrency.languageCode)
                .frame(width: 250)
                .scaleEffect(animationEffect ? 0 : 1)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif

                // Language and Currency Picker --------------
                VStack(spacing: 8) {
                    Text(localizedString("Language and Currency", languageCode: selectedLanguageCurrency.languageCode))
                        .font(.caption)
                        .foregroundColor(.white)
                        .bold()

                    Picker("Language and Currency", selection: $selectedLanguageCurrency) {
                        ForEach(LanguageCurrency.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    #if os(iOS)
                    .pickerStyle(.wheel)
                    #else
                    .pickerStyle(.radioGroup)
                    #endif
                    .frame(width: 250, height: 100)
                    .clipped()
                }
                .scaleEffect(animationEffect ? 0 : 1)
                .padding(.top, 5)

                Button(action: {
                    #if os(iOS)
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    #endif

                    UserDefaults.standard.set(income, forKey: "inkomst")
                    UserDefaults.standard.set(userName, forKey: "userName")
                    UserDefaults.standard.set(selectedLanguageCurrency.rawValue, forKey: "languageCurrency")
                    withAnimation {
                        animationEffect = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showMainView = false
                        showSecondView = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(localizedString("Start", languageCode: selectedLanguageCurrency.languageCode))
                            .font(.system(size: 22, weight: .semibold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 28))
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 55)
                    .cornerRadius(14)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .scaleEffect(animationEffect ? 0 : 1)
                .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty || income == 0)
                .opacity((userName.trimmingCharacters(in: .whitespaces).isEmpty || income == 0) ? 0.6 : 1.0)
                .padding(.top, 15)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }
        }
    }
}

// MARK: - Budget View
struct BudgetView: View {
    @Binding var income: Float
    let expenses: [String:Int]
    @Binding var showEditView: Bool
    @Binding var showAddView: Bool
    @Binding var inputKey: String
    @Binding var inputValue: String
    let onDelete: (IndexSet) -> Void
    let onSave: () -> Void
    @Binding var userName: String
    @Binding var selectedLanguageCurrency: LanguageCurrency
    @State private var isEditingCategories = false
    @State private var editButtonTimer: Timer?

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    if !userName.isEmpty {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(localizedString("Hello,", languageCode: selectedLanguageCurrency.languageCode))
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text(userName)
                                    .font(.title)
                                    .bold()
                            }
                            Spacer()
                            Button(action: {
                                showEditView = true
                            }) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.top, 16)
                        .padding(.leading, 20)
                        .padding(.bottom, 8)
                    }
                    List {
                        BudgetSummaryView(income: income, expenses: expenses, currencySymbol: selectedLanguageCurrency.currencySymbol, languageCode: selectedLanguageCurrency.languageCode)
                        Section(header:
                            HStack {
                                Text(localizedString("Expenses", languageCode: selectedLanguageCurrency.languageCode))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Button(isEditingCategories ? localizedString("Done", languageCode: selectedLanguageCurrency.languageCode) : localizedString("Edit", languageCode: selectedLanguageCurrency.languageCode)) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isEditingCategories.toggle()
                                    }
                                    #if os(iOS)
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    #endif

                                    // Cancel any existing timer
                                    editButtonTimer?.invalidate()

                                    if isEditingCategories {
                                        // Start a new timer to revert after 4 seconds
                                        editButtonTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                isEditingCategories = false
                                            }
                                            #if os(iOS)
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            #endif
                                        }
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            .padding(.vertical, 8)
                        ) {
                            ForEach(expenses.sorted { $0.1 > $1.1 }, id: \.key) { key, value in
                                HStack {
                                    let parts = key.split(separator: " ", maxSplits: 1)
                                    if parts.count == 2 {
                                        Image(systemName: String(parts[0]))
                                            .foregroundColor(.blue)
                                        Text(String(parts[1]))
                                    } else {
                                        Text(key)
                                    }
                                    Spacer()
                                    Text("\(value) \(selectedLanguageCurrency.currencySymbol)")
                                        .foregroundColor(.secondary)
                                    if isEditingCategories {
                                        Button(action: {
                                            #if os(iOS)
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                            #endif
                                            if let index = expenses.sorted(by: { $0.1 > $1.1 }).firstIndex(where: { $0.key == key }) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    onDelete(IndexSet(integer: index))
                                                }
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.system(size: 22))
                                        }
                                        .padding(.leading, 8)
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: onDelete)
                        }
                    }
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    #endif
                    .sheet(isPresented: $showAddView) {
                        AddExpenseSheet(
                            inputKey: $inputKey,
                            inputValue: $inputValue,
                            showAddView: $showAddView,
                            onSave: onSave,
                            currencySymbol: selectedLanguageCurrency.currencySymbol,
                            languageCode: selectedLanguageCurrency.languageCode
                        )
                    }
                    .sheet(isPresented: $showEditView) {
                        EditIncomeSheet(
                            income: $income,
                            userName: $userName,
                            showEditView: $showEditView,
                            selectedLanguageCurrency: $selectedLanguageCurrency
                        )
                    }
                }
                // Floating Plus Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 45, height: 45)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 8, y: 4)
                        }
                        .padding(.trailing, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Budget Summary View
struct BudgetSummaryView: View {
    let income: Float
    let expenses: [String:Int]
    let currencySymbol: String
    var languageCode: String = "en"
    @State private var animateProgress = false

    private var totalExpenses: Int {
        expenses.values.reduce(0, +)
    }

    private var savings: Int {
        Int(income) - totalExpenses
    }

    private var yearlySavings: Int {
        savings * 12
    }

    private var spendingPercentage: Double {
        guard income > 0 else { return 0 }
        return Double(totalExpenses) / Double(income)
    }

    private var progressBarColor: Color {
        switch spendingPercentage {
        case 0..<0.5:
            return .green
        case 0.5..<0.7:
            return .yellow
        case 0.7..<0.9:
            return .orange
        default:
            return .red
        }
    }

    private var progressBarText: String {
        switch spendingPercentage {
        case 0..<0.5:
            return localizedString("Great! You're saving a lot", languageCode: languageCode)
        case 0.5..<0.7:
            return localizedString("Good! You're still saving", languageCode: languageCode)
        case 0.7..<0.9:
            return localizedString("Warning! You're spending a lot", languageCode: languageCode)
        default:
            return localizedString("Danger! You're spending almost everything", languageCode: languageCode)
        }
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedString("Monthly Income", languageCode: languageCode))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 25)
                    Label {
                        Text(formattedAmount(Int(income), currencySymbol: currencySymbol))
                    } icon: {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.green)
                    }
                    .labelStyle(IconOnlyLabelStyle())
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedString("Monthly Spent", languageCode: languageCode))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 25)
                    Label {
                        Text(formattedAmount(totalExpenses, currencySymbol: currencySymbol))
                    } icon: {
                        Text("💸")
                    }
                    .labelStyle(IconOnlyLabelStyle())
                }
            }
            .font(.title3)
            .padding(.bottom, 4)

            GeometryReader { geometry in
                VStack(spacing: 4) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 10)
                            .foregroundColor(.white)

                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: geometry.size.width * (animateProgress ? min(spendingPercentage, 1) : 0), height: 10)
                            .foregroundColor(progressBarColor)
                            .animation(.easeOut(duration: 0.8), value: animateProgress)
                    }

                    Text(progressBarText)
                        .font(.caption)
                        .foregroundColor(progressBarColor)
                }
            }
            .frame(height: 30)
            .padding(.vertical, 5)
            .onAppear { animateProgress = true }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedString("Monthly Saved", languageCode: languageCode))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 25)
                    Label {
                        Text(formattedAmount(savings, currencySymbol: currencySymbol))
                            .foregroundColor(savings >= 0 ? .green : .red)
                    } icon: {
                        Text("💰")
                    }
                    .labelStyle(IconOnlyLabelStyle())
                }
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text(localizedString("Yearly Saved", languageCode: languageCode))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 25)
                    Label {
                        Text(formattedAmount(yearlySavings, currencySymbol: currencySymbol))
                            .foregroundColor(yearlySavings >= 0 ? .green : .red)
                    } icon: {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .foregroundColor(.purple)
                    }
                    .labelStyle(IconOnlyLabelStyle())
                }
            }
            .font(.title3)
            .padding(.top, 4)
        }
    }
}

struct IconOnlyLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            configuration.icon
            configuration.title
        }
    }
}

// MARK: - Edit Income Sheet
struct EditIncomeSheet: View {
    @Binding var income: Float
    @Binding var userName: String
    @Binding var showEditView: Bool
    @Binding var selectedLanguageCurrency: LanguageCurrency
    #if os(iOS)
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    #endif

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(localizedString("Edit your name and income", languageCode: selectedLanguageCurrency.languageCode))
                    .font(.headline)

                CustomTextField(placeholder: "Enter your name", text: $userName, languageCode: selectedLanguageCurrency.languageCode)
                    .frame(width: 200)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)

                CustomTextField(placeholder: "Set your income", text: Binding(
                    get: { income > 0 ? String(Int(income)) : "" },
                    set: { newValue in
                        if let value = Float(newValue) {
                            income = value
                        } else if newValue.isEmpty {
                            income = 0
                        }
                    }
                ), suffix: selectedLanguageCurrency.currencySymbol, languageCode: selectedLanguageCurrency.languageCode)
                .frame(width: 200)
                .padding(.horizontal, 30)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif

                // Language and Currency Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizedString("Language and Currency", languageCode: selectedLanguageCurrency.languageCode))
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)

                    Picker("Language and Currency", selection: $selectedLanguageCurrency) {
                        ForEach(LanguageCurrency.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    #if os(iOS)
                    .pickerStyle(.wheel)
                    #else
                    .pickerStyle(.radioGroup)
                    #endif
                    .frame(height: 100)
                    .clipped()
                }
                .padding(.vertical, 10)

                Spacer()

                // Support Developer Section
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text(localizedString("Support the Developer", languageCode: selectedLanguageCurrency.languageCode))
                            .font(.headline)
                            .foregroundColor(.blue)
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.brown)
                    }

                    Text(localizedString("If you're enjoying iBudget and would like to support the development, consider buying me a coffee.", languageCode: selectedLanguageCurrency.languageCode))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text(localizedString("Email:", languageCode: selectedLanguageCurrency.languageCode))
                                .foregroundColor(.gray)
                            Text("kiko.devv@gmail.com")
                                .foregroundColor(.blue)
                                .textSelection(.enabled)
                        }

                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.blue)
                            Text(localizedString("PayPal:", languageCode: selectedLanguageCurrency.languageCode))
                                .foregroundColor(.gray)
                            Text("Nasrolla.hassani@gmail.com")
                                .foregroundColor(.blue)
                                .textSelection(.enabled)
                        }

                        HStack {
                            Image(systemName: "swedishkronasign.circle.fill")
                                .foregroundColor(.blue)
                            Text(localizedString("Swish:", languageCode: selectedLanguageCurrency.languageCode))
                                .foregroundColor(.gray)
                            Text("072-4499699")
                                .foregroundColor(.blue)
                                .textSelection(.enabled)
                        }
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
            }
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedString("Cancel", languageCode: selectedLanguageCurrency.languageCode)) {
                        showEditView = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localizedString("Save", languageCode: selectedLanguageCurrency.languageCode)) {
                        UserDefaults.standard.set(income, forKey: "inkomst")
                        UserDefaults.standard.set(userName, forKey: "userName")
                        UserDefaults.standard.set(selectedLanguageCurrency.rawValue, forKey: "languageCurrency")
                        showEditView = false
                    }
                }
            }
        }
    }
}

// MARK: - Add Expense Sheet
struct AddExpenseSheet: View {
    @Binding var inputKey: String
    @Binding var inputValue: String
    @Binding var showAddView: Bool
    let onSave: () -> Void
    let currencySymbol: String
    let languageCode: String

    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var sliderValue: Double = 0
    #if os(iOS)
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    #endif

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(predefinedCategories) { category in
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.name)
                        }.tag(category as ExpenseCategory?)
                    }
                }
                #if os(iOS)
                .pickerStyle(.wheel)
                #endif
                .padding(.horizontal)

                if let selected = selectedCategory {
                    if selected.name == "Other" {
                        CustomTextField(placeholder: "Enter category", text: $inputKey, languageCode: languageCode)
                            .frame(width: 200)
                            .padding(.horizontal, 30)
                            .padding(.bottom, 10)
                        #if os(iOS)
                        CustomTextField(placeholder: "Enter amount", text: $inputValue, suffix: currencySymbol, languageCode: languageCode)
                            .frame(width: 200)
                            .padding(.horizontal, 30)
                            .keyboardType(.numberPad)
                        #else
                        CustomTextField(placeholder: "Enter amount", text: $inputValue, suffix: currencySymbol, languageCode: languageCode)
                            .frame(width: 200)
                            .padding(.horizontal, 30)
                        #endif
                    } else {
                        Text("\(localizedString("Amount:", languageCode: languageCode)) \(formattedAmount(Int(sliderValue), currencySymbol: currencySymbol))")
                            .font(.headline)
                            .foregroundColor(.green)
                        Slider(value: $sliderValue, in: 0...20000, step: 100)
                            .tint(.green)
                            .padding(.horizontal, 30)
                            .onChange(of: sliderValue) { newValue in
                                inputValue = String(Int(newValue))
                                #if os(iOS)
                                feedbackGenerator.impactOccurred()
                                #endif
                            }
                    }
                }

                Spacer()
            }
            .padding(.top)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedString("Cancel", languageCode: languageCode)) {
                        inputKey = ""
                        inputValue = ""
                        showAddView = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localizedString("Save", languageCode: languageCode)) {
                        if let cat = selectedCategory {
                            if cat.name == "Other" {
                                // Prepend buying basket icon for custom category
                                inputKey = "cart.fill " + inputKey
                            } else {
                                inputKey = cat.icon + " " + cat.name
                            }
                        }
                        onSave()
                    }
                    .disabled(selectedCategory == nil || (selectedCategory?.name == "Other" ? (inputKey.isEmpty || inputValue.isEmpty) : inputValue.isEmpty))
                }
            }
            #endif
        }
        #if os(iOS)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        #endif
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BlueTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .foregroundColor(.black)
    }
}

// MARK: - Number Formatting Helper
func formattedAmount(_ value: Int, currencySymbol: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    return "\(formatted) \(currencySymbol)"
}

// MARK: - Localization Helper
func localizedString(_ key: String, languageCode: String? = nil) -> String {
    let language: String

    if let languageCode = languageCode {
        // Use the provided language code
        language = languageCode
    } else {
        // Fall back to system language
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let isSwedish = preferredLanguage.hasPrefix("sv")
        language = isSwedish ? "sv" : "en"
    }

    let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")!
    let bundle = Bundle(path: path)!
    return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
}

struct CustomTextField: View {
    // Input fields ----
    let placeholder: String
    @Binding var text: String
    var suffix: String? = nil
    var languageCode: String? = nil
    @FocusState var isTyping: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                TextField("", text: $text)
                    .padding(.leading)
                    .frame(height: 50)
                    .focused($isTyping)
                    .foregroundStyle(isTyping ? .white : .white)

                if let suffix = suffix, !text.isEmpty {
                    Text(suffix)
                        .foregroundColor(.white)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.trailing, 15)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isTyping ? Color.yellow : Color.white, lineWidth: 2)
                    .background(Color.gray.opacity(0.5).cornerRadius(10))
            )

            Text(localizedString(placeholder, languageCode: languageCode))
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isTyping || !text.isEmpty ? Color.blue : Color.clear)
                )
                .foregroundStyle(.white)
                .padding(.leading)
                .offset(y: isTyping || !text.isEmpty ? -27 : 0)
                .font(.caption)
        }
        .animation(.linear(duration: 0.2), value: isTyping)
        .animation(.linear(duration: 0.2), value: text.isEmpty)
    }
}
