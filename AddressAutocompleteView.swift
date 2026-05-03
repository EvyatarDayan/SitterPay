//
//  AddressAutocompleteView.swift
//  SitterPay
//
//  Created for Address Autocomplete using Google Places API
//

import SwiftUI
import Combine

// Google Places API Autocomplete Service
class AddressAutocompleteService: ObservableObject {
    @Published var suggestions: [AddressSuggestion] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let apiKey: String
    
    // You can set your Google Places API key here or via environment variable
    // Get your API key from: https://console.cloud.google.com/google/maps-apis
    init(apiKey: String? = nil) {
        // Try to get API key from environment or use provided one
        if let key = apiKey {
            self.apiKey = key
        } else if let envKey = ProcessInfo.processInfo.environment["GOOGLE_PLACES_API_KEY"] {
            self.apiKey = envKey
        } else {
            // Fallback: You should set this in your app's configuration
            self.apiKey = "" // Set your API key here or use environment variable
        }
    }
    
    func searchAddresses(_ query: String) {
        guard !query.isEmpty, !apiKey.isEmpty else {
            suggestions = []
            return
        }
        
        isLoading = true
        
        // Google Places API Autocomplete endpoint
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&key=\(apiKey)&types=address"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GooglePlacesResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Address autocomplete error: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.suggestions = response.predictions.map { prediction in
                        AddressSuggestion(
                            id: prediction.place_id,
                            description: prediction.description,
                            mainText: prediction.structured_formatting?.main_text ?? prediction.description,
                            secondaryText: prediction.structured_formatting?.secondary_text ?? ""
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func cancelSearch() {
        cancellables.removeAll()
        suggestions = []
        isLoading = false
    }
}

struct AddressSuggestion: Identifiable {
    let id: String
    let description: String
    let mainText: String
    let secondaryText: String
}

// Google Places API Response Models
struct GooglePlacesResponse: Codable {
    let predictions: [Prediction]
    let status: String
}

struct Prediction: Codable {
    let description: String
    let place_id: String
    let structured_formatting: StructuredFormatting?
}

struct StructuredFormatting: Codable {
    let main_text: String
    let secondary_text: String
}

// Address Autocomplete TextField Component
struct AddressAutocompleteTextField: View {
    @Binding var text: String
    @StateObject private var autocompleteService = AddressAutocompleteService()
    @FocusState private var isFocused: Bool
    @State private var showSuggestions = false
    
    var placeholder: String
    var onAddressSelected: ((String) -> Void)?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextField(placeholder, text: $text)
                .font(.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .onChange(of: text) { oldValue, newValue in
                    if !newValue.isEmpty {
                        autocompleteService.searchAddresses(newValue)
                        showSuggestions = true
                    } else {
                        showSuggestions = false
                        autocompleteService.suggestions = []
                    }
                }
                .onChange(of: isFocused) { oldValue, newValue in
                    if !newValue {
                        // Delay hiding suggestions to allow tap
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showSuggestions = false
                        }
                    } else if !text.isEmpty {
                        showSuggestions = true
                    }
                }
            
            // Suggestions dropdown
            if showSuggestions && !autocompleteService.suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(autocompleteService.suggestions.prefix(5)) { suggestion in
                        Button(action: {
                            text = suggestion.description
                            onAddressSelected?(suggestion.description)
                            showSuggestions = false
                            isFocused = false
                            autocompleteService.cancelSearch()
                        }) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.mainText)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    if !suggestion.secondaryText.isEmpty {
                                        Text(suggestion.secondaryText)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemBackground))
                        }
                        .buttonStyle(.plain)
                        
                        if suggestion.id != autocompleteService.suggestions.prefix(5).last?.id {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.top, 40)
            }
            
            // Loading indicator
            if autocompleteService.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                }
            }
        }
    }
}

// Alternative: Free OpenStreetMap Nominatim API (no API key needed)
class OpenStreetMapAutocompleteService: ObservableObject {
    @Published var suggestions: [AddressSuggestion] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func searchAddresses(_ query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        
        isLoading = true
        
        // OpenStreetMap Nominatim API (free, no API key needed)
        let urlString = "https://nominatim.openstreetmap.org/search?format=json&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&limit=5&addressdetails=1"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("SitterPay iOS App", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [OSMPlace].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("OSM autocomplete error: \(error)")
                    }
                },
                receiveValue: { [weak self] places in
                    self?.suggestions = places.map { place in
                        // Simplify address display - show only the most relevant parts
                        let parts = place.display_name.components(separatedBy: ",")
                        let mainText = parts.first?.trimmingCharacters(in: .whitespaces) ?? place.display_name
                        // Take only the next 2 parts for secondary (usually street and city)
                        let secondaryParts = Array(parts.dropFirst().prefix(2))
                        let secondaryText = secondaryParts.joined(separator: ", ").trimmingCharacters(in: .whitespaces)
                        
                        return AddressSuggestion(
                            id: String(place.place_id),
                            description: place.display_name,
                            mainText: mainText,
                            secondaryText: secondaryText
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func cancelSearch() {
        cancellables.removeAll()
        suggestions = []
        isLoading = false
    }
}

struct OSMPlace: Codable {
    let place_id: Int
    let display_name: String
    let lat: String
    let lon: String
}
