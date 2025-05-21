import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    this.isLoading = false,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isLoading = false;
  bool _isApiKeyValid = false;
  bool _isInitializing = true; // Untuk menandai proses inisialisasi

  // Fallback API Key HANYA untuk development jika .env atau dart-define tidak ada.
  // JANGAN PERNAH GUNAKAN KEY ASLI YANG DIHARDCODE DI PRODUKSI.
  // Jika key ini bocor, segera regenerasi.
  final String _devFallbackApiKey = "AIzaSyAT-dLjegP2og8B9Jhi1nKDV8pxeHryOYw";

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    if (!mounted) return;
    setState(() {
      _isInitializing = true;
    });

    String? apiKey = _getApiKeyFromSources();

    if (apiKey == null || apiKey.isEmpty) {
      _showError("API Key Gemini tidak ditemukan. Pastikan file .env berisi GEMINI_API_KEY=nilai_key_anda.");
      if (mounted) {
        setState(() {
          _isApiKeyValid = false;
          _isInitializing = false;
        });
      }
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
        generationConfig: GenerationConfig(maxOutputTokens: 200),
      );

      // Tes koneksi
      final response = await _model!.generateContent([Content.text("Hello")]);
      if (response.text != null && response.text!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _isApiKeyValid = true;
            _chat = _model!.startChat();
            _addInitialBotMessage("Halo! Saya Chatbot Sehat Bersama. Siap membantu Anda.");
          });
        }
      } else {
        _showError("API Key terdeteksi, namun gagal mendapatkan respons tes dari Gemini.");
        if (mounted) setState(() => _isApiKeyValid = false);
      }
    } catch (e) {
      print("Error initializing Gemini: $e");
      String errorMessage = "Gagal terhubung ke layanan AI. ";
      if (e.toString().toLowerCase().contains("api key not valid") ||
          e.toString().toLowerCase().contains("permission denied")) {
        errorMessage += "API Key tidak valid atau izin ditolak. Periksa API Key Anda.";
      } else if (e.toString().toLowerCase().contains("quota")) {
        errorMessage += "Quota API Anda mungkin telah habis.";
      } else {
        errorMessage += "Detail: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}...";
      }
      _showError(errorMessage);
      if (mounted) setState(() => _isApiKeyValid = false);
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  String? _getApiKeyFromSources() {
    // 1. Dari flutter_dotenv (file .env)
    if (dotenv.isInitialized) { // Pastikan dotenv sudah di-load
      final apiKeyFromDotEnv = dotenv.env['GEMINI_API_KEY']; // Gunakan NAMA VARIABEL
      if (apiKeyFromDotEnv != null && apiKeyFromDotEnv.isNotEmpty) {
        print("API Key loaded from .env");
        return apiKeyFromDotEnv;
      }
    }

    // 2. Dari String.fromEnvironment (untuk --dart-define)
    const apiKeyFromDartDefine = String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''); // Gunakan NAMA VARIABEL
    if (apiKeyFromDartDefine.isNotEmpty) {
      print("API Key loaded from dart-define");
      return apiKeyFromDartDefine;
    }

    // 3. Fallback (HANYA UNTUK DEVELOPMENT jika dua di atas gagal total)
    print("WARNING: Using fallback development API Key. Ensure .env or dart-define is configured for release builds.");
    return _devFallbackApiKey;
  }

  void _showError(String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 7),
            ),
          );
        }
      });
    }
  }

  void _addInitialBotMessage(String text) {
    if (mounted) {
      setState(() {
        _messages.insert(0, ChatMessage(text: text, isUserMessage: false));
      });
    }
  }

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();
    if (text.trim().isEmpty) return;

    if (!mounted) return;
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUserMessage: true));
      _isLoading = true;
      _messages.insert(0, ChatMessage(text: "...", isUserMessage: false, isLoading: true));
    });

    if (!_isApiKeyValid || _chat == null) {
      if (mounted) {
        setState(() {
          _messages.removeAt(0); // Hapus "..."
          _messages.insert(0, ChatMessage(text: "Layanan chatbot tidak tersedia (konfigurasi API bermasalah).", isUserMessage: false));
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await _chat!.sendMessage(Content.text(text));
      final String? botResponse = response.text;

      if (mounted) {
        setState(() {
          _messages.removeAt(0); // Hapus "..."
          if (botResponse != null && botResponse.isNotEmpty) {
            _messages.insert(0, ChatMessage(text: botResponse, isUserMessage: false));
          } else {
            _messages.insert(0, ChatMessage(text: "Maaf, saya tidak mendapatkan respons.", isUserMessage: false));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error sending message: $e");
      if (mounted) {
        setState(() {
          _messages.removeAt(0); // Hapus "..."
          _messages.insert(0, ChatMessage(text: "Oops, terjadi kesalahan jaringan.", isUserMessage: false));
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(child: Icon(Icons.support_agent)),
            ),
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: message.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!message.isUserMessage)
            const Padding(
              padding: EdgeInsets.only(right: 8.0, top: 4.0),
              child: CircleAvatar(child: Icon(Icons.support_agent)),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUserMessage ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(message.text),
            ),
          ),
          if (message.isUserMessage)
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 4.0),
              child: CircleAvatar(child: Icon(Icons.person)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          title: const Text("Chatbot Sehat Bersama"),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Menghubungkan ke layanan AI..."),
            ],
          ),
        ),
      );
    }

    if (!_isApiKeyValid) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
          title: const Text("Chatbot Error"),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                const Text(
                  "Gagal Menginisialisasi Chatbot",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Pastikan API Key Gemini sudah benar dan layanan dapat diakses. Periksa file .env (GEMINI_API_KEY) atau koneksi internet Anda.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Coba Lagi Inisialisasi"),
                  onPressed: _initializeAI,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Tampilan utama chatbot jika semua OK
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Consultation with Chatbot\nSehat Bersama",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessage(_messages[index]),
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 4.0), // Padding yang sudah ada
        decoration: BoxDecoration( // Optional: Tambahkan border atau background jika diinginkan
          color: Theme.of(context).cardColor, // Menggunakan warna kartu tema sebagai latar
          borderRadius: BorderRadius.circular(25.0), // Membuat sudut lebih melengkung
          border: Border.all(
            color: Theme.of(context).dividerColor, // Warna border tipis
            width: 0.5,
          )
        ),
        child: Row(
          children: <Widget>[
            Expanded( // Mengganti Flexible dengan Expanded agar TextField mengisi ruang
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0), // Tambahkan padding horizontal di dalam TextField
                child: TextField(
                  controller: _textController,
                  onSubmitted: _isLoading ? null : _handleSubmitted,
                  style: const TextStyle(color: Colors.black, fontSize: 16.0), // <--- TAMBAHKAN INI: Gaya teks input
                  decoration: const InputDecoration.collapsed(
                    hintText: "Ketik pesan Anda...",
                    hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Optional: Atur warna hint text
                  ),
                  cursorColor: Theme.of(context).colorScheme.primary, // Optional: Atur warna kursor
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4.0), // Margin hanya di kanan untuk send button
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary, // Warna ikon send disesuaikan dengan primary color
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}