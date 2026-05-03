//
//  LocalizationManager.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-30.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("selectedLanguage") private var selectedLanguageName: String = "English"
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = "en"
    
    init() {
        // Initialize language code from language name if needed
        if selectedLanguageCode == "en" && selectedLanguageName != "English" {
            selectedLanguageCode = languageCode(for: selectedLanguageName)
        }
    }
    
    var currentLanguage: String {
        selectedLanguageCode
    }
    
    func setLanguage(_ language: String) {
        selectedLanguageName = language
        selectedLanguageCode = languageCode(for: language)
        objectWillChange.send()
    }
    
    private func languageCode(for language: String) -> String {
        switch language {
        case "English": return "en"
        case "French": return "fr"
        case "Swedish": return "sv"
        case "Spanish": return "es"
        case "German": return "de"
        case "Italian": return "it"
        case "Portuguese": return "pt"
        case "Russian": return "ru"
        case "Chinese": return "zh"
        case "Japanese": return "ja"
        case "Korean": return "ko"
        case "Hebrew": return "he"
        case "Arabic": return "ar"
        case "Dutch": return "nl"
        case "Polish": return "pl"
        case "Turkish": return "tr"
        case "Norwegian": return "no"
        case "Danish": return "da"
        case "Finnish": return "fi"
        case "Greek": return "el"
        case "Czech": return "cs"
        case "Hungarian": return "hu"
        case "Romanian": return "ro"
        case "Thai": return "th"
        case "Vietnamese": return "vi"
        case "Indonesian": return "id"
        case "Hindi": return "hi"
        default: return "en"
        }
    }
    
    func localizedString(_ key: String) -> String {
        return Translations.shared.getString(for: key, language: selectedLanguageCode)
    }
}

// Translation dictionary
class Translations {
    static let shared = Translations()
    
    private let translations: [String: [String: String]] = [
        // Navigation & Titles
        "live_session": [
            "en": "Live Session",
            "fr": "Session en Direct",
            "sv": "Live Session",
            "es": "Sesión en Vivo",
            "de": "Live Sitzung"
        ],
        "calculate": [
            "en": "Calculate",
            "fr": "Calculer",
            "sv": "Beräkna",
            "es": "Calcular",
            "de": "Berechnen"
        ],
        "history": [
            "en": "History",
            "fr": "Historique",
            "sv": "Historik",
            "es": "Historial",
            "de": "Verlauf"
        ],
        "settings": [
            "en": "Settings",
            "fr": "Paramètres",
            "sv": "Inställningar",
            "es": "Configuración",
            "de": "Einstellungen"
        ],
        "profile": [
            "en": "Profile",
            "fr": "Profil",
            "sv": "Profil",
            "es": "Perfil",
            "de": "Profil"
        ],
        
        // Live Session View
        "pay_per_hour": [
            "en": "Hourly rate",
            "fr": "Taux horaire",
            "sv": "Timlön",
            "es": "Tarifa por hora",
            "de": "Stundensatz"
        ],
        "hourly_rate": [
            "en": "Hourly rate",
            "fr": "Taux horaire",
            "sv": "Timlön",
            "es": "Tarifa por hora",
            "de": "Stundensatz"
        ],
        "other_pays": [
            "en": "Extras",
            "fr": "Extras",
            "sv": "Extras",
            "es": "Extras",
            "de": "Extras"
        ],
        "babysitter_name": [
            "en": "Babysitter name",
            "fr": "Nom de la baby-sitter",
            "sv": "Barnvaktsnamn",
            "es": "Nombre de la niñera",
            "de": "Name des Babysitters"
        ],
        "babysitter_name_placeholder": [
            "en": "e.g. Alexandra",
            "fr": "ex. Alexandra",
            "sv": "t.ex. Alexandra",
            "es": "ej. Alexandra",
            "de": "z.B. Alexandra"
        ],
        "comments": [
            "en": "Comments",
            "fr": "Commentaires",
            "sv": "Kommentarer",
            "es": "Comentarios",
            "de": "Kommentare"
        ],
        "my_babysitters": [
            "en": "My Babysitters",
            "fr": "Mes baby-sitters",
            "sv": "Mina barnvakter",
            "es": "Mis niñeras",
            "de": "Meine Babysitter"
        ],
        "manage_babysitters": [
            "en": "Manage your babysitters",
            "fr": "Gérez vos baby-sitters",
            "sv": "Hantera dina barnvakter",
            "es": "Administra tus niñeras",
            "de": "Verwalten Sie Ihre Babysitter"
        ],
        "statistics": [
            "en": "Statistics",
            "fr": "Statistiques",
            "sv": "Statistik",
            "es": "Estadísticas",
            "de": "Statistiken"
        ],
        "view_statistics": [
            "en": "View payment statistics and insights",
            "fr": "Voir les statistiques et informations de paiement",
            "sv": "Visa betalningsstatistik och insikter",
            "es": "Ver estadísticas e información de pagos",
            "de": "Zahlungsstatistiken und Einblicke anzeigen"
        ],
        "total_payments": [
            "en": "Total Payments",
            "fr": "Paiements totaux",
            "sv": "Totalt betalningar",
            "es": "Pagos totales",
            "de": "Gesamtzahlungen"
        ],
        "total_hours": [
            "en": "Total Hours",
            "fr": "Heures totales",
            "sv": "Totalt timmar",
            "es": "Horas totales",
            "de": "Gesamtstunden"
        ],
        "upcoming_events": [
            "en": "Upcoming Events",
            "fr": "Événements à venir",
            "sv": "Kommande händelser",
            "es": "Próximos eventos",
            "de": "Bevorstehende Ereignisse"
        ],
        "babysitters": [
            "en": "Babysitters",
            "fr": "Baby-sitters",
            "sv": "Barnvakter",
            "es": "Niñeras",
            "de": "Babysitter"
        ],
        "average_pay_per_hour": [
            "en": "Average Pay per Hour",
            "fr": "Paiement moyen par heure",
            "sv": "Genomsnittlig betalning per timme",
            "es": "Pago promedio por hora",
            "de": "Durchschnittlicher Stundenlohn"
        ],
        "pay_by_babysitter": [
            "en": "Pay by Babysitter",
            "fr": "Paiement par baby-sitter",
            "sv": "Betalning per barnvakt",
            "es": "Pago por niñera",
            "de": "Zahlung nach Babysitter"
        ],
        "no_statistics_available": [
            "en": "No statistics available yet",
            "fr": "Aucune statistique disponible pour le moment",
            "sv": "Ingen statistik tillgänglig ännu",
            "es": "No hay estadísticas disponibles aún",
            "de": "Noch keine Statistiken verfügbar"
        ],
        "add_babysitter": [
            "en": "Add Babysitter",
            "fr": "Ajouter une baby-sitter",
            "sv": "Lägg till barnvakt",
            "es": "Agregar niñera",
            "de": "Babysitter hinzufügen"
        ],
        "add_new": [
            "en": "Add new",
            "fr": "Ajouter nouveau",
            "sv": "Lägg till ny",
            "es": "Agregar nuevo",
            "de": "Neu hinzufügen"
        ],
        "edit_babysitter": [
            "en": "Edit Babysitter",
            "fr": "Modifier la baby-sitter",
            "sv": "Redigera barnvakt",
            "es": "Editar niñera",
            "de": "Babysitter bearbeiten"
        ],
        "no_babysitters": [
            "en": "No Babysitters",
            "fr": "Aucune baby-sitter",
            "sv": "Inga barnvakter",
            "es": "Sin niñeras",
            "de": "Keine Babysitter"
        ],
        "hourly_rate_required": [
            "en": "Hourly rate is required",
            "fr": "Le taux horaire est requis",
            "sv": "Timlön krävs",
            "es": "Se requiere tarifa por hora",
            "de": "Stundenlohn ist erforderlich"
        ],
        "phone_number_required": [
            "en": "Phone number is required",
            "fr": "Le numéro de téléphone est requis",
            "sv": "Telefonnummer krävs",
            "es": "Se requiere número de teléfono",
            "de": "Telefonnummer ist erforderlich"
        ],
        "invalid_email": [
            "en": "Invalid email address",
            "fr": "Adresse e-mail invalide",
            "sv": "Ogiltig e-postadress",
            "es": "Dirección de correo electrónico inválida",
            "de": "Ungültige E-Mail-Adresse"
        ],
        "tap_add_to_create_babysitter": [
            "en": "Tap the + button to add a new babysitter",
            "fr": "Appuyez sur le bouton + pour ajouter une nouvelle baby-sitter",
            "sv": "Tryck på +-knappen för att lägga till en ny barnvakt",
            "es": "Toca el botón + para agregar una nueva niñera",
            "de": "Tippen Sie auf die +-Schaltfläche, um einen neuen Babysitter hinzuzufügen"
        ],
        "login_to_manage_babysitters": [
            "en": "Please log in to manage your babysitters",
            "fr": "Veuillez vous connecter pour gérer vos baby-sitters",
            "sv": "Logga in för att hantera dina barnvakter",
            "es": "Inicia sesión para administrar tus niñeras",
            "de": "Bitte melden Sie sich an, um Ihre Babysitter zu verwalten"
        ],
        "phone_number": [
            "en": "Phone Number",
            "fr": "Numéro de téléphone",
            "sv": "Telefonnummer",
            "es": "Número de teléfono",
            "de": "Telefonnummer"
        ],
        "address": [
            "en": "Address",
            "fr": "Adresse",
            "sv": "Adress",
            "es": "Dirección",
            "de": "Adresse"
        ],
        "select": [
            "en": "Select",
            "fr": "Sélectionner",
            "sv": "Välj",
            "es": "Seleccionar",
            "de": "Auswählen"
        ],
        "select_babysitter": [
            "en": "Select Babysitter",
            "fr": "Sélectionner une baby-sitter",
            "sv": "Välj barnvakt",
            "es": "Seleccionar niñera",
            "de": "Babysitter auswählen"
        ],
        "please_sign_in_to_view_babysitters": [
            "en": "Please sign in to view your babysitters",
            "fr": "Veuillez vous connecter pour voir vos baby-sitters",
            "sv": "Vänligen logga in för att se dina barnvakter",
            "es": "Por favor, inicia sesión para ver tus niñeras",
            "de": "Bitte melden Sie sich an, um Ihre Babysitter zu sehen"
        ],
        "name": [
            "en": "Name",
            "fr": "Nom",
            "sv": "Namn",
            "es": "Nombre",
            "de": "Name"
        ],
        "time": [
            "en": "Time",
            "fr": "Temps",
            "sv": "Tid",
            "es": "Tiempo",
            "de": "Zeit"
        ],
        "pay": [
            "en": "Pay",
            "fr": "Paiement",
            "sv": "Betalning",
            "es": "Pago",
            "de": "Bezahlung"
        ],
        "clear_all": [
            "en": "Clear all",
            "fr": "Tout effacer",
            "sv": "Rensa allt",
            "es": "Limpiar todo",
            "de": "Alles löschen"
        ],
        "reset": [
            "en": "Reset",
            "fr": "Réinitialiser",
            "sv": "Återställ",
            "es": "Restablecer",
            "de": "Zurücksetzen"
        ],
        "click_play_instruction": [
            "en": "Tap start to begin tracking time for the current sitter session",
            "fr": "Appuyez sur démarrer pour commencer à suivre le temps de la session de garde actuelle",
            "sv": "Tryck på start för att börja spåra tiden för den aktuella barnvaktssessionen",
            "es": "Toca inicio para comenzar a rastrear el tiempo de la sesión de niñera actual",
            "de": "Tippen Sie auf Start, um mit der Zeitverfolgung für die aktuelle Babysitter-Sitzung zu beginnen"
        ],
        "payment_in_process": [
            "en": "Payment in process...",
            "fr": "Paiement en cours...",
            "sv": "Betalning pågår...",
            "es": "Pago en proceso...",
            "de": "Zahlung läuft..."
        ],
        "session_is_running": [
            "en": "Session is running",
            "fr": "La session est en cours",
            "sv": "Sessionen pågår",
            "es": "La sesión está en curso",
            "de": "Sitzung läuft"
        ],
        "session_ended": [
            "en": "Session ended",
            "fr": "Session terminée",
            "sv": "Sessionen avslutad",
            "es": "Sesión finalizada",
            "de": "Sitzung beendet"
        ],
        "ready_to_start": [
            "en": "Ready to start",
            "fr": "Prêt à démarrer",
            "sv": "Redo att starta",
            "es": "Listo para comenzar",
            "de": "Bereit zum Starten"
        ],
        "manual_entry": [
            "en": "Manual Entry",
            "fr": "Saisie manuelle",
            "sv": "Manuell inmatning",
            "es": "Entrada manual",
            "de": "Manuelle Eingabe"
        ],
        "enter_manually": [
            "en": "Enter Manually",
            "fr": "Saisir manuellement",
            "sv": "Ange manuellt",
            "es": "Ingresar manualmente",
            "de": "Manuell eingeben"
        ],
        "start": [
            "en": "START",
            "fr": "DÉMARRER",
            "sv": "STARTA",
            "es": "INICIAR",
            "de": "STARTEN"
        ],
        "end": [
            "en": "END",
            "fr": "TERMINER",
            "sv": "SLUTA",
            "es": "FINALIZAR",
            "de": "BEENDEN"
        ],
        "save": [
            "en": "Save",
            "fr": "Enregistrer",
            "sv": "Spara",
            "es": "Guardar",
            "de": "Speichern"
        ],
        "save_to_history": [
            "en": "Save to History",
            "fr": "Enregistrer dans l'historique",
            "sv": "Spara till historik",
            "es": "Guardar en Historial",
            "de": "Im Verlauf speichern"
        ],
        "mark_as_paid": [
            "en": "Mark as Paid",
            "fr": "Marquer comme payé",
            "sv": "Markera som betald",
            "es": "Marcar como pagado",
            "de": "Als bezahlt markieren"
        ],
        "mark_as_unpaid": [
            "en": "Mark as Unpaid",
            "fr": "Marquer comme non payé",
            "sv": "Markera som obetald",
            "es": "Marcar como no pagado",
            "de": "Als unbezahlt markieren"
        ],
        "payment_status": [
            "en": "Payment Status",
            "fr": "Statut du paiement",
            "sv": "Betalningsstatus",
            "es": "Estado del pago",
            "de": "Zahlungsstatus"
        ],
        "paid": [
            "en": "Paid",
            "fr": "Payé",
            "sv": "Betald",
            "es": "Pagado",
            "de": "Bezahlt"
        ],
        "pending": [
            "en": "Pending",
            "fr": "En attente",
            "sv": "Väntande",
            "es": "Pendiente",
            "de": "Ausstehend"
        ],
        "saved_to_history": [
            "en": "Saved to History",
            "fr": "Enregistré dans l'historique",
            "sv": "Sparad till historik",
            "es": "Guardado en Historial",
            "de": "Im Verlauf gespeichert"
        ],
        "pay_saved_to_history": [
            "en": "Session saved to history",
            "fr": "Session enregistrée dans l'historique",
            "sv": "Session sparad i historiken",
            "es": "Sesión guardada en el historial",
            "de": "Sitzung im Verlauf gespeichert"
        ],
        "click_on_history_button_to_see_it": [
            "en": "Click on history button to see it",
            "fr": "Cliquez sur le bouton historique pour le voir",
            "sv": "Klicka på historik-knappen för att se den",
            "es": "Haz clic en el botón de historial para verlo",
            "de": "Klicken Sie auf die Schaltfläche Verlauf, um es zu sehen"
        ],
        "you_need_to_pay": [
            "en": "You need to pay",
            "fr": "Vous devez payer",
            "sv": "Du behöver betala",
            "es": "Necesitas pagar",
            "de": "Sie müssen zahlen"
        ],
        "worked_from": [
            "en": "worked from",
            "fr": "a travaillé de",
            "sv": "arbetade från",
            "es": "trabajó desde",
            "de": "arbeitete von"
        ],
        "payment_of": [
            "en": "Payment of",
            "fr": "Paiement de",
            "sv": "Betalning på",
            "es": "Pago de",
            "de": "Zahlung von"
        ],
        "is_due_to": [
            "en": " is due to ",
            "fr": " est dû à ",
            "sv": " ska betalas till ",
            "es": " se debe a ",
            "de": " ist fällig an "
        ],
        "for_work_completed_from": [
            "en": " for work completed from ",
            "fr": " pour le travail effectué du ",
            "sv": " för arbete som slutförts från ",
            "es": " por trabajo completado desde ",
            "de": " für abgeschlossene Arbeit vom "
        ],
        "to": [
            "en": " to ",
            "fr": " au ",
            "sv": " till ",
            "es": " hasta ",
            "de": " bis "
        ],
        "total": [
            "en": " (total: ",
            "fr": " (total : ",
            "sv": " (totalt: ",
            "es": " (total: ",
            "de": " (gesamt: "
        ],
        "payment_summary_end": [
            "en": ").",
            "fr": ").",
            "sv": ").",
            "es": ").",
            "de": ")."
        ],
        "the_babysitter": [
            "en": "the babysitter",
            "fr": "la baby-sitter",
            "sv": "barnvakten",
            "es": "la niñera",
            "de": "der Babysitter"
        ],
        "hour": [
            "en": "hour",
            "fr": "heure",
            "sv": "timme",
            "es": "hora",
            "de": "Stunde"
        ],
        "hours": [
            "en": "hours",
            "fr": "heures",
            "sv": "timmar",
            "es": "horas",
            "de": "Stunden"
        ],
        "minute": [
            "en": "minute",
            "fr": "minute",
            "sv": "minut",
            "es": "minuto",
            "de": "Minute"
        ],
        "minutes": [
            "en": "minutes",
            "fr": "minutes",
            "sv": "minuter",
            "es": "minutos",
            "de": "Minuten"
        ],
        "and": [
            "en": "and",
            "fr": "et",
            "sv": "och",
            "es": "y",
            "de": "und"
        ],
        "are_you_sure": [
            "en": "Are you sure?",
            "fr": "Êtes-vous sûr?",
            "sv": "Är du säker?",
            "es": "¿Estás seguro?",
            "de": "Sind Sie sicher?"
        ],
        "stop_confirmation_message": [
            "en": "Do you want to stop the live session?",
            "fr": "Voulez-vous arrêter la session en direct?",
            "sv": "Vill du stoppa live sessionen?",
            "es": "¿Quieres detener la sesión en vivo?",
            "de": "Möchten Sie die Live-Sitzung beenden?"
        ],
        "yes": [
            "en": "Yes",
            "fr": "Oui",
            "sv": "Ja",
            "es": "Sí",
            "de": "Ja"
        ],
        "continue": [
            "en": "Continue",
            "fr": "Continuer",
            "sv": "Fortsätt",
            "es": "Continuar",
            "de": "Fortsetzen"
        ],
        
        // History View
        "no_history_saved_yet": [
            "en": "No history saved yet",
            "fr": "Aucun historique enregistré",
            "sv": "Ingen historik sparad ännu",
            "es": "Aún no hay historial guardado",
            "de": "Noch kein Verlauf gespeichert"
        ],
        
        // Settings View
        "authentication": [
            "en": "AUTHENTICATION",
            "fr": "AUTHENTIFICATION",
            "sv": "AUTENTISERING",
            "es": "AUTENTICACIÓN",
            "de": "AUTHENTIFIZIERUNG"
        ],
        "preferences": [
            "en": "PREFERENCES",
            "fr": "PRÉFÉRENCES",
            "sv": "INSTÄLLNINGAR",
            "es": "PREFERENCIAS",
            "de": "EINSTELLUNGEN"
        ],
        "support": [
            "en": "SUPPORT",
            "fr": "SUPPORT",
            "sv": "SUPPORT",
            "es": "SOPORTE",
            "de": "SUPPORT"
        ],
        "currency": [
            "en": "Currency",
            "fr": "Devise",
            "sv": "Valuta",
            "es": "Moneda",
            "de": "Währung"
        ],
        "select_currency": [
            "en": "Select currency",
            "fr": "Sélectionner la devise",
            "sv": "Välj valuta",
            "es": "Seleccionar moneda",
            "de": "Währung auswählen"
        ],
        "language": [
            "en": "Language",
            "fr": "Langue",
            "sv": "Språk",
            "es": "Idioma",
            "de": "Sprache"
        ],
        "select_app_language": [
            "en": "Select app language",
            "fr": "Sélectionner la langue de l'application",
            "sv": "Välj appens språk",
            "es": "Seleccionar idioma de la aplicación",
            "de": "App-Sprache auswählen"
        ],
        "dark_mode": [
            "en": "Dark Mode",
            "fr": "Mode Sombre",
            "sv": "Mörkt Läge",
            "es": "Modo Oscuro",
            "de": "Dunkler Modus"
        ],
        "enable_dark_mode": [
            "en": "Enable dark mode",
            "fr": "Activer le mode sombre",
            "sv": "Aktivera mörkt läge",
            "es": "Activar modo oscuro",
            "de": "Dunklen Modus aktivieren"
        ],
        "help_support": [
            "en": "Help & Support",
            "fr": "Aide et Support",
            "sv": "Hjälp & Support",
            "es": "Ayuda y Soporte",
            "de": "Hilfe & Support"
        ],
        "get_help_contact_support": [
            "en": "Get help and contact support",
            "fr": "Obtenir de l'aide et contacter le support",
            "sv": "Få hjälp och kontakta support",
            "es": "Obtener ayuda y contactar soporte",
            "de": "Hilfe erhalten und Support kontaktieren"
        ],
        "terms_privacy": [
            "en": "Terms & Privacy",
            "fr": "Conditions et Confidentialité",
            "sv": "Villkor & Integritet",
            "es": "Términos y Privacidad",
            "de": "Bedingungen & Datenschutz"
        ],
        "view_terms_privacy_policy": [
            "en": "View terms and privacy policy",
            "fr": "Voir les conditions et la politique de confidentialité",
            "sv": "Visa villkor och integritetspolicy",
            "es": "Ver términos y política de privacidad",
            "de": "Bedingungen und Datenschutzrichtlinie anzeigen"
        ],
        "about": [
            "en": "About",
            "fr": "À propos",
            "sv": "Om",
            "es": "Acerca de",
            "de": "Über"
        ],
        "app_version_information": [
            "en": "App version and information",
            "fr": "Version et informations de l'application",
            "sv": "Appversion och information",
            "es": "Versión e información de la aplicación",
            "de": "App-Version und Informationen"
        ],
        "select_language": [
            "en": "Select Language",
            "fr": "Sélectionner la Langue",
            "sv": "Välj Språk",
            "es": "Seleccionar Idioma",
            "de": "Sprache Auswählen"
        ],
        "all": [
            "en": "All",
            "fr": "Tout",
            "sv": "Allt",
            "es": "Todo",
            "de": "Alle"
        ],
        "last_week": [
            "en": "Last Week",
            "fr": "La semaine dernière",
            "sv": "Förra veckan",
            "es": "Semana pasada",
            "de": "Letzte Woche"
        ],
        "last_month": [
            "en": "Last Month",
            "fr": "Le mois dernier",
            "sv": "Förra månaden",
            "es": "Mes pasado",
            "de": "Letzter Monat"
        ],
        "last_3_months": [
            "en": "Last 3 Months",
            "fr": "3 derniers mois",
            "sv": "Senaste 3 månaderna",
            "es": "Últimos 3 meses",
            "de": "Letzte 3 Monate"
        ],
        "call": [
            "en": "Call",
            "fr": "Appeler",
            "sv": "Ringa",
            "es": "Llamar",
            "de": "Anrufen"
        ],
        "cancel": [
            "en": "Cancel",
            "fr": "Annuler",
            "sv": "Avbryt",
            "es": "Cancelar",
            "de": "Abbrechen"
        ],
        "select_currency_title": [
            "en": "Select Currency",
            "fr": "Sélectionner la Devise",
            "sv": "Välj Valuta",
            "es": "Seleccionar Moneda",
            "de": "Währung Auswählen"
        ],
        "currency_change_confirmation": [
            "en": "Are you sure? All history payments will be updated to %@!",
            "fr": "Êtes-vous sûr? Tous les paiements de l'historique seront mis à jour vers %@!",
            "sv": "Är du säker? Alla historiska betalningar kommer att uppdateras till %@!",
            "es": "¿Estás seguro? ¡Todos los pagos del historial se actualizarán a %@!",
            "de": "Sind Sie sicher? Alle Zahlungen im Verlauf werden auf %@ aktualisiert!"
        ],
        "done": [
            "en": "Done",
            "fr": "Terminé",
            "sv": "Klar",
            "es": "Hecho",
            "de": "Fertig"
        ],
        "search_currency": [
            "en": "Search currency",
            "fr": "Rechercher une devise",
            "sv": "Sök valuta",
            "es": "Buscar moneda",
            "de": "Währung suchen"
        ],
        
        // Authentication & Login
        "sign_in": [
            "en": "Sign In",
            "fr": "Se connecter",
            "sv": "Logga in",
            "es": "Iniciar sesión",
            "de": "Anmelden"
        ],
        "sign_up": [
            "en": "Sign Up",
            "fr": "S'inscrire",
            "sv": "Registrera dig",
            "es": "Registrarse",
            "de": "Registrieren"
        ],
        "please_sign_in_to_use_sitterpay": [
            "en": "Please sign in to use SitterPay.",
            "fr": "Veuillez vous connecter pour utiliser SitterPay.",
            "sv": "Vänligen logga in för att använda SitterPay.",
            "es": "Por favor inicia sesión para usar SitterPay.",
            "de": "Bitte melden Sie sich an, um SitterPay zu verwenden."
        ],
        "dont_have_an_account": [
            "en": "Don't have an account?",
            "fr": "Vous n'avez pas de compte ?",
            "sv": "Har du inget konto?",
            "es": "¿No tienes una cuenta?",
            "de": "Haben Sie kein Konto?"
        ],
        "sign_up_in_seconds": [
            "en": "Sign up in seconds.",
            "fr": "Inscrivez-vous en quelques secondes.",
            "sv": "Registrera dig på några sekunder.",
            "es": "Regístrate en segundos.",
            "de": "Registrieren Sie sich in Sekunden."
        ],
        "in_seconds": [
            "en": "in seconds.",
            "fr": "en quelques secondes.",
            "sv": "på några sekunder.",
            "es": "en segundos.",
            "de": "in Sekunden."
        ],
        "sign_in_to_your_account": [
            "en": "Sign in to your account",
            "fr": "Connectez-vous à votre compte",
            "sv": "Logga in på ditt konto",
            "es": "Inicia sesión en tu cuenta",
            "de": "Melden Sie sich in Ihrem Konto an"
        ],
        "access_your_data_across_devices": [
            "en": "Sign in to access your information",
            "fr": "Connectez-vous pour accéder à vos informations",
            "sv": "Logga in för att komma åt din information",
            "es": "Inicia sesión para acceder a tu información",
            "de": "Melden Sie sich an, um auf Ihre Informationen zuzugreifen"
        ],
        "welcome_back": [
            "en": "Welcome Back",
            "fr": "Bon retour",
            "sv": "Välkommen tillbaka",
            "es": "Bienvenido de nuevo",
            "de": "Willkommen zurück"
        ],
        "login_to_access_your_account": [
            "en": "Login to access your account",
            "fr": "Connectez-vous pour accéder à votre compte",
            "sv": "Logga in för att komma åt ditt konto",
            "es": "Inicia sesión para acceder a tu cuenta",
            "de": "Melden Sie sich an, um auf Ihr Konto zuzugreifen"
        ],
        "create_account": [
            "en": "Create Account",
            "fr": "Créer un compte",
            "sv": "Skapa konto",
            "es": "Crear cuenta",
            "de": "Konto erstellen"
        ],
        "sign_up_to_sync_your_data": [
            "en": "Sign up to sync your data",
            "fr": "Inscrivez-vous pour synchroniser vos données",
            "sv": "Registrera dig för att synkronisera dina data",
            "es": "Regístrate para sincronizar tus datos",
            "de": "Registrieren Sie sich, um Ihre Daten zu synchronisieren"
        ],
        "account_information": [
            "en": "Account Information",
            "fr": "Informations du compte",
            "sv": "Kontoinformation",
            "es": "Información de la cuenta",
            "de": "Kontoinformationen"
        ],
        "login_information": [
            "en": "Login Information",
            "fr": "Informations de connexion",
            "sv": "Inloggningsinformation",
            "es": "Información de inicio de sesión",
            "de": "Anmeldeinformationen"
        ],
        "password": [
            "en": "Password",
            "fr": "Mot de passe",
            "sv": "Lösenord",
            "es": "Contraseña",
            "de": "Passwort"
        ],
        "reenter_password": [
            "en": "Re-enter Password",
            "fr": "Retaper le mot de passe",
            "sv": "Ange lösenord igen",
            "es": "Vuelve a ingresar la contraseña",
            "de": "Passwort erneut eingeben"
        ],
        "please_enter_valid_email": [
            "en": "Please enter a valid email address",
            "fr": "Veuillez entrer une adresse e-mail valide",
            "sv": "Vänligen ange en giltig e-postadress",
            "es": "Por favor ingresa una dirección de correo electrónico válida",
            "de": "Bitte geben Sie eine gültige E-Mail-Adresse ein"
        ],
        "passwords_do_not_match": [
            "en": "Passwords do not match",
            "fr": "Les mots de passe ne correspondent pas",
            "sv": "Lösenorden matchar inte",
            "es": "Las contraseñas no coinciden",
            "de": "Die Passwörter stimmen nicht überein"
        ],
        "password_must_be_at_least_6_characters": [
            "en": "Password must be at least 6 characters long",
            "fr": "Le mot de passe doit contenir au moins 6 caractères",
            "sv": "Lösenordet måste vara minst 6 tecken långt",
            "es": "La contraseña debe tener al menos 6 caracteres",
            "de": "Das Passwort muss mindestens 6 Zeichen lang sein"
        ],
        "account_with_email_already_exists": [
            "en": "An account with this email already exists",
            "fr": "Un compte avec cet e-mail existe déjà",
            "sv": "Ett konto med denna e-post finns redan",
            "es": "Ya existe una cuenta con este correo electrónico",
            "de": "Ein Konto mit dieser E-Mail existiert bereits"
        ],
        "failed_to_create_account": [
            "en": "Failed to create account. Please try again.",
            "fr": "Échec de la création du compte. Veuillez réessayer.",
            "sv": "Kunde inte skapa konto. Försök igen.",
            "es": "Error al crear la cuenta. Por favor, inténtalo de nuevo.",
            "de": "Konto konnte nicht erstellt werden. Bitte versuchen Sie es erneut."
        ],
        "invalid_email_or_password": [
            "en": "Invalid email or password",
            "fr": "E-mail ou mot de passe invalide",
            "sv": "Ogiltig e-post eller lösenord",
            "es": "Correo electrónico o contraseña inválidos",
            "de": "Ungültige E-Mail oder Passwort"
        ],
        "ok": [
            "en": "OK",
            "fr": "OK",
            "sv": "OK",
            "es": "OK",
            "de": "OK"
        ],
        "account_created_successfully": [
            "en": "Account Created Successfully",
            "fr": "Compte créé avec succès",
            "sv": "Konto skapat framgångsrikt",
            "es": "Cuenta creada exitosamente",
            "de": "Konto erfolgreich erstellt"
        ],
        "welcome_first_name": [
            "en": "Welcome %@!",
            "fr": "Bienvenue %@ !",
            "sv": "Välkommen %@!",
            "es": "¡Bienvenido %@!",
            "de": "Willkommen %@!"
        ],
        "welcome_back_first_name": [
            "en": "Welcome back %@!",
            "fr": "Bon retour %@ !",
            "sv": "Välkommen tillbaka %@!",
            "es": "¡Bienvenido de nuevo %@!",
            "de": "Willkommen zurück %@!"
        ],
        
        // Profile View
        "edit_profile": [
            "en": "Edit Profile",
            "fr": "Modifier le profil",
            "sv": "Redigera profil",
            "es": "Editar perfil",
            "de": "Profil bearbeiten"
        ],
        "personal_information": [
            "en": "Personal Information",
            "fr": "Informations personnelles",
            "sv": "Personlig information",
            "es": "Información personal",
            "de": "Persönliche Informationen"
        ],
        "first_name": [
            "en": "First Name",
            "fr": "Prénom",
            "sv": "Förnamn",
            "es": "Nombre",
            "de": "Vorname"
        ],
        "last_name": [
            "en": "Last Name",
            "fr": "Nom de famille",
            "sv": "Efternamn",
            "es": "Apellido",
            "de": "Nachname"
        ],
        "email": [
            "en": "Email",
            "fr": "E-mail",
            "sv": "E-post",
            "es": "Correo electrónico",
            "de": "E-Mail"
        ],
        "email_cannot_be_updated": [
            "en": "Email cannot be updated",
            "fr": "L'e-mail ne peut pas être mis à jour",
            "sv": "E-post kan inte uppdateras",
            "es": "El correo electrónico no se puede actualizar",
            "de": "E-Mail kann nicht aktualisiert werden"
        ],
        "security": [
            "en": "Security",
            "fr": "Sécurité",
            "sv": "Säkerhet",
            "es": "Seguridad",
            "de": "Sicherheit"
        ],
        "update_password": [
            "en": "Update Password",
            "fr": "Mettre à jour le mot de passe",
            "sv": "Uppdatera lösenord",
            "es": "Actualizar contraseña",
            "de": "Passwort aktualisieren"
        ],
        "change_your_account_password": [
            "en": "Change your account password",
            "fr": "Modifier le mot de passe de votre compte",
            "sv": "Ändra ditt kontolösenord",
            "es": "Cambiar la contraseña de tu cuenta",
            "de": "Ändern Sie Ihr Kontopasswort"
        ],
        "update": [
            "en": "Update",
            "fr": "Mettre à jour",
            "sv": "Uppdatera",
            "es": "Actualizar",
            "de": "Aktualisieren"
        ],
        "delete_account": [
            "en": "Delete Account",
            "fr": "Supprimer le compte",
            "sv": "Ta bort konto",
            "es": "Eliminar cuenta",
            "de": "Konto löschen"
        ],
        "logout": [
            "en": "Logout",
            "fr": "Déconnexion",
            "sv": "Logga ut",
            "es": "Cerrar sesión",
            "de": "Abmelden"
        ],
        "are_you_sure_delete_account": [
            "en": "Are you sure you want to delete your account? This action cannot be undone.",
            "fr": "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action ne peut pas être annulée.",
            "sv": "Är du säker på att du vill ta bort ditt konto? Denna åtgärd kan inte ångras.",
            "es": "¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.",
            "de": "Sind Sie sicher, dass Sie Ihr Konto löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden."
        ],
        "delete": [
            "en": "Delete",
            "fr": "Supprimer",
            "sv": "Ta bort",
            "es": "Eliminar",
            "de": "Löschen"
        ],
        "library": [
            "en": "Library",
            "fr": "Bibliothèque",
            "sv": "Bibliotek",
            "es": "Biblioteca",
            "de": "Bibliothek"
        ],
        "avatar": [
            "en": "Avatar",
            "fr": "Avatar",
            "sv": "Avatar",
            "es": "Avatar",
            "de": "Avatar"
        ],
        "choose_avatar": [
            "en": "Choose Avatar",
            "fr": "Choisir un avatar",
            "sv": "Välj avatar",
            "es": "Elegir avatar",
            "de": "Avatar auswählen"
        ],
        "password_information": [
            "en": "Password Information",
            "fr": "Informations sur le mot de passe",
            "sv": "Lösenordsinformation",
            "es": "Información de contraseña",
            "de": "Passwortinformationen"
        ],
        "current_password": [
            "en": "Current Password",
            "fr": "Mot de passe actuel",
            "sv": "Nuvarande lösenord",
            "es": "Contraseña actual",
            "de": "Aktuelles Passwort"
        ],
        "new_password": [
            "en": "New Password",
            "fr": "Nouveau mot de passe",
            "sv": "Nytt lösenord",
            "es": "Nueva contraseña",
            "de": "Neues Passwort"
        ],
        "enter_your_current_password_and_choose_new_one": [
            "en": "Enter your current password and choose a new one",
            "fr": "Entrez votre mot de passe actuel et choisissez-en un nouveau",
            "sv": "Ange ditt nuvarande lösenord och välj ett nytt",
            "es": "Ingresa tu contraseña actual y elige una nueva",
            "de": "Geben Sie Ihr aktuelles Passwort ein und wählen Sie ein neues"
        ],
        "password_requirements": [
            "en": "Password Requirements",
            "fr": "Exigences du mot de passe",
            "sv": "Lösenordskrav",
            "es": "Requisitos de contraseña",
            "de": "Passwortanforderungen"
        ],
        "at_least_6_characters_long": [
            "en": "At least 6 characters long",
            "fr": "Au moins 6 caractères",
            "sv": "Minst 6 tecken långt",
            "es": "Al menos 6 caracteres de longitud",
            "de": "Mindestens 6 Zeichen lang"
        ],
        "new_password_must_be_different_from_current": [
            "en": "New password must be different from current",
            "fr": "Le nouveau mot de passe doit être différent de l'actuel",
            "sv": "Nytt lösenord måste skilja sig från det nuvarande",
            "es": "La nueva contraseña debe ser diferente de la actual",
            "de": "Das neue Passwort muss sich vom aktuellen unterscheiden"
        ],
        "password_update": [
            "en": "Password Update",
            "fr": "Mise à jour du mot de passe",
            "sv": "Lösenordsuppdatering",
            "es": "Actualización de contraseña",
            "de": "Passwortaktualisierung"
        ],
        "password_updated_successfully": [
            "en": "Password updated successfully",
            "fr": "Mot de passe mis à jour avec succès",
            "sv": "Lösenord uppdaterat framgångsrikt",
            "es": "Contraseña actualizada exitosamente",
            "de": "Passwort erfolgreich aktualisiert"
        ],
        "incorrect_current_password": [
            "en": "Incorrect current password",
            "fr": "Mot de passe actuel incorrect",
            "sv": "Felaktigt nuvarande lösenord",
            "es": "Contraseña actual incorrecta",
            "de": "Falsches aktuelles Passwort"
        ],
        "new_passwords_do_not_match": [
            "en": "New passwords do not match",
            "fr": "Les nouveaux mots de passe ne correspondent pas",
            "sv": "Nya lösenorden matchar inte",
            "es": "Las nuevas contraseñas no coinciden",
            "de": "Die neuen Passwörter stimmen nicht überein"
        ],
        "new_password_must_be_different_from_current_password": [
            "en": "New password must be different from current password",
            "fr": "Le nouveau mot de passe doit être différent du mot de passe actuel",
            "sv": "Nytt lösenord måste skilja sig från det nuvarande lösenordet",
            "es": "La nueva contraseña debe ser diferente de la contraseña actual",
            "de": "Das neue Passwort muss sich vom aktuellen Passwort unterscheiden"
        ],
        "new_password_must_be_at_least_6_characters_long": [
            "en": "New password must be at least 6 characters long",
            "fr": "Le nouveau mot de passe doit contenir au moins 6 caractères",
            "sv": "Nytt lösenord måste vara minst 6 tecken långt",
            "es": "La nueva contraseña debe tener al menos 6 caracteres",
            "de": "Das neue Passwort muss mindestens 6 Zeichen lang sein"
        ],
        "profile_update": [
            "en": "Profile Update",
            "fr": "Mise à jour du profil",
            "sv": "Profiluppdatering",
            "es": "Actualización de perfil",
            "de": "Profilaktualisierung"
        ],
        "failed_to_update_profile": [
            "en": "Failed to update profile",
            "fr": "Échec de la mise à jour du profil",
            "sv": "Kunde inte uppdatera profil",
            "es": "Error al actualizar el perfil",
            "de": "Profil konnte nicht aktualisiert werden"
        ],
        "profile_data_updated": [
            "en": "Profile data updated",
            "fr": "Données du profil mises à jour",
            "sv": "Profildata uppdaterad",
            "es": "Datos del perfil actualizados",
            "de": "Profildaten aktualisiert"
        ],
        "data_management": [
            "en": "DATA MANAGEMENT",
            "fr": "GESTION DES DONNÉES",
            "sv": "DATAHANTERING",
            "es": "GESTIÓN DE DATOS",
            "de": "DATENVERWALTUNG"
        ],
        "export": [
            "en": "Export",
            "fr": "Exporter",
            "sv": "Exportera",
            "es": "Exportar",
            "de": "Exportieren"
        ],
        "payment_history_summary": [
            "en": "Payment History Summary",
            "fr": "Résumé de l'historique des paiements",
            "sv": "Sammanfattning av betalningshistorik",
            "es": "Resumen del historial de pagos",
            "de": "Zahlungshistorie-Zusammenfassung"
        ],
        "total_records": [
            "en": "Total Records: %d",
            "fr": "Total des enregistrements : %d",
            "sv": "Totalt antal poster: %d",
            "es": "Total de registros: %d",
            "de": "Gesamtanzahl der Datensätze: %d"
        ],
        "export_data": [
            "en": "Export Data",
            "fr": "Exporter les données",
            "sv": "Exportera data",
            "es": "Exportar datos",
            "de": "Daten exportieren"
        ],
        "export_your_data_as_pdf": [
            "en": "Export your data as PDF",
            "fr": "Exporter vos données en PDF",
            "sv": "Exportera dina data som PDF",
            "es": "Exportar tus datos como PDF",
            "de": "Exportieren Sie Ihre Daten als PDF"
        ],
        "clear_all_data": [
            "en": "Clear All Data",
            "fr": "Effacer toutes les données",
            "sv": "Rensa all data",
            "es": "Borrar todos los datos",
            "de": "Alle Daten löschen"
        ],
        "clear_all_bills_and_data": [
            "en": "Clear all bills and data",
            "fr": "Effacer toutes les factures et données",
            "sv": "Rensa alla räkningar och data",
            "es": "Borrar todas las facturas y datos",
            "de": "Alle Rechnungen und Daten löschen"
        ],
        "please_sign_in_to_view_history": [
            "en": "Please sign in to view your history",
            "fr": "Veuillez vous connecter pour voir votre historique",
            "sv": "Vänligen logga in för att se din historik",
            "es": "Por favor inicia sesión para ver tu historial",
            "de": "Bitte melden Sie sich an, um Ihren Verlauf anzuzeigen"
        ],
        "please_sign_in_to_save_history": [
            "en": "Please sign in to save to history",
            "fr": "Veuillez vous connecter pour enregistrer dans l'historique",
            "sv": "Vänligen logga in för att spara till historik",
            "es": "Por favor inicia sesión para guardar en el historial",
            "de": "Bitte melden Sie sich an, um im Verlauf zu speichern"
        ],
        "time_range": [
            "en": "Time Range",
            "fr": "Plage horaire",
            "sv": "Tidsintervall",
            "es": "Rango de tiempo",
            "de": "Zeitspanne"
        ],
        "duration": [
            "en": "Duration",
            "fr": "Durée",
            "sv": "Varaktighet",
            "es": "Duración",
            "de": "Dauer"
        ],
        "tip": [
            "en": "Tip",
            "fr": "Pourboire",
            "sv": "Dricks",
            "es": "Propina",
            "de": "Trinkgeld"
        ],
        "share": [
            "en": "Share",
            "fr": "Partager",
            "sv": "Dela",
            "es": "Compartir",
            "de": "Teilen"
        ],
        "total_pay": [
            "en": "Total Pay",
            "fr": "Paiement total",
            "sv": "Total betalning",
            "es": "Pago total",
            "de": "Gesamtzahlung"
        ],
        "payment_details": [
            "en": "Payment Details",
            "fr": "Détails du paiement",
            "sv": "Betalningsdetaljer",
            "es": "Detalles del pago",
            "de": "Zahlungsdetails"
        ],
        "date": [
            "en": "Date",
            "fr": "Date",
            "sv": "Datum",
            "es": "Fecha",
            "de": "Datum"
        ],
        "work_information": [
            "en": "Work Information:",
            "fr": "Informations de travail :",
            "sv": "Arbetsinformation:",
            "es": "Información del trabajo:",
            "de": "Arbeitsinformationen:"
        ],
        "time_information": [
            "en": "Time Information",
            "fr": "Informations sur l'heure",
            "sv": "Tidsinformation",
            "es": "Información de tiempo",
            "de": "Zeitinformationen"
        ],
        "calendar": [
            "en": "Events",
            "fr": "Événements",
            "sv": "Händelser",
            "es": "Eventos",
            "de": "Ereignisse"
        ],
        "add_event": [
            "en": "Add Event",
            "fr": "Ajouter un événement",
            "sv": "Lägg till händelse",
            "es": "Agregar evento",
            "de": "Ereignis hinzufügen"
        ],
        "event_name": [
            "en": "Event name",
            "fr": "Nom de l'événement",
            "sv": "Händelsenamn",
            "es": "Nombre del evento",
            "de": "Ereignisname"
        ],
        "event": [
            "en": "Event",
            "fr": "Événement",
            "sv": "Händelse",
            "es": "Evento",
            "de": "Ereignis"
        ],
        "select_event": [
            "en": "Select Event",
            "fr": "Sélectionner un événement",
            "sv": "Välj händelse",
            "es": "Seleccionar evento",
            "de": "Ereignis auswählen"
        ],
        "event_information": [
            "en": "Event Information",
            "fr": "Informations sur l'événement",
            "sv": "Händelseinformation",
            "es": "Información del evento",
            "de": "Ereignisinformationen"
        ],
        "payment_information": [
            "en": "Payment Information",
            "fr": "Informations de paiement",
            "sv": "Betalningsinformation",
            "es": "Información de pago",
            "de": "Zahlungsinformationen"
        ],
        "babysitter_information": [
            "en": "Babysitter Information",
            "fr": "Informations sur la baby-sitter",
            "sv": "Barnvaktsinformation",
            "es": "Información de la niñera",
            "de": "Babysitter-Informationen"
        ],
        "pending_confirmation": [
            "en": "Pending confirmation",
            "fr": "En attente de confirmation",
            "sv": "Väntar på bekräftelse",
            "es": "Pendiente de confirmación",
            "de": "Bestätigung ausstehend"
        ],
        "confirmed_by": [
            "en": "Confirmed by %@",
            "fr": "Confirmé par %@",
            "sv": "Bekräftad av %@",
            "es": "Confirmado por %@",
            "de": "Bestätigt von %@"
        ],
        "event_details": [
            "en": "Event Details",
            "fr": "Détails de l'événement",
            "sv": "Händelsedetaljer",
            "es": "Detalles del evento",
            "de": "Ereignisdetails"
        ],
        "delete_event": [
            "en": "Delete Event",
            "fr": "Supprimer l'événement",
            "sv": "Ta bort händelse",
            "es": "Eliminar evento",
            "de": "Ereignis löschen"
        ],
        "are_you_sure_delete_event": [
            "en": "Are you sure you want to delete this event?",
            "fr": "Êtes-vous sûr de vouloir supprimer cet événement ?",
            "sv": "Är du säker på att du vill ta bort denna händelse?",
            "es": "¿Estás seguro de que quieres eliminar este evento?",
            "de": "Sind Sie sicher, dass Sie dieses Ereignis löschen möchten?"
        ],
        "no_events_for_this_date": [
            "en": "No events for this date",
            "fr": "Aucun événement pour cette date",
            "sv": "Inga händelser för detta datum",
            "es": "No hay eventos para esta fecha",
            "de": "Keine Ereignisse für dieses Datum"
        ],
        "please_sign_in_to_view_events": [
            "en": "Please sign in to view events",
            "fr": "Veuillez vous connecter pour voir les événements",
            "sv": "Vänligen logga in för att se händelser",
            "es": "Por favor, inicia sesión para ver eventos",
            "de": "Bitte melden Sie sich an, um Ereignisse anzuzeigen"
        ],
        "start_time": [
            "en": "Start Time",
            "fr": "Heure de début",
            "sv": "Starttid",
            "es": "Hora de inicio",
            "de": "Startzeit"
        ],
        "end_time": [
            "en": "End Time",
            "fr": "Heure de fin",
            "sv": "Sluttid",
            "es": "Hora de finalización",
            "de": "Endzeit"
        ],
        "end_time_must_be_after_start_time": [
            "en": "End time must be after start time!",
            "fr": "L'heure de fin doit être après l'heure de début !",
            "sv": "Sluttiden måste vara efter starttiden!",
            "es": "¡La hora de finalización debe ser después de la hora de inicio!",
            "de": "Die Endzeit muss nach der Startzeit liegen!"
        ],
        "terms_of_use_title": [
            "en": "Terms of Use",
            "fr": "Conditions d'utilisation",
            "sv": "Användarvillkor",
            "es": "Términos de uso",
            "de": "Nutzungsbedingungen"
        ],
        "privacy_policy_title": [
            "en": "Privacy Policy",
            "fr": "Politique de confidentialité",
            "sv": "Integritetspolicy",
            "es": "Política de privacidad",
            "de": "Datenschutzrichtlinie"
        ],
        "disclaimer_title": [
            "en": "Disclaimer",
            "fr": "Avertissement",
            "sv": "Friskrivning",
            "es": "Descargo de responsabilidad",
            "de": "Haftungsausschluss"
        ],
        "terms_of_use_content": [
            "en": """
            TERMS OF USE
            
            Last Updated: November 29, 2025
            
            Welcome to SitterPay. These Terms of Use ("Terms") govern your access to and use of the SitterPay mobile application ("App"). By using the App, you agree to be bound by these Terms.
            
            1. ACCEPTANCE OF TERMS
            By downloading, installing, or using SitterPay, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy.
            
            2. DESCRIPTION OF SERVICE
            SitterPay is a mobile application designed to help users calculate and track payments for babysitting services. The App allows users to:
            - Track time and calculate payments in real-time
            - Save payment history
            - Manage multiple babysitting sessions
            - Support multiple currencies
            
            3. USER ACCOUNTS
            You may create an account to use certain features of the App. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.
            
            4. ACCEPTABLE USE
            You agree to use the App only for lawful purposes and in accordance with these Terms. You agree not to:
            - Use the App for any illegal or unauthorized purpose
            - Attempt to gain unauthorized access to any part of the App
            - Interfere with or disrupt the App's functionality
            - Use automated systems to access the App
            
            5. INTELLECTUAL PROPERTY
            The App and its content, including but not limited to text, graphics, logos, and software, are the property of SitterPay and are protected by copyright and other intellectual property laws.
            
            6. LIMITATION OF LIABILITY
            SitterPay is provided "as is" without warranties of any kind. We do not guarantee that the App will be error-free or uninterrupted. In no event shall SitterPay be liable for any indirect, incidental, or consequential damages.
            
            7. MODIFICATIONS TO TERMS
            We reserve the right to modify these Terms at any time. Your continued use of the App after any changes constitutes acceptance of the modified Terms.
            
            8. CONTACT INFORMATION
            If you have any questions about these Terms, please contact us through the App's support section.
            """,
            "fr": """
            CONDITIONS D'UTILISATION
            
            Dernière mise à jour : 29 novembre 2025
            
            Bienvenue sur SitterPay. Ces Conditions d'utilisation ("Conditions") régissent votre accès et votre utilisation de l'application mobile SitterPay ("Application"). En utilisant l'Application, vous acceptez d'être lié par ces Conditions.
            
            1. ACCEPTATION DES CONDITIONS
            En téléchargeant, installant ou utilisant SitterPay, vous reconnaissez avoir lu, compris et accepté d'être lié par ces Conditions et notre Politique de confidentialité.
            
            2. DESCRIPTION DU SERVICE
            SitterPay est une application mobile conçue pour aider les utilisateurs à calculer et suivre les paiements pour les services de garde d'enfants. L'Application permet aux utilisateurs de :
            - Suivre le temps et calculer les paiements en temps réel
            - Enregistrer l'historique des paiements
            - Gérer plusieurs sessions de garde d'enfants
            - Prendre en charge plusieurs devises
            
            3. COMPTES UTILISATEUR
            Vous pouvez créer un compte pour utiliser certaines fonctionnalités de l'Application. Vous êtes responsable de maintenir la confidentialité de vos identifiants de compte et de toutes les activités qui se produisent sous votre compte.
            
            4. UTILISATION ACCEPTABLE
            Vous acceptez d'utiliser l'Application uniquement à des fins légales et conformément à ces Conditions. Vous acceptez de ne pas :
            - Utiliser l'Application à des fins illégales ou non autorisées
            - Tenter d'accéder sans autorisation à une partie de l'Application
            - Interférer avec ou perturber la fonctionnalité de l'Application
            - Utiliser des systèmes automatisés pour accéder à l'Application
            
            5. PROPRIÉTÉ INTELLECTUELLE
            L'Application et son contenu, y compris mais sans s'y limiter le texte, les graphiques, les logos et les logiciels, sont la propriété de SitterPay et sont protégés par le droit d'auteur et d'autres lois sur la propriété intellectuelle.
            
            6. LIMITATION DE RESPONSABILITÉ
            SitterPay est fourni "tel quel" sans garanties d'aucune sorte. Nous ne garantissons pas que l'Application sera exempte d'erreurs ou ininterrompue. En aucun cas SitterPay ne sera responsable de tout dommage indirect, accessoire ou consécutif.
            
            7. MODIFICATIONS DES CONDITIONS
            Nous nous réservons le droit de modifier ces Conditions à tout moment. Votre utilisation continue de l'Application après tout changement constitue une acceptation des Conditions modifiées.
            
            8. INFORMATIONS DE CONTACT
            Si vous avez des questions concernant ces Conditions, veuillez nous contacter via la section de support de l'Application.
            """,
            "sv": """
            ANVÄNDARVILLKOR
            
            Senast uppdaterad: 29 november 2025
            
            Välkommen till SitterPay. Dessa Användarvillkor ("Villkor") styr din åtkomst till och användning av SitterPay-mobilappen ("Appen"). Genom att använda Appen godkänner du att vara bunden av dessa Villkor.
            
            1. ACCEPTERANDE AV VILLKOR
            Genom att ladda ner, installera eller använda SitterPay bekräftar du att du har läst, förstått och godkänner att vara bunden av dessa Villkor och vår Integritetspolicy.
            
            2. BESKRIVNING AV TJÄNSTEN
            SitterPay är en mobilapplikation utformad för att hjälpa användare att beräkna och spåra betalningar för barnvaktstjänster. Appen gör det möjligt för användare att:
            - Spåra tid och beräkna betalningar i realtid
            - Spara betalningshistorik
            - Hantera flera barnvaktssessioner
            - Stödja flera valutor
            
            3. ANVÄNDARKONTON
            Du kan skapa ett konto för att använda vissa funktioner i Appen. Du är ansvarig för att upprätthålla konfidentialiteten för dina kontouppgifter och för alla aktiviteter som sker under ditt konto.
            
            4. ACCEPTABEL ANVÄNDNING
            Du godkänner att använda Appen endast för lagliga ändamål och i enlighet med dessa Villkor. Du godkänner att inte:
            - Använda Appen för något olagligt eller obehörigt ändamål
            - Försöka få obehörig åtkomst till någon del av Appen
            - Störa eller avbryta Appens funktionalitet
            - Använda automatiserade system för att komma åt Appen
            
            5. IMMATERIELLA RÄTTIGHETER
            Appen och dess innehåll, inklusive men inte begränsat till text, grafik, logotyper och programvara, är SitterPays egendom och skyddas av upphovsrätt och andra immateriella rättigheter.
            
            6. BEGRÄNSNING AV ANSVAR
            SitterPay tillhandahålls "som det är" utan garantier av något slag. Vi garanterar inte att Appen kommer att vara felfri eller oavbruten. Under inga omständigheter ska SitterPay vara ansvarig för några indirekta, tillfälliga eller följdskador.
            
            7. ÄNDRINGAR AV VILLKOR
            Vi förbehåller oss rätten att ändra dessa Villkor när som helst. Din fortsatta användning av Appen efter eventuella ändringar innebär acceptans av de ändrade Villkoren.
            
            8. KONTAKTINFORMATION
            Om du har några frågor om dessa Villkor, vänligen kontakta oss via Appens supportsektion.
            """,
            "es": """
            TÉRMINOS DE USO
            
            Última actualización: 29 de noviembre de 2025
            
            Bienvenido a SitterPay. Estos Términos de Uso ("Términos") rigen su acceso y uso de la aplicación móvil SitterPay ("Aplicación"). Al usar la Aplicación, acepta estar sujeto a estos Términos.
            
            1. ACEPTACIÓN DE TÉRMINOS
            Al descargar, instalar o usar SitterPay, reconoce que ha leído, entendido y acepta estar sujeto a estos Términos y nuestra Política de Privacidad.
            
            2. DESCRIPCIÓN DEL SERVICIO
            SitterPay es una aplicación móvil diseñada para ayudar a los usuarios a calcular y rastrear pagos por servicios de cuidado de niños. La Aplicación permite a los usuarios:
            - Rastrear tiempo y calcular pagos en tiempo real
            - Guardar historial de pagos
            - Gestionar múltiples sesiones de cuidado de niños
            - Soportar múltiples monedas
            
            3. CUENTAS DE USUARIO
            Puede crear una cuenta para usar ciertas funciones de la Aplicación. Usted es responsable de mantener la confidencialidad de sus credenciales de cuenta y de todas las actividades que ocurran bajo su cuenta.
            
            4. USO ACEPTABLE
            Acepta usar la Aplicación solo para fines legales y de acuerdo con estos Términos. Acepta no:
            - Usar la Aplicación para cualquier propósito ilegal o no autorizado
            - Intentar obtener acceso no autorizado a cualquier parte de la Aplicación
            - Interferir o interrumpir la funcionalidad de la Aplicación
            - Usar sistemas automatizados para acceder a la Aplicación
            
            5. PROPIEDAD INTELECTUAL
            La Aplicación y su contenido, incluyendo pero no limitado a texto, gráficos, logotipos y software, son propiedad de SitterPay y están protegidos por derechos de autor y otras leyes de propiedad intelectual.
            
            6. LIMITACIÓN DE RESPONSABILIDAD
            SitterPay se proporciona "tal cual" sin garantías de ningún tipo. No garantizamos que la Aplicación esté libre de errores o sea ininterrumpida. En ningún caso SitterPay será responsable de daños indirectos, incidentales o consecuentes.
            
            7. MODIFICACIONES A LOS TÉRMINOS
            Nos reservamos el derecho de modificar estos Términos en cualquier momento. Su uso continuo de la Aplicación después de cualquier cambio constituye la aceptación de los Términos modificados.
            
            8. INFORMACIÓN DE CONTACTO
            Si tiene alguna pregunta sobre estos Términos, por favor contáctenos a través de la sección de soporte de la Aplicación.
            """,
            "de": """
            NUTZUNGSBEDINGUNGEN
            
            Zuletzt aktualisiert: 29. November 2025
            
            Willkommen bei SitterPay. Diese Nutzungsbedingungen ("Bedingungen") regeln Ihren Zugang zu und die Nutzung der SitterPay-Mobilanwendung ("App"). Durch die Nutzung der App stimmen Sie zu, an diese Bedingungen gebunden zu sein.
            
            1. ANNAHME DER BEDINGUNGEN
            Durch das Herunterladen, Installieren oder Verwenden von SitterPay bestätigen Sie, dass Sie diese Bedingungen und unsere Datenschutzrichtlinie gelesen, verstanden und akzeptiert haben.
            
            2. BESCHREIBUNG DES DIENSTES
            SitterPay ist eine mobile Anwendung, die Benutzern helfen soll, Zahlungen für Babysitter-Dienste zu berechnen und zu verfolgen. Die App ermöglicht es Benutzern:
            - Zeit zu verfolgen und Zahlungen in Echtzeit zu berechnen
            - Zahlungshistorie zu speichern
            - Mehrere Babysitter-Sitzungen zu verwalten
            - Mehrere Währungen zu unterstützen
            
            3. BENUTZERKONTEN
            Sie können ein Konto erstellen, um bestimmte Funktionen der App zu nutzen. Sie sind dafür verantwortlich, die Vertraulichkeit Ihrer Kontodaten zu wahren und für alle Aktivitäten, die unter Ihrem Konto stattfinden.
            
            4. ZULÄSSIGE NUTZUNG
            Sie stimmen zu, die App nur für rechtmäßige Zwecke und in Übereinstimmung mit diesen Bedingungen zu verwenden. Sie stimmen zu, nicht:
            - Die App für illegale oder nicht autorisierte Zwecke zu verwenden
            - Unbefugten Zugriff auf einen Teil der App zu versuchen
            - Die Funktionalität der App zu stören oder zu unterbrechen
            - Automatisierte Systeme zum Zugriff auf die App zu verwenden
            
            5. GEISTIGES EIGENTUM
            Die App und ihr Inhalt, einschließlich aber nicht beschränkt auf Text, Grafiken, Logos und Software, sind Eigentum von SitterPay und durch Urheberrechte und andere Gesetze zum geistigen Eigentum geschützt.
            
            6. HAFTUNGSBESCHRÄNKUNG
            SitterPay wird "wie besehen" ohne Gewährleistungen jeglicher Art bereitgestellt. Wir garantieren nicht, dass die App fehlerfrei oder ununterbrochen ist. In keinem Fall haftet SitterPay für indirekte, zufällige oder Folgeschäden.
            
            7. ÄNDERUNGEN DER BEDINGUNGEN
            Wir behalten uns das Recht vor, diese Bedingungen jederzeit zu ändern. Ihre fortgesetzte Nutzung der App nach Änderungen stellt eine Annahme der geänderten Bedingungen dar.
            
            8. KONTAKTINFORMATIONEN
            Wenn Sie Fragen zu diesen Bedingungen haben, kontaktieren Sie uns bitte über den Support-Bereich der App.
            """
        ],
        "privacy_policy_content": [
            "en": """
            PRIVACY POLICY
            
            Last Updated: November 29, 2025
            
            At SitterPay, we are committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our mobile application.
            
            1. NO DATA COLLECTION
            SitterPay does not collect, transmit, or store any of your personal information on external servers. We do not collect:
            - Usage analytics
            - Device information
            - Location data
            - Any other personal data
            
            All information you enter into the App remains on your device only.
            
            2. LOCAL DATA STORAGE
            All your data is stored exclusively on your device using secure local storage methods. This includes:
            - Account information (name, email, password)
            - Payment history and calculations
            - Babysitting session data
            - App settings and preferences
            
            Your data never leaves your device and is not transmitted to any external servers or third parties.
            
            3. DATA MANAGEMENT
            You have full control over your data:
            - Clear All Data: In Settings, you can use the "Clear All Data" option to remove all payment information and history. This action cannot be undone.
            - Delete Account: In your Profile, you can delete your account, which will permanently remove:
              * Your login credentials and account information
              * All payment history and associated data
            This action is permanent and cannot be reversed.
            
            4. NO DATA SHARING
            Since we do not collect any data, we do not and cannot share your information with anyone. Your privacy is fully protected because your data never leaves your device.
            
            5. DATA SECURITY
            Your data is protected by your device's built-in security features. We use secure local storage methods provided by iOS to ensure your information remains private and secure on your device.
            
            6. YOUR RIGHTS
            You have complete control over your data:
            - All data is stored locally on your device
            - You can clear all payment data at any time through Settings
            - You can delete your account and all associated data through your Profile
            - No external parties have access to your information
            
            7. CHILDREN'S PRIVACY
            Our App is not intended for children under the age of 13. Since we do not collect any data, we do not collect personal information from anyone, including children.
            
            8. CHANGES TO THIS POLICY
            We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy in the App.
            
            9. CONTACT US
            If you have any questions about this Privacy Policy, please contact us through the App's support section.
            """,
            "fr": """
            POLITIQUE DE CONFIDENTIALITÉ
            
            Dernière mise à jour : 29 novembre 2025
            
            Chez SitterPay, nous nous engageons à protéger votre vie privée. Cette Politique de confidentialité explique comment nous gérons vos informations lorsque vous utilisez notre application mobile.
            
            1. AUCUNE COLLECTE DE DONNÉES
            SitterPay ne collecte, ne transmet ni ne stocke aucune de vos informations personnelles sur des serveurs externes. Nous ne collectons pas :
            - Les analyses d'utilisation
            - Les informations sur l'appareil
            - Les données de localisation
            - Toute autre donnée personnelle
            
            Toutes les informations que vous saisissez dans l'Application restent uniquement sur votre appareil.
            
            2. STOCKAGE LOCAL DES DONNÉES
            Toutes vos données sont stockées exclusivement sur votre appareil en utilisant des méthodes de stockage local sécurisées. Cela comprend :
            - Les informations de compte (nom, e-mail, mot de passe)
            - L'historique et les calculs de paiement
            - Les données des sessions de garde d'enfants
            - Les paramètres et préférences de l'Application
            
            Vos données ne quittent jamais votre appareil et ne sont pas transmises à des serveurs externes ou à des tiers.
            
            3. GESTION DES DONNÉES
            Vous avez un contrôle total sur vos données :
            - Effacer toutes les données : Dans les Paramètres, vous pouvez utiliser l'option "Effacer toutes les données" pour supprimer toutes les informations et l'historique de paiement. Cette action est irréversible.
            - Supprimer le compte : Dans votre Profil, vous pouvez supprimer votre compte, ce qui supprimera définitivement :
              * Vos identifiants de connexion et informations de compte
              * Tout l'historique de paiement et les données associées
            Cette action est permanente et ne peut pas être annulée.
            
            4. AUCUN PARTAGE DE DONNÉES
            Comme nous ne collectons aucune donnée, nous ne partageons pas et ne pouvons pas partager vos informations avec qui que ce soit. Votre vie privée est entièrement protégée car vos données ne quittent jamais votre appareil.
            
            5. SÉCURITÉ DES DONNÉES
            Vos données sont protégées par les fonctionnalités de sécurité intégrées de votre appareil. Nous utilisons des méthodes de stockage local sécurisées fournies par iOS pour garantir que vos informations restent privées et sécurisées sur votre appareil.
            
            6. VOS DROITS
            Vous avez un contrôle complet sur vos données :
            - Toutes les données sont stockées localement sur votre appareil
            - Vous pouvez effacer toutes les données de paiement à tout moment via les Paramètres
            - Vous pouvez supprimer votre compte et toutes les données associées via votre Profil
            - Aucun tiers externe n'a accès à vos informations
            
            7. CONFIDENTIALITÉ DES ENFANTS
            Notre Application n'est pas destinée aux enfants de moins de 13 ans. Comme nous ne collectons aucune donnée, nous ne collectons pas d'informations personnelles auprès de qui que ce soit, y compris les enfants.
            
            8. MODIFICATIONS DE CETTE POLITIQUE
            Nous pouvons mettre à jour cette Politique de confidentialité de temps à autre. Nous vous informerons de tout changement en publiant la nouvelle Politique de confidentialité dans l'Application.
            
            9. CONTACTEZ-NOUS
            Si vous avez des questions concernant cette Politique de confidentialité, veuillez nous contacter via la section de support de l'Application.
            """,
            "sv": """
            INTEGRITETSPOLICY
            
            Senast uppdaterad: 29 november 2025
            
            På SitterPay är vi engagerade i att skydda din integritet. Denna Integritetspolicy förklarar hur vi hanterar din information när du använder vår mobilapplikation.
            
            1. INGEN DATASAMLING
            SitterPay samlar inte in, överför eller lagrar någon av dina personuppgifter på externa servrar. Vi samlar inte in:
            - Användningsanalys
            - Enhetsinformation
            - Platsdata
            - Någon annan personlig data
            
            All information du anger i Appen förblir endast på din enhet.
            
            2. LOKAL DATALAGRING
            Alla dina data lagras endast på din enhet med säkra lokala lagringsmetoder. Detta inkluderar:
            - Kontoinformation (namn, e-post, lösenord)
            - Betalningshistorik och beräkningar
            - Barnvaktssessionsdata
            - Appinställningar och preferenser
            
            Dina data lämnar aldrig din enhet och överförs inte till externa servrar eller tredje part.
            
            3. DATAHANTERING
            Du har full kontroll över dina data:
            - Rensa all data: I Inställningar kan du använda alternativet "Rensa all data" för att ta bort all betalningsinformation och historik. Denna åtgärd kan inte ångras.
            - Ta bort konto: I din Profil kan du ta bort ditt konto, vilket permanent tar bort:
              * Dina inloggningsuppgifter och kontoinformation
              * All betalningshistorik och associerade data
            Denna åtgärd är permanent och kan inte ångras.
            
            4. INGEN DATADELNING
            Eftersom vi inte samlar in några data delar vi inte och kan inte dela din information med någon. Din integritet är fullt skyddad eftersom dina data aldrig lämnar din enhet.
            
            5. DATASÄKERHET
            Dina data skyddas av din enhets inbyggda säkerhetsfunktioner. Vi använder säkra lokala lagringsmetoder som tillhandahålls av iOS för att säkerställa att din information förblir privat och säker på din enhet.
            
            6. DINA RÄTTIGHETER
            Du har fullständig kontroll över dina data:
            - Alla data lagras lokalt på din enhet
            - Du kan rensa all betalningsdata när som helst via Inställningar
            - Du kan ta bort ditt konto och all associerad data via din Profil
            - Inga externa parter har tillgång till din information
            
            7. BARNENS INTEGRITET
            Vår App är inte avsedd för barn under 13 år. Eftersom vi inte samlar in några data samlar vi inte in personlig information från någon, inklusive barn.
            
            8. ÄNDRINGAR AV DENNA POLICY
            Vi kan uppdatera denna Integritetspolicy från tid till annan. Vi kommer att meddela dig om eventuella ändringar genom att publicera den nya Integritetspolicyn i Appen.
            
            9. KONTAKTA OSS
            Om du har några frågor om denna Integritetspolicy, vänligen kontakta oss via Appens supportsektion.
            """,
            "es": """
            POLÍTICA DE PRIVACIDAD
            
            Última actualización: 29 de noviembre de 2025
            
            En SitterPay, nos comprometemos a proteger su privacidad. Esta Política de Privacidad explica cómo manejamos su información cuando usa nuestra aplicación móvil.
            
            1. SIN RECOPILACIÓN DE DATOS
            SitterPay no recopila, transmite ni almacena ninguna de sus información personal en servidores externos. No recopilamos:
            - Análisis de uso
            - Información del dispositivo
            - Datos de ubicación
            - Cualquier otra información personal
            
            Toda la información que ingresa en la Aplicación permanece solo en su dispositivo.
            
            2. ALMACENAMIENTO LOCAL DE DATOS
            Todos sus datos se almacenan exclusivamente en su dispositivo utilizando métodos de almacenamiento local seguros. Esto incluye:
            - Información de cuenta (nombre, correo electrónico, contraseña)
            - Historial y cálculos de pagos
            - Datos de sesiones de cuidado de niños
            - Configuraciones y preferencias de la Aplicación
            
            Sus datos nunca salen de su dispositivo y no se transmiten a servidores externos o terceros.
            
            3. GESTIÓN DE DATOS
            Usted tiene control total sobre sus datos:
            - Borrar todos los datos: En Configuración, puede usar la opción "Borrar todos los datos" para eliminar toda la información e historial de pagos. Esta acción no se puede deshacer.
            - Eliminar cuenta: En su Perfil, puede eliminar su cuenta, lo que eliminará permanentemente:
              * Sus credenciales de inicio de sesión e información de cuenta
              * Todo el historial de pagos y datos asociados
            Esta acción es permanente y no se puede revertir.
            
            4. SIN COMPARTIR DATOS
            Como no recopilamos ningún dato, no compartimos y no podemos compartir su información con nadie. Su privacidad está completamente protegida porque sus datos nunca salen de su dispositivo.
            
            5. SEGURIDAD DE DATOS
            Sus datos están protegidos por las funciones de seguridad integradas de su dispositivo. Utilizamos métodos de almacenamiento local seguros proporcionados por iOS para garantizar que su información permanezca privada y segura en su dispositivo.
            
            6. SUS DERECHOS
            Usted tiene control completo sobre sus datos:
            - Todos los datos se almacenan localmente en su dispositivo
            - Puede borrar todos los datos de pago en cualquier momento a través de Configuración
            - Puede eliminar su cuenta y todos los datos asociados a través de su Perfil
            - Ninguna parte externa tiene acceso a su información
            
            7. PRIVACIDAD DE NIÑOS
            Nuestra Aplicación no está destinada a niños menores de 13 años. Como no recopilamos ningún dato, no recopilamos información personal de nadie, incluidos los niños.
            
            8. CAMBIOS A ESTA POLÍTICA
            Podemos actualizar esta Política de Privacidad de vez en cuando. Le notificaremos de cualquier cambio publicando la nueva Política de Privacidad en la Aplicación.
            
            9. CONTÁCTENOS
            Si tiene alguna pregunta sobre esta Política de Privacidad, por favor contáctenos a través de la sección de soporte de la Aplicación.
            """,
            "de": """
            DATENSCHUTZRICHTLINIE
            
            Zuletzt aktualisiert: 29. November 2025
            
            Bei SitterPay sind wir verpflichtet, Ihre Privatsphäre zu schützen. Diese Datenschutzrichtlinie erklärt, wie wir Ihre Informationen behandeln, wenn Sie unsere mobile Anwendung verwenden.
            
            1. KEINE DATENSAMMLUNG
            SitterPay sammelt, überträgt oder speichert keine Ihrer persönlichen Informationen auf externen Servern. Wir sammeln nicht:
            - Nutzungsanalysen
            - Geräteinformationen
            - Standortdaten
            - Andere personenbezogene Daten
            
            Alle Informationen, die Sie in die App eingeben, verbleiben nur auf Ihrem Gerät.
            
            2. LOKALE DATENSPEICHERUNG
            Alle Ihre Daten werden ausschließlich auf Ihrem Gerät mit sicheren lokalen Speichermethoden gespeichert. Dies umfasst:
            - Kontoinformationen (Name, E-Mail, Passwort)
            - Zahlungshistorie und Berechnungen
            - Babysitter-Sitzungsdaten
            - App-Einstellungen und Präferenzen
            
            Ihre Daten verlassen niemals Ihr Gerät und werden nicht an externe Server oder Dritte übertragen.
            
            3. DATENVERWALTUNG
            Sie haben vollständige Kontrolle über Ihre Daten:
            - Alle Daten löschen: In den Einstellungen können Sie die Option "Alle Daten löschen" verwenden, um alle Zahlungsinformationen und den Verlauf zu entfernen. Diese Aktion kann nicht rückgängig gemacht werden.
            - Konto löschen: In Ihrem Profil können Sie Ihr Konto löschen, wodurch dauerhaft entfernt werden:
              * Ihre Anmeldedaten und Kontoinformationen
              * Die gesamte Zahlungshistorie und zugehörige Daten
            Diese Aktion ist dauerhaft und kann nicht rückgängig gemacht werden.
            
            4. KEIN DATENAUSTAUSCH
            Da wir keine Daten sammeln, teilen wir Ihre Informationen nicht und können sie nicht mit jemandem teilen. Ihre Privatsphäre ist vollständig geschützt, da Ihre Daten niemals Ihr Gerät verlassen.
            
            5. DATENSICHERHEIT
            Ihre Daten sind durch die integrierten Sicherheitsfunktionen Ihres Geräts geschützt. Wir verwenden sichere lokale Speichermethoden, die von iOS bereitgestellt werden, um sicherzustellen, dass Ihre Informationen auf Ihrem Gerät privat und sicher bleiben.
            
            6. IHRE RECHTE
            Sie haben vollständige Kontrolle über Ihre Daten:
            - Alle Daten werden lokal auf Ihrem Gerät gespeichert
            - Sie können alle Zahlungsdaten jederzeit über die Einstellungen löschen
            - Sie können Ihr Konto und alle zugehörigen Daten über Ihr Profil löschen
            - Keine externen Parteien haben Zugriff auf Ihre Informationen
            
            7. DATENSCHUTZ FÜR KINDER
            Unsere App ist nicht für Kinder unter 13 Jahren bestimmt. Da wir keine Daten sammeln, sammeln wir keine persönlichen Informationen von niemandem, einschließlich Kindern.
            
            8. ÄNDERUNGEN DIESER RICHTLINIE
            Wir können diese Datenschutzrichtlinie von Zeit zu Zeit aktualisieren. Wir werden Sie über Änderungen informieren, indem wir die neue Datenschutzrichtlinie in der App veröffentlichen.
            
            9. KONTAKTIEREN SIE UNS
            Wenn Sie Fragen zu dieser Datenschutzrichtlinie haben, kontaktieren Sie uns bitte über den Support-Bereich der App.
            """
        ],
        "disclaimer_content": [
            "en": """
            DISCLAIMER
            
            Last Updated: November 29, 2025
            
            1. NO WARRANTY
            SitterPay is provided "as is" and "as available" without any warranties, express or implied. We do not guarantee that the App will be error-free, uninterrupted, or free from defects.
            
            2. ACCURACY OF CALCULATIONS
            While we strive to ensure accurate payment calculations, we cannot guarantee the accuracy of all calculations. Users are responsible for verifying payment amounts before making payments.
            
            3. LIMITATION OF LIABILITY
            To the fullest extent permitted by law, SitterPay shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, or use, arising out of or in connection with the use of the App.
            
            4. USER RESPONSIBILITY
            Users are solely responsible for:
            - The accuracy of information entered into the App
            - Verifying payment calculations
            - Making payments to babysitters
            - Maintaining the security of their account
            
            5. THIRD-PARTY SERVICES
            The App may contain links to third-party services. We are not responsible for the content, privacy policies, or practices of third-party services.
            
            6. CHANGES TO THE APP
            We reserve the right to modify, suspend, or discontinue the App at any time without prior notice. We shall not be liable to you or any third party for any modification, suspension, or discontinuance.
            
            7. NO PROFESSIONAL ADVICE
            The App is for informational and calculation purposes only. It does not constitute professional financial, legal, or tax advice. Users should consult with appropriate professionals for such advice.
            
            8. ACCEPTANCE
            By using SitterPay, you acknowledge that you have read, understood, and agree to this Disclaimer.
            """,
            "fr": """
            AVERTISSEMENT
            
            Dernière mise à jour : 29 novembre 2025
            
            1. AUCUNE GARANTIE
            SitterPay est fourni "tel quel" et "tel que disponible" sans aucune garantie, expresse ou implicite. Nous ne garantissons pas que l'Application sera exempte d'erreurs, ininterrompue ou sans défauts.
            
            2. EXACTITUDE DES CALCULS
            Bien que nous nous efforcions d'assurer des calculs de paiement précis, nous ne pouvons pas garantir l'exactitude de tous les calculs. Les utilisateurs sont responsables de vérifier les montants des paiements avant d'effectuer des paiements.
            
            3. LIMITATION DE RESPONSABILITÉ
            Dans la mesure maximale permise par la loi, SitterPay ne sera pas responsable de tout dommage indirect, accessoire, spécial, consécutif ou punitif, y compris mais sans s'y limiter, la perte de profits, de données ou d'utilisation, découlant de ou en relation avec l'utilisation de l'Application.
            
            4. RESPONSABILITÉ DE L'UTILISATEUR
            Les utilisateurs sont uniquement responsables de :
            - L'exactitude des informations saisies dans l'Application
            - La vérification des calculs de paiement
            - L'effectuation des paiements aux baby-sitters
            - Le maintien de la sécurité de leur compte
            
            5. SERVICES TIERS
            L'Application peut contenir des liens vers des services tiers. Nous ne sommes pas responsables du contenu, des politiques de confidentialité ou des pratiques des services tiers.
            
            6. MODIFICATIONS DE L'APPLICATION
            Nous nous réservons le droit de modifier, suspendre ou interrompre l'Application à tout moment sans préavis. Nous ne serons pas responsables envers vous ou tout tiers pour toute modification, suspension ou interruption.
            
            7. AUCUN CONSEIL PROFESSIONNEL
            L'Application est uniquement à des fins d'information et de calcul. Elle ne constitue pas un conseil professionnel financier, juridique ou fiscal. Les utilisateurs devraient consulter des professionnels appropriés pour de tels conseils.
            
            8. ACCEPTATION
            En utilisant SitterPay, vous reconnaissez avoir lu, compris et accepté cet Avertissement.
            """,
            "sv": """
            FRISKRIVNING
            
            Senast uppdaterad: 29 november 2025
            
            1. INGEN GARANTI
            SitterPay tillhandahålls "som det är" och "som tillgängligt" utan några garantier, uttryckliga eller underförstådda. Vi garanterar inte att Appen kommer att vara felfri, oavbruten eller felfri.
            
            2. BERÄKNINGARS NOGGRANNHET
            Även om vi strävar efter att säkerställa korrekta betalningsberäkningar, kan vi inte garantera noggrannheten i alla beräkningar. Användare är ansvariga för att verifiera betalningsbelopp innan de gör betalningar.
            
            3. BEGRÄNSNING AV ANSVAR
            I den största utsträckning som tillåts enligt lag ska SitterPay inte vara ansvarig för några indirekta, tillfälliga, särskilda, följdskador eller straffskador, inklusive men inte begränsat till förlust av vinster, data eller användning, som uppstår från eller i samband med användningen av Appen.
            
            4. ANVÄNDARANSVAR
            Användare är ensamt ansvariga för:
            - Noggrannheten i informationen som anges i Appen
            - Verifiering av betalningsberäkningar
            - Gör betalningar till barnvakter
            - Upprätthålla säkerheten för sitt konto
            
            5. TJÄNSTER FRÅN TREDJE PART
            Appen kan innehålla länkar till tjänster från tredje part. Vi är inte ansvariga för innehållet, integritetspolicyn eller praxis för tjänster från tredje part.
            
            6. ÄNDRINGAR I APPEN
            Vi förbehåller oss rätten att modifiera, suspendera eller avbryta Appen när som helst utan föregående meddelande. Vi ska inte vara ansvariga mot dig eller någon tredje part för någon modifiering, suspension eller avbrott.
            
            7. INGET PROFESSIONELLT RÅD
            Appen är endast för informations- och beräkningsändamål. Den utgör inte professionell finansiell, juridisk eller skatterådgivning. Användare bör konsultera lämpliga yrkesmän för sådana råd.
            
            8. ACCEPTERANDE
            Genom att använda SitterPay bekräftar du att du har läst, förstått och godkänner denna Friskrivning.
            """,
            "es": """
            DESCARGO DE RESPONSABILIDAD
            
            Última actualización: 29 de noviembre de 2025
            
            1. SIN GARANTÍA
            SitterPay se proporciona "tal cual" y "según disponibilidad" sin garantías de ningún tipo, expresas o implícitas. No garantizamos que la Aplicación esté libre de errores, sea ininterrumpida o libre de defectos.
            
            2. PRECISIÓN DE LOS CÁLCULOS
            Si bien nos esforzamos por garantizar cálculos de pago precisos, no podemos garantizar la precisión de todos los cálculos. Los usuarios son responsables de verificar los montos de pago antes de realizar pagos.
            
            3. LIMITACIÓN DE RESPONSABILIDAD
            En la medida máxima permitida por la ley, SitterPay no será responsable de ningún daño indirecto, incidental, especial, consecuente o punitivo, incluyendo pero no limitado a pérdida de ganancias, datos o uso, que surja de o en conexión con el uso de la Aplicación.
            
            4. RESPONSABILIDAD DEL USUARIO
            Los usuarios son únicamente responsables de:
            - La precisión de la información ingresada en la Aplicación
            - Verificar los cálculos de pago
            - Realizar pagos a niñeras
            - Mantener la seguridad de su cuenta
            
            5. SERVICIOS DE TERCEROS
            La Aplicación puede contener enlaces a servicios de terceros. No somos responsables del contenido, políticas de privacidad o prácticas de servicios de terceros.
            
            6. CAMBIOS A LA APLICACIÓN
            Nos reservamos el derecho de modificar, suspender o discontinuar la Aplicación en cualquier momento sin previo aviso. No seremos responsables ante usted o cualquier tercero por cualquier modificación, suspensión o discontinuación.
            
            7. SIN ASESORAMIENTO PROFESIONAL
            La Aplicación es solo para fines informativos y de cálculo. No constituye asesoramiento financiero, legal o fiscal profesional. Los usuarios deben consultar con profesionales apropiados para dicho asesoramiento.
            
            8. ACEPTACIÓN
            Al usar SitterPay, reconoce que ha leído, entendido y acepta este Descargo de Responsabilidad.
            """,
            "de": """
            HAFTUNGSAUSSCHLUSS
            
            Zuletzt aktualisiert: 29. November 2025
            
            1. KEINE GEWÄHRLEISTUNG
            SitterPay wird "wie besehen" und "wie verfügbar" ohne jegliche Gewährleistungen, ausdrücklich oder stillschweigend, bereitgestellt. Wir garantieren nicht, dass die App fehlerfrei, ununterbrochen oder fehlerfrei ist.
            
            2. GENAUIGKEIT DER BERECHNUNGEN
            Während wir uns bemühen, genaue Zahlungsberechnungen sicherzustellen, können wir die Genauigkeit aller Berechnungen nicht garantieren. Benutzer sind dafür verantwortlich, Zahlungsbeträge vor der Zahlung zu überprüfen.
            
            3. HAFTUNGSBESCHRÄNKUNG
            In vollem Umfang, wie es gesetzlich zulässig ist, haftet SitterPay nicht für indirekte, zufällige, besondere, Folge- oder Strafschäden, einschließlich, aber nicht beschränkt auf Verlust von Gewinnen, Daten oder Nutzung, die sich aus oder in Verbindung mit der Nutzung der App ergeben.
            
            4. BENUTZERVERANTWORTUNG
            Benutzer sind allein verantwortlich für:
            - Die Genauigkeit der in die App eingegebenen Informationen
            - Überprüfung der Zahlungsberechnungen
            - Zahlungen an Babysitter
            - Aufrechterhaltung der Sicherheit ihres Kontos
            
            5. DIENSTE DRITTER
            Die App kann Links zu Diensten Dritter enthalten. Wir sind nicht verantwortlich für den Inhalt, die Datenschutzrichtlinien oder Praktiken von Diensten Dritter.
            
            6. ÄNDERUNGEN AN DER APP
            Wir behalten uns das Recht vor, die App jederzeit ohne vorherige Ankündigung zu ändern, auszusetzen oder einzustellen. Wir haften nicht gegenüber Ihnen oder Dritten für Änderungen, Aussetzung oder Einstellung.
            
            7. KEINE PROFESSIONELLE BERATUNG
            Die App dient nur zu Informations- und Berechnungszwecken. Sie stellt keine professionelle finanzielle, rechtliche oder steuerliche Beratung dar. Benutzer sollten sich für solche Beratung an geeignete Fachleute wenden.
            
            8. ANNAHME
            Durch die Nutzung von SitterPay bestätigen Sie, dass Sie diesen Haftungsausschluss gelesen, verstanden und akzeptiert haben.
            """
        ],
        "close": [
            "en": "Close",
            "fr": "Fermer",
            "sv": "Stäng",
            "es": "Cerrar",
            "de": "Schließen"
        ],
        "your_full_name": [
            "en": "Your Full Name",
            "fr": "Votre nom complet",
            "sv": "Ditt fullständiga namn",
            "es": "Tu nombre completo",
            "de": "Ihr vollständiger Name"
        ],
        "full_name": [
            "en": "Full Name",
            "fr": "Nom complet",
            "sv": "Fullständigt namn",
            "es": "Nombre completo",
            "de": "Vollständiger Name"
        ],
        "your_email": [
            "en": "Your Email",
            "fr": "Votre e-mail",
            "sv": "Din e-post",
            "es": "Tu correo electrónico",
            "de": "Ihre E-Mail"
        ],
        "subject": [
            "en": "Subject",
            "fr": "Sujet",
            "sv": "Ämne",
            "es": "Asunto",
            "de": "Betreff"
        ],
        "description": [
            "en": "Description",
            "fr": "Description",
            "sv": "Beskrivning",
            "es": "Descripción",
            "de": "Beschreibung"
        ],
        "all_fields_required": [
            "en": "All fields are required",
            "fr": "Tous les champs sont requis",
            "sv": "Alla fält är obligatoriska",
            "es": "Todos los campos son obligatorios",
            "de": "Alle Felder sind erforderlich"
        ],
        "send": [
            "en": "Send",
            "fr": "Envoyer",
            "sv": "Skicka",
            "es": "Enviar",
            "de": "Senden"
        ],
        "contact_us": [
            "en": "Contact Us",
            "fr": "Contactez-nous",
            "sv": "Kontakta oss",
            "es": "Contáctanos",
            "de": "Kontaktieren Sie uns"
        ],
        "wed_love_to_hear_from_you": [
            "en": "We'd love to hear from you!",
            "fr": "Nous aimerions avoir de vos nouvelles !",
            "sv": "Vi skulle gärna höra från dig!",
            "es": "¡Nos encantaría saber de ti!",
            "de": "Wir würden gerne von Ihnen hören!"
        ],
        "whether_you_have_questions": [
            "en": "Whether you have questions,",
            "fr": "Que vous ayez des questions,",
            "sv": "Oavsett om du har frågor,",
            "es": "Ya sea que tengas preguntas,",
            "de": "Ob Sie Fragen haben,"
        ],
        "feedback_or_just_want_to_say_hi": [
            "en": "feedback, or just want to say hi,",
            "fr": "des commentaires, ou que vous souhaitiez simplement dire bonjour,",
            "sv": "feedback eller bara vill säga hej,",
            "es": "comentarios, o simplemente quieras saludar,",
            "de": "Feedback haben oder einfach nur Hallo sagen möchten,"
        ],
        "feel_free_to_reach_out": [
            "en": "feel free to reach out!",
            "fr": "n'hésitez pas à nous contacter !",
            "sv": "tveka inte att höra av dig!",
            "es": "¡no dudes en contactarnos!",
            "de": "zögern Sie nicht, uns zu kontaktieren!"
        ],
        "email_contact": [
            "en": "abashelariprod@gmail.com",
            "fr": "abashelariprod@gmail.com",
            "sv": "abashelariprod@gmail.com",
            "es": "abashelariprod@gmail.com",
            "de": "abashelariprod@gmail.com"
        ],
        "website_contact": [
            "en": "https://abashelariprod.wordpress.com/",
            "fr": "https://abashelariprod.wordpress.com/",
            "sv": "https://abashelariprod.wordpress.com/",
            "es": "https://abashelariprod.wordpress.com/",
            "de": "https://abashelariprod.wordpress.com/"
        ],
        "or": [
            "en": "OR",
            "fr": "OU",
            "sv": "ELLER",
            "es": "O",
            "de": "ODER"
        ],
        "contact_form": [
            "en": "Contact Form",
            "fr": "Formulaire de contact",
            "sv": "Kontaktformulär",
            "es": "Formulario de contacto",
            "de": "Kontaktformular"
        ],
        "we_aim_to_respond_within_24_hours": [
            "en": "We aim to respond within 24 hours",
            "fr": "Nous visons à répondre dans les 24 heures",
            "sv": "Vi strävar efter att svara inom 24 timmar",
            "es": "Nuestro objetivo es responder en 24 horas",
            "de": "Wir bemühen uns, innerhalb von 24 Stunden zu antworten"
        ],
        "message_sent": [
            "en": "Message Sent",
            "fr": "Message envoyé",
            "sv": "Meddelande skickat",
            "es": "Mensaje enviado",
            "de": "Nachricht gesendet"
        ],
        "thanks_for_reaching_out": [
            "en": "Thanks for reaching out! We'll get back to you soon.",
            "fr": "Merci de nous avoir contactés ! Nous vous répondrons bientôt.",
            "sv": "Tack för att du hör av dig! Vi återkommer snart.",
            "es": "¡Gracias por contactarnos! Te responderemos pronto.",
            "de": "Vielen Dank für Ihre Kontaktaufnahme! Wir werden uns bald bei Ihnen melden."
        ],
        "call_support": [
            "en": "Call Support",
            "fr": "Appeler le support",
            "sv": "Ringa support",
            "es": "Llamar al soporte",
            "de": "Support anrufen"
        ],
        "do_you_want_to_call": [
            "en": "Do you want to call {phone}?",
            "fr": "Voulez-vous appeler {phone} ?",
            "sv": "Vill du ringa {phone}?",
            "es": "¿Quieres llamar a {phone}?",
            "de": "Möchten Sie {phone} anrufen?"
        ],
        "do_you_want_to_call_name": [
            "en": "Do you want to call %@",
            "fr": "Voulez-vous appeler %@",
            "sv": "Vill du ringa %@",
            "es": "¿Quieres llamar a %@",
            "de": "Möchten Sie %@ anrufen"
        ],
        "no": [
            "en": "No",
            "fr": "Non",
            "sv": "Nej",
            "es": "No",
            "de": "Nein"
        ],
        "notify_me": [
            "en": "Notify me",
            "fr": "Me notifier",
            "sv": "Meddela mig",
            "es": "Notificarme",
            "de": "Benachrichtigen"
        ],
        "do_you_want_to_start_live_session_with": [
            "en": "Do you want to start live session with %@?",
            "fr": "Voulez-vous démarrer une session en direct avec %@?",
            "sv": "Vill du starta en live-session med %@?",
            "es": "¿Quieres iniciar una sesión en vivo con %@?",
            "de": "Möchten Sie eine Live-Sitzung mit %@ starten?"
        ],
        "clear_all_history_message": [
            "en": "This will delete all payment history and cannot be undone.",
            "fr": "Cela supprimera tout l'historique des paiements et ne peut pas être annulé.",
            "sv": "Detta kommer att ta bort all betalningshistorik och kan inte ångras.",
            "es": "Esto eliminará todo el historial de pagos y no se puede deshacer.",
            "de": "Dies löscht den gesamten Zahlungsverlauf und kann nicht rückgängig gemacht werden."
        ],
        "clear_history": [
            "en": "Clear History",
            "fr": "Effacer l'historique",
            "sv": "Rensa historik",
            "es": "Limpiar historial",
            "de": "Verlauf löschen"
        ],
        "delete_all_payment_history": [
            "en": "Delete all payment history",
            "fr": "Supprimer tout l'historique des paiements",
            "sv": "Ta bort all betalningshistorik",
            "es": "Eliminar todo el historial de pagos",
            "de": "Gesamten Zahlungsverlauf löschen"
        ],
        "about_sitterpay_title": [
            "en": "About SitterPay",
            "fr": "À propos de SitterPay",
            "sv": "Om SitterPay",
            "es": "Acerca de SitterPay",
            "de": "Über SitterPay"
        ],
        "about_sitterpay_content": [
            "en": "SitterPay is a comprehensive babysitting payment calculator designed to help you track and manage payments for babysitting services with ease. Calculate payments in real-time, save payment history, and manage multiple babysitting sessions. Get accurate payment calculations and never miss a payment detail again.",
            "fr": "SitterPay est un calculateur de paiement de garde d'enfants complet conçu pour vous aider à suivre et gérer les paiements pour les services de garde d'enfants en toute simplicité. Calculez les paiements en temps réel, enregistrez l'historique des paiements et gérez plusieurs sessions de garde d'enfants. Obtenez des calculs de paiement précis et ne manquez plus jamais un détail de paiement.",
            "sv": "SitterPay är en omfattande betalningskalkylator för barnpassning som är designad för att hjälpa dig spåra och hantera betalningar för barnpassningstjänster med lätthet. Beräkna betalningar i realtid, spara betalningshistorik och hantera flera barnpassningssessioner. Få noggranna betalningsberäkningar och missa aldrig en betalningsdetalj igen.",
            "es": "SitterPay es una calculadora integral de pagos para cuidado de niños diseñada para ayudarte a rastrear y gestionar los pagos de servicios de cuidado de niños con facilidad. Calcula pagos en tiempo real, guarda el historial de pagos y gestiona múltiples sesiones de cuidado de niños. Obtén cálculos de pago precisos y nunca más te pierdas un detalle de pago.",
            "de": "SitterPay ist ein umfassender Babysitting-Zahlungsrechner, der entwickelt wurde, um Ihnen zu helfen, Zahlungen für Babysitting-Dienste mühelos zu verfolgen und zu verwalten. Berechnen Sie Zahlungen in Echtzeit, speichern Sie Zahlungshistorien und verwalten Sie mehrere Babysitting-Sitzungen. Erhalten Sie genaue Zahlungsberechnungen und verpassen Sie nie wieder ein Zahlungsdetail."
        ],
        "from_contacts": [
            "en": "From Contacts",
            "fr": "Depuis les contacts",
            "sv": "Från kontakter",
            "es": "Desde contactos",
            "de": "Aus Kontakten"
        ],
        "hi_name_available_babysitting": [
            "en": "Hi %@, are you available for babysitting on %@ at %@? Please let us know. Thanks! 😊",
            "fr": "Salut %@, es-tu disponible pour garder les enfants le %@ à %@ ? Fais-nous savoir. Merci ! 😊",
            "sv": "Hej %@, är du tillgänglig för barnpassning den %@ kl %@? Låt oss veta. Tack! 😊",
            "es": "¡Hola %@, estás disponible para cuidar niños el %@ a las %@? Por favor, avísanos. ¡Gracias! 😊",
            "de": "Hallo %@, bist du am %@ um %@ für Babysitting verfügbar? Bitte lass uns wissen. Danke! 😊"
        ],
        "about_abashelari_title": [
            "en": "About ABASHELARI",
            "fr": "À propos d'ABASHELARI",
            "sv": "Om ABASHELARI",
            "es": "Acerca de ABASHELARI",
            "de": "Über ABASHELARI"
        ],
        "about_abashelari_content": [
            "en": "At ABASHELARI, we believe in creating software that makes everyday life simpler, smarter, and more enjoyable. Our mission is to develop innovative digital solutions that blend creativity with technology, offering users tools that are intuitive, reliable, and engaging.\n\nWhether it's educational apps, lifestyle tools, or entertainment experiences, ABASHELARI is dedicated to delivering high-quality products that inspire learning, spark curiosity, and bring value to people around the world.\n\nDriven by passion and guided by innovation, ABASHELARI is committed to continuous improvement and to building software that connects people with what matters most.",
            "fr": "Chez ABASHELARI, nous croyons en la création de logiciels qui rendent la vie quotidienne plus simple, plus intelligente et plus agréable. Notre mission est de développer des solutions numériques innovantes qui allient créativité et technologie, offrant aux utilisateurs des outils intuitifs, fiables et engageants.\n\nQu'il s'agisse d'applications éducatives, d'outils de style de vie ou d'expériences de divertissement, ABASHELARI s'engage à fournir des produits de haute qualité qui inspirent l'apprentissage, suscitent la curiosité et apportent de la valeur aux personnes du monde entier.\n\nAnimés par la passion et guidés par l'innovation, ABASHELARI s'engage à améliorer continuellement et à construire des logiciels qui connectent les gens avec ce qui compte le plus.",
            "sv": "På ABASHELARI tror vi på att skapa programvara som gör vardagen enklare, smartare och roligare. Vårt uppdrag är att utveckla innovativa digitala lösningar som kombinerar kreativitet med teknik, och erbjuder användare verktyg som är intuitiva, pålitliga och engagerande.\n\nOavsett om det är utbildningsappar, livsstilsverktyg eller underhållningsupplevelser, är ABASHELARI dedikerad till att leverera högkvalitativa produkter som inspirerar lärande, väcker nyfikenhet och ger värde till människor över hela världen.\n\nDrivna av passion och vägledda av innovation, är ABASHELARI engagerade i kontinuerlig förbättring och att bygga programvara som kopplar samman människor med det som betyder mest.",
            "es": "En ABASHELARI, creemos en crear software que hace la vida cotidiana más simple, inteligente y agradable. Nuestra misión es desarrollar soluciones digitales innovadoras que combinen creatividad con tecnología, ofreciendo a los usuarios herramientas que sean intuitivas, confiables y atractivas.\n\nYa sean aplicaciones educativas, herramientas de estilo de vida o experiencias de entretenimiento, ABASHELARI se dedica a entregar productos de alta calidad que inspiren el aprendizaje, despierten la curiosidad y aporten valor a las personas de todo el mundo.\n\nImpulsados por la pasión y guiados por la innovación, ABASHELARI está comprometido con la mejora continua y con la construcción de software que conecte a las personas con lo que más importa.",
            "de": "Bei ABASHELARI glauben wir daran, Software zu erstellen, die das tägliche Leben einfacher, intelligenter und angenehmer macht. Unsere Mission ist es, innovative digitale Lösungen zu entwickeln, die Kreativität mit Technologie verbinden und Benutzern Tools bieten, die intuitiv, zuverlässig und ansprechend sind.\n\nOb es sich um Bildungs-Apps, Lifestyle-Tools oder Unterhaltungserlebnisse handelt, ABASHELARI ist bestrebt, hochwertige Produkte zu liefern, die zum Lernen inspirieren, Neugier wecken und Menschen auf der ganzen Welt einen Mehrwert bieten.\n\nAngetrieben von Leidenschaft und geleitet von Innovation ist ABASHELARI kontinuierlicher Verbesserung verpflichtet und baut Software, die Menschen mit dem verbindet, was am wichtigsten ist."
        ],
        "this_is_the_first_time_for": [
            "en": "This is the first time for %@",
            "fr": "C'est la première fois pour %@",
            "sv": "Detta är första gången för %@",
            "es": "Esta es la primera vez para %@",
            "de": "Dies ist das erste Mal für %@"
        ],
        "babysitter_worked_times_this_month": [
            "en": "%@ worked %d times this month",
            "fr": "%@ a travaillé %d fois ce mois-ci",
            "sv": "%@ arbetade %d gånger denna månad",
            "es": "%@ trabajó %d veces este mes",
            "de": "%@ hat %d Mal diesen Monat gearbeitet"
        ],
        "babysitter_earned_till_now": [
            "en": "%@ earned %@%@ till now",
            "fr": "%@ a gagné %@%@ jusqu'à présent",
            "sv": "%@ har tjänat %@%@ hittills",
            "es": "%@ ha ganado %@%@ hasta ahora",
            "de": "%@ hat bisher %@%@ verdient"
        ],
        "select_babysitter_to_start": [
            "en": "Select babysitter to start",
            "fr": "Sélectionnez une baby-sitter pour commencer",
            "sv": "Välj barnvakt för att börja",
            "es": "Selecciona niñera para comenzar",
            "de": "Babysitter auswählen, um zu beginnen"
        ],
        "babysitter_hourly_pay": [
            "en": "%@ hourly pay is %@%@",
            "fr": "Le salaire horaire de %@ est de %@%@",
            "sv": "%@ timlön är %@%@",
            "es": "El pago por hora de %@ es %@%@",
            "de": "%@ Stundenlohn beträgt %@%@"
        ],
        "babysitter_hourly_pay_with_extras": [
            "en": "%@ hourly pay is %@%@ + %@%@ extra",
            "fr": "Le salaire horaire de %@ est de %@%@ + %@%@ supplémentaire",
            "sv": "%@ timlön är %@%@ + %@%@ extra",
            "es": "El pago por hora de %@ es %@%@ + %@%@ extra",
            "de": "%@ Stundenlohn beträgt %@%@ + %@%@ extra"
        ]
    ]
    
    func getString(for key: String, language: String) -> String {
        guard let languageDict = translations[key],
              let translation = languageDict[language] else {
            // Fallback to English if translation not found
            return translations[key]?["en"] ?? key
        }
        return translation
    }
}

// Convenience extension for easy access
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
}

