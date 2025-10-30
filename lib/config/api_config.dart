class ApiConfig {
  // ========================================
  // API CONFIGURATION - EDIT THIS SECTION
  // ========================================
  
  // Your computer's IP address (change this when you switch networks)
  static const String serverIp = '192.168.1.3';
  
  // Laravel server port (usually 8000 for 'php artisan serve' or check your composer run dev port)
  static const String serverPort = '8000';
  
  // Protocol (usually http for local development)
  static const String protocol = 'http';
  
  // ========================================
  // DO NOT EDIT BELOW THIS LINE
  // ========================================
  
  // Computed base URL for API endpoints
  static String get baseUrl => '$protocol://$serverIp:$serverPort/api';
  
  // Computed base URL for static files (images, documents, etc.)
  static String get staticUrl => '$protocol://$serverIp:$serverPort';
  
  // Environment-specific URLs for reference
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000/api';
  static const String iosSimulatorUrl = 'http://localhost:8000/api';
  
  // Helper method to get connection info
  static Map<String, String> getConnectionInfo() {
    return {
      'Base URL': baseUrl,
      'Server IP': serverIp,
      'Server Port': serverPort,
      'Protocol': protocol,
    };
  }
  
  // Common Laravel development ports for reference
  static const Map<String, String> commonPorts = {
    'php artisan serve': '8000',
    'composer run dev (Vite)': '5173',
    'npm run dev': '3000',
    'Laravel Sail': '80',
  };
  
  // Instructions for finding your IP address
  static const String ipInstructions = '''
  To find your computer's IP address:
  
  Windows:
  1. Press Win + R, type 'cmd', press Enter
  2. Type 'ipconfig' and press Enter
  3. Look for "IPv4 Address" under your network adapter
  
  Mac:
  1. Open System Preferences > Network
  2. Select your connection (Wi-Fi/Ethernet)
  3. Your IP address is shown on the right
  
  Linux:
  1. Open terminal
  2. Type 'ip addr show' or 'hostname -I'
  ''';
}
