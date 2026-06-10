import AVFoundation
import PhotosUI
import SwiftUI
import UIKit
import Vision

let mandatoryMedicalNotice = "Cette application ne fournit aucun diagnostic médical. Les résultats sont uniquement informatifs. En cas de symptôme, douleur ou doute, consultez un professionnel de santé qualifié."

enum PrudenceLevel: String, Codable, CaseIterable {
    case faible
    case moyen
    case eleve

    var title: String {
        switch self {
        case .faible: "Faible"
        case .moyen: "Moyen"
        case .eleve: "Élevé"
        }
    }

    var tint: Color {
        switch self {
        case .faible: .green
        case .moyen: .orange
        case .eleve: .red
        }
    }
}

struct AnalysisResult: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let prudence: PrudenceLevel
    let summary: String
    let generalExplanation: String
    let recommendedAction: String
    let observations: [String]
    let rawProviderText: String

    static let empty = AnalysisResult(
        id: UUID(),
        date: .now,
        prudence: .moyen,
        summary: "Analyse non disponible",
        generalExplanation: "Aucun résultat réel n'a encore été reçu de l'API IA.",
        recommendedAction: "Configurez une clé API valide dans Réglages.",
        observations: [],
        rawProviderText: ""
    )
}

@MainActor
final class AppState: ObservableObject {
    @Published var latestResult: AnalysisResult?
    @Published var history: [AnalysisResult] = []
    @Published var isAnalyzing = false
    @Published var errorMessage: String?

    @AppStorage("openAIAPIKey") var apiKey = ""
    @AppStorage("openAIModel") var model = "gpt-5.5"
    @AppStorage("realtimeAnalysisEnabled") var realtimeAnalysisEnabled = true

    private let historyKey = "analysisHistory"

    init() {
        loadHistory()
    }

    func analyze(image: UIImage) async {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Ajoutez une clé API OpenAI valide dans Réglages pour lancer une analyse réelle."
            return
        }

        isAnalyzing = true
        errorMessage = nil

        do {
            let result = try await OpenAIVisionService(
                apiKey: apiKey.trimmingCharacters(in: .whitespacesAndNewlines),
                model: model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "gpt-5.5" : model
            ).analyze(image: image)
            latestResult = result
            history.insert(result, at: 0)
            saveHistory()
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    func clearHistory() {
        history.removeAll()
        latestResult = nil
        UserDefaults.standard.removeObject(forKey: historyKey)
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let decoded = try? JSONDecoder().decode([AnalysisResult].self, from: data) else { return }
        history = decoded
        latestResult = decoded.first
    }

    private func saveHistory() {
        let trimmed = Array(history.prefix(60))
        history = trimmed
        guard let data = try? JSONEncoder().encode(trimmed) else { return }
        UserDefaults.standard.set(data, forKey: historyKey)
    }
}

struct RootView: View {
    @Binding var hasCompletedOnboarding: Bool
    @StateObject private var appState = AppState()

    var body: some View {
        ZStack(alignment: .bottom) {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(appState)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                OnboardingView {
                    withAnimation(.smooth(duration: 0.7)) {
                        hasCompletedOnboarding = true
                    }
                }
            }

            SafetyNoticeBar()
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
        }
        .animation(.smooth(duration: 0.55), value: hasCompletedOnboarding)
    }
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView {
            CameraAnalysisView()
                .tabItem { Label("Analyse", systemImage: "viewfinder") }

            HistoryView()
                .tabItem { Label("Historique", systemImage: "clock") }

            SettingsView()
                .tabItem { Label("Réglages", systemImage: "slider.horizontal.3") }
        }
        .tint(.primary)
    }
}

struct PremiumBackdrop: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemGroupedBackground),
                Color(.systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct GlassIconButton: View {
    let icon: String
    var tint: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
                .shadow(color: .black.opacity(0.16), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
    }
}

struct StatusPill: View {
    let text: String
    let icon: String
    var tint: Color = .green

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(tint.opacity(0.16), in: Capsule())
            .foregroundStyle(tint)
    }
}

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            PremiumBackdrop()

            VStack(alignment: .leading, spacing: 24) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 104, height: 104)
                        .overlay(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .stroke(.white.opacity(0.35), lineWidth: 1)
                        )

                    Image(systemName: "camera.metering.matrix")
                        .font(.system(size: 46, weight: .light))
                        .symbolRenderingMode(.hierarchical)
                }
                .shadow(color: .black.opacity(0.14), radius: 30, y: 18)

                VStack(alignment: .leading, spacing: 12) {
                    Text("MyApp")
                        .font(.system(size: 58, weight: .semibold))
                    Text("Analyse visuelle connectée, prudente et structurée.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 12) {
                    PremiumFeatureRow(icon: "camera.aperture", title: "Caméra avant et arrière", subtitle: "Capture photo, vidéo courte et flux en direct.")
                    PremiumFeatureRow(icon: "brain.head.profile", title: "IA cloud réelle", subtitle: "Connexion API Vision externe, sans résultat simulé.")
                    PremiumFeatureRow(icon: "shield.lefthalf.filled", title: "Prudence intégrée", subtitle: "Informations générales, jamais de diagnostic médical.")
                }

                Button(action: onComplete) {
                    HStack {
                        Text("Commencer")
                        .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 17)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [.primary, .primary.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
                    .shadow(color: .black.opacity(0.22), radius: 24, y: 14)
                }
                .buttonStyle(.plain)

                Spacer()
                    .frame(height: 72)
            }
            .padding(24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.8)) {
                appeared = true
            }
        }
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 42, height: 42)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.24), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }
}

struct CameraAnalysisView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var camera = CameraModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var capturePulse = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                CameraPreview(session: camera.session)
                    .ignoresSafeArea()
                    .overlay(CameraGradient())

                VStack(spacing: 14) {
                    topGlassBar
                    Spacer()
                    ResultPanel(result: appState.latestResult, isLoading: appState.isAnalyzing, error: appState.errorMessage)
                        .animation(.smooth(duration: 0.45), value: appState.latestResult)
                        .animation(.smooth(duration: 0.30), value: appState.isAnalyzing)
                    controls
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 74)
            }
            .navigationTitle("Analyse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await camera.configure()
                camera.onFrame = { image in
                    guard appState.realtimeAnalysisEnabled, !appState.isAnalyzing else { return }
                    Task { await appState.analyze(image: image) }
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    guard let data = try? await newItem?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    await appState.analyze(image: image)
                }
            }
        }
    }

    private var topGlassBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("MyApp Vision")
                    .font(.headline.weight(.semibold))
                Text(appState.realtimeAnalysisEnabled ? "Temps réel actif" : "Analyse à la capture")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusPill(
                text: appState.realtimeAnalysisEnabled ? "Live" : "Manuel",
                icon: appState.realtimeAnalysisEnabled ? "dot.radiowaves.left.and.right" : "hand.tap",
                tint: appState.realtimeAnalysisEnabled ? .green : .secondary
            )
            GlassIconButton(icon: "arrow.triangle.2.circlepath.camera") {
                withAnimation(.smooth(duration: 0.35)) { camera.switchCamera() }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 22, y: 12)
        .padding(.top, 54)
    }

    private var controls: some View {
        HStack(spacing: 18) {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 21, weight: .semibold))
                    .frame(width: 58, height: 58)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.24), lineWidth: 1))
            }

            Button {
                withAnimation(.smooth(duration: 0.22)) {
                    capturePulse.toggle()
                }
                Task {
                    if let image = await camera.capturePhoto() {
                        await appState.analyze(image: image)
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.24))
                    Circle()
                        .strokeBorder(.white.opacity(0.95), lineWidth: 4)
                        .padding(4)
                    Circle()
                        .fill(.white.opacity(appState.isAnalyzing ? 0.36 : 0.90))
                        .frame(width: 50, height: 50)
                        .scaleEffect(capturePulse ? 0.92 : 1)
                }
                .frame(width: 82, height: 82)
                .shadow(color: .black.opacity(0.28), radius: 22, y: 12)
            }
            .disabled(appState.isAnalyzing)

            Button {
                camera.toggleRecording()
            } label: {
                Image(systemName: camera.isRecording ? "stop.fill" : "video.fill")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(camera.isRecording ? .red : .primary)
                    .frame(width: 58, height: 58)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.24), lineWidth: 1))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.22), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
    }
}

struct CameraGradient: View {
    var body: some View {
        LinearGradient(
            colors: [.black.opacity(0.42), .clear, .black.opacity(0.56)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct ResultPanel: View {
    let result: AnalysisResult?
    let isLoading: Bool
    let error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Résultat IA", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                if isLoading {
                    ProgressView()
                } else if let level = result?.prudence {
                    Text(level.title)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(level.tint.opacity(0.18), in: Capsule())
                        .foregroundStyle(level.tint)
                }
            }

            if let error {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.red)
            } else if let result {
                PrudenceMeter(level: result.prudence)

                Text(result.summary)
                    .font(.title3.weight(.semibold))
                Text(result.generalExplanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                if !result.observations.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(result.observations.prefix(3), id: \.self) { observation in
                            Label(observation, systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 2)
                }
                Text(result.recommendedAction)
                    .font(.footnote.weight(.medium))
                    .padding(.top, 2)
            } else {
                Text("Cadrez une image, puis lancez une analyse réelle via l'API configurée.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 28, y: 14)
    }
}

struct PrudenceMeter: View {
    let level: PrudenceLevel

    private var index: Int {
        switch level {
        case .faible: 0
        case .moyen: 1
        case .eleve: 2
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Niveau de prudence")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(level.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(level.tint)
            }

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { value in
                    Capsule()
                        .fill(value <= index ? level.tint : Color.secondary.opacity(0.16))
                        .frame(height: 8)
                }
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                ForEach(appState.history) { item in
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            Text(item.summary)
                                .font(.headline)
                            Spacer()
                            Text(item.prudence.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(item.prudence.tint)
                        }
                        Text(item.generalExplanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(item.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(16)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(.white.opacity(0.20), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(PremiumBackdrop())
            .overlay {
                if appState.history.isEmpty {
                    ContentUnavailableView("Aucune analyse", systemImage: "clock", description: Text("Les résultats réels de l'API apparaîtront ici."))
                }
            }
            .navigationTitle("Historique")
            .toolbar {
                Button("Effacer", role: .destructive) { appState.clearHistory() }
                    .disabled(appState.history.isEmpty)
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: appState.apiKey.isEmpty ? "key.slash" : "key.radiowaves.forward")
                            .font(.title2)
                            .frame(width: 46, height: 46)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(appState.apiKey.isEmpty ? "API non configurée" : "API prête")
                                .font(.headline)
                            Text(appState.apiKey.isEmpty ? "Aucune analyse réelle ne démarre sans clé valide." : "Les images sont envoyées au fournisseur IA configuré.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("API IA réelle") {
                    SecureField("Clé API OpenAI", text: $appState.apiKey)
                        .textContentType(.password)
                    TextField("Modèle", text: $appState.model)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Toggle("Analyse temps réel", isOn: $appState.realtimeAnalysisEnabled)
                }

                Section("Sécurité") {
                    Text(mandatoryMedicalNotice)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(PremiumBackdrop())
            .navigationTitle("Réglages")
        }
    }
}

struct SafetyNoticeBar: View {
    var body: some View {
        Text(mandatoryMedicalNotice)
            .font(.caption2.weight(.medium))
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.10), radius: 12, y: 5)
            .accessibilityLabel(mandatoryMedicalNotice)
    }
}

final class CameraModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    @Published var isRecording = false
    var onFrame: ((UIImage) -> Void)?

    private let sessionQueue = DispatchQueue(label: "myapp.camera.session")
    private let output = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var currentPosition: AVCaptureDevice.Position = .back
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?
    private var lastFrameAnalysis = Date.distantPast

    func configure() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        guard granted else { return }

        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .high
            self.session.inputs.forEach { self.session.removeInput($0) }

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.currentPosition),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)

            if self.session.canAddOutput(self.output) { self.session.addOutput(self.output) }
            if self.session.canAddOutput(self.movieOutput) { self.session.addOutput(self.movieOutput) }
            if self.session.canAddOutput(self.videoOutput) {
                self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "myapp.camera.frames"))
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.session.addOutput(self.videoOutput)
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func switchCamera() {
        currentPosition = currentPosition == .back ? .front : .back
        Task { await configure() }
    }

    func capturePhoto() async -> UIImage? {
        await withCheckedContinuation { continuation in
            photoContinuation = continuation
            let settings = AVCapturePhotoSettings()
            output.capturePhoto(with: settings, delegate: self)
        }
    }

    func toggleRecording() {
        if movieOutput.isRecording {
            movieOutput.stopRecording()
            isRecording = false
        } else {
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("MyApp-\(UUID().uuidString).mov")
            movieOutput.startRecording(to: url, recordingDelegate: self)
            isRecording = true
        }
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let image = photo.fileDataRepresentation().flatMap(UIImage.init(data:))
        Task { @MainActor in
            self.photoContinuation?.resume(returning: image)
            self.photoContinuation = nil
        }
    }
}

extension CameraModel: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        Task { @MainActor in self.isRecording = false }
    }
}

extension CameraModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        Task { @MainActor in
            guard Date().timeIntervalSince(self.lastFrameAnalysis) > 8 else { return }
            self.lastFrameAnalysis = Date()
            guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
            self.onFrame?(image)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

struct OpenAIVisionService {
    let apiKey: String
    let model: String

    func analyze(image: UIImage) async throws -> AnalysisResult {
        try await ImageSafetyPreflight.validate(image: image)

        guard let resized = image.resized(maxDimension: 1280),
              let jpegData = resized.jpegData(compressionQuality: 0.78) else {
            throw AppError("Impossible de préparer l'image pour l'analyse.")
        }

        let prompt = """
        Analyse cette image de manière strictement non médicale et prudente.
        Ne fournis jamais de diagnostic, certitude médicale, identification de maladie ou consigne de traitement.
        Retourne uniquement un JSON valide avec les clés:
        prudence: "faible", "moyen" ou "eleve";
        summary: une phrase courte;
        generalExplanation: explication générale prudente;
        recommendedAction: recommandation générale invitant à consulter si symptôme, douleur ou doute;
        observations: tableau de 2 à 5 observations visuelles générales.
        Ajoute explicitement que l'analyse est informative et non médicale.
        """

        let payload = OpenAIResponsesRequest(
            model: model,
            input: [
                .init(role: "user", content: [
                    .text(prompt),
                    .image("data:image/jpeg;base64,\(jpegData.base64EncodedString())")
                ])
            ]
        )

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        request.timeoutInterval = 45

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw AppError("Réponse API invalide.") }
        guard (200...299).contains(http.statusCode) else {
            let providerError = String(data: data, encoding: .utf8) ?? "Erreur inconnue"
            throw AppError("Erreur API OpenAI \(http.statusCode): \(providerError)")
        }

        let decoded = try JSONDecoder().decode(OpenAIResponsesResponse.self, from: data)
        let text = decoded.outputText
        let structured = try Self.parseProviderJSON(text)

        return AnalysisResult(
            id: UUID(),
            date: .now,
            prudence: structured.prudenceLevel,
            summary: structured.summary,
            generalExplanation: structured.generalExplanation,
            recommendedAction: structured.recommendedAction,
            observations: structured.observations,
            rawProviderText: text
        )
    }

    private static func parseProviderJSON(_ text: String) throws -> ProviderAnalysis {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else { throw AppError("Réponse IA illisible.") }
        return try JSONDecoder().decode(ProviderAnalysis.self, from: data)
    }
}

enum OpenAIContent: Encodable {
    case text(String)
    case image(String)

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let value):
            try container.encode("input_text", forKey: .type)
            try container.encode(value, forKey: .text)
        case .image(let value):
            try container.encode("input_image", forKey: .type)
            try container.encode(value, forKey: .imageURL)
            try container.encode("auto", forKey: .detail)
        }
    }

    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageURL = "image_url"
        case detail
    }
}

struct OpenAIResponsesRequest: Encodable {
    struct Input: Encodable {
        let role: String
        let content: [OpenAIContent]
    }

    let model: String
    let input: [Input]
}

struct OpenAIResponsesResponse: Decodable {
    struct Output: Decodable {
        struct Content: Decodable {
            let type: String?
            let text: String?
        }
        let content: [Content]?
    }

    let output: [Output]?

    var outputText: String {
        output?
            .flatMap { $0.content ?? [] }
            .compactMap(\.text)
            .joined(separator: "\n") ?? ""
    }
}

struct ProviderAnalysis: Decodable {
    let prudence: String
    let summary: String
    let generalExplanation: String
    let recommendedAction: String
    let observations: [String]

    var prudenceLevel: PrudenceLevel {
        switch prudence.lowercased().folding(options: .diacriticInsensitive, locale: .current) {
        case "faible": .faible
        case "eleve", "elevé": .eleve
        default: .moyen
        }
    }
}

enum ImageSafetyPreflight {
    static func validate(image: UIImage) async throws {
        guard let cgImage = image.cgImage else { return }
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
    }
}

struct AppError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}

extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage? {
        let largest = max(size.width, size.height)
        guard largest > maxDimension else { return self }
        let scale = maxDimension / largest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

#Preview {
    RootView(hasCompletedOnboarding: .constant(true))
}
