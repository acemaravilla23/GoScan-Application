import 'api_config.dart';

class NetworkConfig {
  // Use the same IP from ApiConfig to avoid duplication
  static String get laptopIp => ApiConfig.serverIp;
  
  // Flask Backend URLs
  static String get flaskBaseUrl => 'http://$laptopIp:5000/api';
  
  // Template Download endpoints
  static String getTemplateDownloadUrl(String templateName) => '$flaskBaseUrl/pdf/download/$templateName';
  
  // Available templates
  static String get applicationFormUrl => getTemplateDownloadUrl('application-form');
  static String get rulesUndertakingUrl => getTemplateDownloadUrl('rules-undertaking');
  static String get requirementsChecklistUrl => getTemplateDownloadUrl('requirements-checklist');
  static String get employmentCertificateUrl => getTemplateDownloadUrl('employment-certificate');
  static String get schoolCertificationUrl => getTemplateDownloadUrl('school-certification');
}
