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
    @State private var showMainView: Bool = {
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        let income = UserDefaults.standard.float(forKey: "inkomst")
        return name.trimmingCharacters(in: .whitespaces).isEmpty || income == 0
    }()
    @State private var showSecondView: Bool = {
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        let income = UserDefaults.standard.float(forKey: "inkomst")
        return !(name.trimmingCharacters(in: .whitespaces).isEmpty || income == 0)
    }()
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
                    onEdit: editExpense,
                    userName: $userName,
                    selectedLanguageCurrency: $selectedLanguageCurrency
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            #if os(iOS)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            #endif
        }
    }
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

    private func editExpense(key: String, newAmount: Int) {
        expenses[key] = newAmount
        UserDefaults.standard.set(expenses, forKey: "listan")
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
    let onEdit: (String, Int) -> Void
    @Binding var userName: String
    @Binding var selectedLanguageCurrency: LanguageCurrency
    @State private var isEditingCategories = false
    @State private var editButtonTimer: Timer?
    @State private var editingExpenseKey: String? = nil
    @State private var editingAmountText: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    if !userName.isEmpty {
                        HStack(alignment: .center, spacing: 5) {
                            // Avatar with initials
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: [.blue, .blue.opacity(0.6)],
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 48, height: 48)
                                    .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
                                Text(String(userName.prefix(1)).uppercased())
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localizedString("Hello,", languageCode: selectedLanguageCurrency.languageCode))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(userName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .fontDesign(.rounded)
                            }
                            Spacer()
                            Button(action: {
                                showEditView = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                            .padding(.trailing, 20)
                        }
                        .padding(.top, 16)
                        .padding(.leading, 20)
                        .padding(.bottom, 8)
                    }
                    List {
                        BudgetSummaryView(income: income, expenses: expenses, currencySymbol: selectedLanguageCurrency.currencySymbol, languageCode: selectedLanguageCurrency.languageCode)
                    }
                    .frame(height: 220)
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    .contentMargins(.top, 20)
                    #endif



                    // -------------- Expenses header --------------------
                    HStack {
                        Text(localizedString("Expenses", languageCode: selectedLanguageCurrency.languageCode))
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        if !expenses.isEmpty {
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
                                // Start a new timer to revert after 6 seconds
                                editButtonTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { _ in
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
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 10)

                    //------------------ Scrollable expense list -----------
                    List {
                        if expenses.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text(localizedString("No expenses yet", languageCode: selectedLanguageCurrency.languageCode))
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text(localizedString("Tap + to add your first expense", languageCode: selectedLanguageCurrency.languageCode))
                                    .font(.subheadline)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        }
                        ForEach(expenses.sorted { $0.1 > $1.1 }, id: \.key) { key, value in
                            HStack(spacing: 12) {
                                let parts = key.split(separator: " ", maxSplits: 1)
                                if parts.count == 2 {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.7))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: String(parts[0]))
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    Text(localizedString(String(parts[1]), languageCode: selectedLanguageCurrency.languageCode))
                                        .fontWeight(.medium)
                                } else {
                                    Text(key)
                                        .fontWeight(.medium)
                                }
                                Spacer()
                                Text(formattedAmount(value, currencySymbol: selectedLanguageCurrency.currencySymbol))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
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
                                    .buttonStyle(.borderless)
                                    .padding(.leading, 8)
                                    .transition(.scale.combined(with: .opacity))
                                    Button(action: {
                                        #if os(iOS)
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        #endif
                                        editingAmountText = String(value)
                                        editingExpenseKey = key
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 22))
                                    }
                                    .buttonStyle(.borderless)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    if let index = expenses.sorted(by: { $0.1 > $1.1 }).firstIndex(where: { $0.key == key }) {
                                        onDelete(IndexSet(integer: index))
                                    }
                                } label: {
                                    Label(localizedString("Delete", languageCode: selectedLanguageCurrency.languageCode), systemImage: "trash")
                                }
                                Button {
                                    editingAmountText = String(value)
                                    editingExpenseKey = key
                                } label: {
                                    Label(localizedString("Edit", languageCode: selectedLanguageCurrency.languageCode), systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                        }

                    }
                    #if os(iOS)
                    .listStyle(.insetGrouped)
                    .contentMargins(.top, 0)
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
                    .sheet(item: $editingExpenseKey) { key in
                        EditExpenseSheet(
                            expenseKey: key,
                            amountText: $editingAmountText,
                            onSave: { newAmount in
                                onEdit(key, newAmount)
                                editingExpenseKey = nil
                            },
                            onCancel: {
                                editingExpenseKey = nil
                            },
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
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    LinearGradient(colors: [.blue, .blue.opacity(0.75)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: .blue.opacity(0.4), radius: 10, y: 5)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 1)
                    }
                }
            }
        }
    }
}

// -------------- Budget Summary View --------------------
struct BudgetSummaryView: View {
    let income: Float
    let expenses: [String:Int]
    let currencySymbol: String
    var languageCode: String = "en"
    @State private var animateProgress = false
    @State private var shimmerOffset: CGFloat = -0.3

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

    private var remainingPercentage: Double {
        max(1 - spendingPercentage, 0)
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
        VStack(spacing:0) {
            // Top row: Income & Spent
            HStack(spacing: 12) {
                StatCardView(
                    title: localizedString("Monthly Income", languageCode: languageCode),
                    amount: formattedAmount(Int(income), currencySymbol: currencySymbol),
                    iconImage: "money-icons/take-money",
                    amountColor: .primary
                )
                StatCardView(
                    title: localizedString("Monthly Spent", languageCode: languageCode),
                    amount: formattedAmount(totalExpenses, currencySymbol: currencySymbol),
                    iconImage: "money-icons/money-out",
                    amountColor: .primary
                )
            }

            // Progress bar
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 8)
                            .foregroundColor(Color(.systemGray5))

                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(colors: [progressBarColor, progressBarColor.opacity(0.7)],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geometry.size.width * (animateProgress ? remainingPercentage : 1), height: 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            stops: [
                                                .init(color: .clear, location: 0),
                                                .init(color: .white.opacity(0.5), location: 0.5),
                                                .init(color: .clear, location: 1)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 60)
                                    .offset(x: geometry.size.width * (shimmerOffset - 0.5))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .animation(.easeOut(duration: 1), value: animateProgress)
                    }
                }
                .frame(height: 8)

                Text(progressBarText)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(progressBarColor)
                    .padding(.top, 2)
                    .padding(.bottom, 1)
            }
            .padding(.top, 15)
            .onAppear {
                animateProgress = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(Animation.linear(duration: 5).repeatForever(autoreverses: false)) {
                        shimmerOffset = 1.3
                    }
                }
            }

            // Bottom row: Saved & Yearly
            HStack(spacing: 12) {
                StatCardView(
                    title: localizedString("Monthly Saved", languageCode: languageCode),
                    amount: formattedAmount(savings, currencySymbol: currencySymbol),
                    iconImage: "money-icons/money-sedlar",
                    amountColor: savings >= 0 ? .green : .red
                )
                StatCardView(
                    title: localizedString("Yearly Saved", languageCode: languageCode),
                    amount: formattedAmount(yearlySavings, currencySymbol: currencySymbol),
                    iconImage: "money-icons/money",
                    amountColor: yearlySavings >= 0 ? .green : .red
                )
            }
        }
        .frame(height:150)
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

// MARK: - Stat Card View
struct StatCardView: View {
    let title: String
    let amount: String
    let iconImage: String
    var amountColor: Color = .primary

    var body: some View {
        HStack(spacing: 10) {
            Image(iconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(amount)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(amountColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
        )
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
                Text(localizedString("Edit your name and income", languageCode: selectedLanguageCurrency.languageCode,))
                    .font(.headline)

                CustomTextField(placeholder: "Enter your name", text: $userName, languageCode: selectedLanguageCurrency.languageCode, labelColor: .gray, borderColor: .white)
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
                ), suffix: selectedLanguageCurrency.currencySymbol, languageCode: selectedLanguageCurrency.languageCode, labelColor: .gray, borderColor: .gray)
                .frame(width: 200)
                .padding(.horizontal, 30)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif

                // Language and Currency Picker
                VStack(alignment: .center, spacing: 8) {
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
        .onTapGesture {
            #if os(iOS)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            #endif
        }
    }
}

// MARK: - String Identifiable
extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Edit Expense Sheet
struct EditExpenseSheet: View {
    let expenseKey: String
    @Binding var amountText: String
    let onSave: (Int) -> Void
    let onCancel: () -> Void
    let currencySymbol: String
    let languageCode: String

    private var displayName: String {
        let parts = expenseKey.split(separator: " ", maxSplits: 1)
        return parts.count == 2 ? String(parts[1]) : expenseKey
    }

    private var iconName: String? {
        let parts = expenseKey.split(separator: " ", maxSplits: 1)
        return parts.count == 2 ? String(parts[0]) : nil
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Category header
                VStack(spacing: 8) {
                    if let icon = iconName {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [.blue, .blue.opacity(0.6)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 64, height: 64)
                                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)

                            Image(systemName: icon)
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    Text(localizedString(displayName, languageCode: languageCode))
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.top, 24)

                CustomTextField(
                    placeholder: "Enter amount",
                    text: $amountText,
                    suffix: currencySymbol,
                    languageCode: languageCode,
                    labelColor: .green,
                    borderColor: .green
                )
                .frame(width: 280)
                #if os(iOS)
                .keyboardType(.numberPad)
                #endif

                Spacer()

                // Save button
                VStack(spacing: 0) {
                    Divider()
                    Button {
                        if let value = Int(amountText) {
                            onSave(value)
                        }
                    } label: {
                        Text(localizedString("Save", languageCode: languageCode))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: amountText.isEmpty
                                                ? [Color.gray.opacity(0.4), Color.gray.opacity(0.4)]
                                                : [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .disabled(amountText.isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
            }
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedString("Cancel", languageCode: languageCode)) {
                        onCancel()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(43)
            #endif
        }
        .onTapGesture {
            #if os(iOS)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            #endif
        }
    }
}

//-------------------------------Expand Sheet-------------------------------
struct AddExpenseSheet: View {
    @Binding var inputKey: String
    @Binding var inputValue: String
    @Binding var showAddView: Bool
    let onSave: () -> Void
    let currencySymbol: String
    let languageCode: String

    @State private var selectedCategory: ExpenseCategory? = nil
    @State private var amountText: String = ""
    @State private var appearAnimation = false
    #if os(iOS)
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    #endif

    private let columns = [
        GridItem(.adaptive(minimum: 72, maximum: 90), spacing: 10)
    ]

    private var isSaveDisabled: Bool {
        selectedCategory == nil || (selectedCategory?.name == "Other"
            ? (inputKey.isEmpty || inputValue.isEmpty)
            : inputValue.isEmpty)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Selected category hero
                if let selected = selectedCategory {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [.blue, .blue.opacity(0.6)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 64, height: 64)
                                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)

                            Image(systemName: selected.icon)
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(appearAnimation ? 1 : 0.5)
                        .opacity(appearAnimation ? 1 : 0)

                        Text(localizedString(selected.name, languageCode: languageCode))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .transition(.scale.combined(with: .opacity))
                }

                ScrollView {
                    VStack(spacing: 20) {
                        // Amount input area
                        if let selected = selectedCategory {
                            VStack(spacing: 14) {
                                if selected.name == "Other" {
                                    CustomTextField(placeholder: "Enter category", text: $inputKey, languageCode: languageCode, labelColor: .green)
                                        .frame(width: 280)
                                }

                                CustomTextField(
                                    placeholder: "Enter amount",
                                    text: selected.name == "Other" ? $inputValue : $amountText,
                                    suffix: currencySymbol,
                                    languageCode: languageCode,
                                    labelColor: . green,
                                )
                                .frame(width: 280)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                                .onChange(of: amountText) { newValue in
                                    if selected.name != "Other" {
                                        inputValue = newValue
                                    }
                                }
                            }
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        // Category grid
                        VStack(alignment: .leading, spacing: 10) {
                            Text(localizedString("Category", languageCode: languageCode))
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal, 4)

                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(Array(predefinedCategories.enumerated()), id: \.element.id) { index, category in
                                    let isSelected = selectedCategory == category
                                    Button {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            selectedCategory = category
                                            appearAnimation = true
                                        }
                                        #if os(iOS)
                                        feedbackGenerator.impactOccurred()
                                        #endif
                                    } label: {
                                        VStack(spacing: 5) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 20))
                                                .frame(width: 44, height: 44)
                                                .background(
                                                    Circle()
                                                        .fill(isSelected
                                                              ? Color.blue
                                                              : Color(.systemGray5))
                                                )
                                                .foregroundColor(isSelected ? .white : .primary)
                                            Text(localizedString(category.name, languageCode: languageCode))
                                                .font(.system(size: 10, weight: .medium))
                                                .lineLimit(1)
                                                .foregroundColor(isSelected ? .blue : .secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(isSelected ? Color.blue.opacity(0.08) : Color.clear)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .scaleEffect(isSelected ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }

                // Bottom save button
                VStack(spacing: 0) {
                    Divider()
                    Button {
                        if let cat = selectedCategory {
                            if cat.name == "Other" {
                                inputKey = "cart.fill " + inputKey
                            } else {
                                inputKey = cat.icon + " " + cat.name
                            }
                        }
                        onSave()
                    } label: {
                        Text(localizedString("Save", languageCode: languageCode))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(
                                        LinearGradient(
                                            colors: isSaveDisabled
                                                ? [Color.gray.opacity(0.4), Color.gray.opacity(0.4)]
                                                : [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .disabled(isSaveDisabled)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                }
            }
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedString("Cancel", languageCode: languageCode)) {
                        inputKey = ""
                        inputValue = ""
                        showAddView = false
                    }
                    .foregroundColor(.secondary)
                }
            }
            #endif
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(43)
        #endif
        .onTapGesture {
            #if os(iOS)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            #endif
        }
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
    var labelColor: Color = .blue
    var borderColor: Color = .white
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
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isTyping ? Color.green : borderColor, lineWidth: 1)
                    .background(Color.gray.opacity(0.5).cornerRadius(10))
            )

            Text(localizedString(placeholder, languageCode: languageCode))
                .padding(.horizontal, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(isTyping || !text.isEmpty ? labelColor : Color.clear)
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
