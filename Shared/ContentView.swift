// Your task is to finish this application to satisfy requirements below and make it look like on the attached screenshots. Try to use 80/20 principle.
// Good luck! 🍀

// 1. Setup UI of the ContentView. Try to keep it as similar as possible.
// 2. Subscribe to the timer and count seconds down from 60 to 0 on the ContentView.
// 3. Present PaymentModalView as a sheet after tapping on the "Open payment" button.
// 4. Load payment types from repository in PaymentInfoView. Show loader when waiting for the response. No need to handle error.
// 5. List should be refreshable.
// 6. Show search bar for the list to filter payment types. You can filter items in any way.
// 7. User should select one of the types on the list. Show checkmark next to the name when item is selected.
// 8. Show "Done" button in navigation bar only if payment type is selected. Tapping this button should hide the modal.
// 9. Show "Finish" button on ContentScreen only when "payment type" was selected.
// 10. Replace main view with "FinishView" when user taps on the "Finish" button.

import SwiftUI
import Combine

class Model: ObservableObject {

    @Published var processDurationInSeconds: Int = 60
    private(set) var repository: PaymentTypesRepository = PaymentTypesRepositoryImplementation()
    private(set) var cancellable: Cancellable?
    
    init() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerCountDown()
            }
            
    }
    
    private func timerCountDown() {
        if processDurationInSeconds > 0 {
            processDurationInSeconds -= 1
        }
    }
}

struct ContentView: View {
    @State private var showPaymentModal = false
    @State private var showFninishView = false
    @State private var selectedPayment: PaymentType?
    
    @ObservedObject private var model = Model()
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack {
                // Seconds should count down from 60 to 0
                Spacer()
                Text("You have only \(model.processDurationInSeconds) seconds left to get the discount")
                    .foregroundColor(Color.white)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
                Button {
                    showPaymentModal.toggle()
                } label: {
                    Text("Open payment").frame(maxWidth: .infinity, maxHeight: 42)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.white)
                
                // Visible only if payment type is selected
                if selectedPayment != nil {
                    Button {
                        showFninishView.toggle()
                    } label: {
                        Text("Finish").frame(maxWidth: .infinity, maxHeight: 42)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.white)
                }
            }
            .padding()
            .sheet(isPresented: $showPaymentModal) {
                PaymentModalView(selectedPayment: $selectedPayment)
            }
            .fullScreenCover(isPresented: $showFninishView) {
                FinishView()
            }
            .environmentObject(model)
        }
    }
}

struct FinishView: View {
    var body: some View {
        Text("Congratulations")
    }
}

struct PaymentModalView : View {
    @Binding var selectedPayment: PaymentType?
    var body: some View {
        NavigationView {
            PaymentInfoView(selectedPayment: $selectedPayment)
        }
    }
}

struct PaymentInfoView: View {
    @State private var isLoading: Bool = false
    @State private var payments: [PaymentType] = []
    @State private var searchText = ""
    
    @Binding var selectedPayment: PaymentType?
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var model: Model
    
    var body: some View {
        // Load payment types when presenting the view. Repository has 2 seconds delay.
        // User should select an item.
        // Show checkmark in a selected row.
        //
        // No need to handle error.
        // Use refreshing mechanism to reload the list items.
        // Show loader before response comes.
        // Show search bar to filter payment types
        //
        // Finish button should be only available if user selected payment type.
        // Tapping on Finish button should close the modal.

        VStack {
            let filteredPayments = payments.filter { paymentType in
                if searchText.isEmpty { return true }
                
                return paymentType.name.lowercased().contains(searchText.lowercased())
            }
            List(filteredPayments, id: \.self, selection: $selectedPayment) { paymentType in
                let isSelected = paymentType.id == selectedPayment?.id
                ItemRow(paymentType: paymentType, selected: isSelected).onTapGesture {
                    selectedPayment = paymentType
                }
            }
            .overlay(alignment: .center) {
                if isLoading {
                    ProgressView()
                }
            }
            .refreshable {
                refresh()
            }
        }
        .onAppear {
            performSearch()
        }
        .searchable(text: $searchText)
        .navigationTitle("Payment info")
        .navigationBarItems(trailing: selectedPayment != nil ? Button("Done", action: {
            dismiss()
        }) : nil)
    }
    
    private func performSearch() {
        isLoading = true
        model.repository.getTypes { result in
            switch result {
            case .success(let payments):
                self.isLoading = false
                self.payments = payments
            case .failure:
                self.isLoading = false
            }
        }
    }
    
    private func refresh() {
        payments = []
        selectedPayment = nil
        performSearch()
    }
}

struct ItemRow: View {
    var paymentType: PaymentType
    var selected: Bool = false
    
    var body: some View {
        HStack {
            Text(paymentType.name)
            Spacer()
            if selected {
                Image(systemName: "checkmark")
            }
        }.listRowBackground(Color.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
