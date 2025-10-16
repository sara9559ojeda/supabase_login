# TODO: Update Gemini Service Model and Improve Prompts

- [x] Change the model in GeminiService from 'gemini-1.5-flash' to 'gemini-2.5-flash-lite'
- [x] Improve the summary prompt for better summarization results
- [x] Improve the writing improvement prompt for better rewriting results

# TODO: Integrate Supabase Authentication and Storage

- [x] Add Supabase dependencies to pubspec.yaml
- [x] Create SupabaseService for authentication and storage operations
- [x] Create AuthProvider for state management
- [x] Create AuthScreen for login/signup
- [x] Update main.dart to use Provider and authentication flow
- [x] Create ExportService for PDF/TXT generation and Supabase upload
- [x] Update HistoryService to save to Supabase instead of local storage
- [x] Update screens to use authentication and export functionality
- [x] Create FilesScreen to view and manage exported files
- [x] Improve UI/UX across all screens with better styling and empty states
- [x] Test the complete integration
