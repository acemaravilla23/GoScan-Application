import 'api_service.dart';

class ScholarshipService {
  // Get scholarship program status
  static Future<ScholarshipStatus> getScholarshipStatus() async {
    try {
      final response = await ApiService.get('/scholarship/status');

      if (response['success'] == true) {
        // Debug logging
        print('Scholarship Status API Response: ${response['data']}');
        if (response['data']['debug'] != null) {
          print('Debug Info: ${response['data']['debug']}');
        }
        
        return ScholarshipStatus.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to get scholarship status');
      }
    } catch (e) {
      throw Exception('Failed to get scholarship status: $e');
    }
  }

  // Check for existing application
  static Future<ApplicationCheckResult> checkExistingApplication(String email) async {
    try {
      final response = await ApiService.get('/scholarship/check-application?email=$email');

      if (response['success'] == true) {
        return ApplicationCheckResult.success(
          hasApplication: response['has_application'] ?? false,
          applicationStatus: response['application_status'],
          examStatus: response['exam_status'],
          interviewStatus: response['interview_status'],
          requirementsStatus: response['requirements_status'],
          classification: response['classification'],
          batch: response['batch'],
          academicYear: response['academic_year'],
          message: response['message'],
          examDetails: response['exam_details'],
          interviewDetails: response['interview_details'],
          requirementsDetails: response['requirements_details'],
          submittedAt: response['submitted_at'],
          spesId: response['spes_id'],
          spesBatch: response['spes_batch'],
          scholarStatus: response['scholar_status'],
        );
      } else {
        return ApplicationCheckResult.error(response['message'] ?? 'Failed to check application');
      }
    } on ApiException catch (e) {
      return ApplicationCheckResult.error(e.getAllErrors());
    } catch (e) {
      return ApplicationCheckResult.error('An unexpected error occurred: $e');
    }
  }

  // Submit scholarship application
  static Future<ApplicationResult> submitApplication(Map<String, dynamic> applicationData) async {
    try {
      final response = await ApiService.post('/scholarship/apply', applicationData);

      // Debug logging (remove in production)
      print('API Response - Success: ${response['success']}, Message: ${response['message']}');

      if (response['success'] == true) {
        // Safely extract data with proper null checking and type conversion
        final data = response['data'] as Map<String, dynamic>?;
        return ApplicationResult.success(
          applicationId: data?['application_id']?.toString(),
          status: data?['status']?.toString(),
          message: response['message']?.toString() ?? 'Application submitted successfully!',
        );
      } else {
        return ApplicationResult.error(response['message']?.toString() ?? 'Application failed');
      }
    } on ApiException catch (e) {
      return ApplicationResult.error(e.getAllErrors());
    } catch (e) {
      return ApplicationResult.error('An unexpected error occurred: $e');
    }
  }
}

// Scholarship status model
class ScholarshipStatus {
  final bool hasOngoingAcademicYear;
  final bool isApplicationOpen;
  final String? currentAcademicYear;
  final String? applicationPeriod;
  final String? applicationStartDate;
  final String? applicationEndDate;
  final String? message;

  ScholarshipStatus({
    required this.hasOngoingAcademicYear,
    required this.isApplicationOpen,
    this.currentAcademicYear,
    this.applicationPeriod,
    this.applicationStartDate,
    this.applicationEndDate,
    this.message,
  });

  factory ScholarshipStatus.fromJson(Map<String, dynamic> json) {
    return ScholarshipStatus(
      hasOngoingAcademicYear: json['has_ongoing_academic_year'] ?? false,
      isApplicationOpen: json['is_application_open'] ?? false,
      currentAcademicYear: json['current_academic_year'],
      applicationPeriod: json['application_period'],
      applicationStartDate: json['application_start_date'],
      applicationEndDate: json['application_end_date'],
      message: json['message'],
    );
  }
}

// Application check result model
class ApplicationCheckResult {
  final bool isSuccess;
  final String? error;
  final bool? hasApplication;
  final String? applicationStatus;
  final String? examStatus;
  final String? interviewStatus;
  final String? requirementsStatus;
  final String? classification;
  final String? batch;
  final String? academicYear;
  final String? message;
  final ExamDetails? examDetails;
  final InterviewDetails? interviewDetails;
  final RequirementsDetails? requirementsDetails;
  final String? submittedAt;
  final String? spesId;
  final String? spesBatch;
  final String? scholarStatus;

  ApplicationCheckResult._({
    required this.isSuccess,
    this.error,
    this.hasApplication,
    this.applicationStatus,
    this.examStatus,
    this.interviewStatus,
    this.requirementsStatus,
    this.classification,
    this.batch,
    this.academicYear,
    this.message,
    this.examDetails,
    this.interviewDetails,
    this.requirementsDetails,
    this.submittedAt,
    this.spesId,
    this.spesBatch,
    this.scholarStatus,
  });

  factory ApplicationCheckResult.success({
    bool? hasApplication,
    String? applicationStatus,
    String? examStatus,
    String? interviewStatus,
    String? requirementsStatus,
    String? classification,
    String? batch,
    String? academicYear,
    String? message,
    Map<String, dynamic>? examDetails,
    Map<String, dynamic>? interviewDetails,
    Map<String, dynamic>? requirementsDetails,
    String? submittedAt,
    String? spesId,
    String? spesBatch,
    String? scholarStatus,
  }) {
    return ApplicationCheckResult._(
      isSuccess: true,
      hasApplication: hasApplication,
      applicationStatus: applicationStatus,
      examStatus: examStatus,
      interviewStatus: interviewStatus,
      requirementsStatus: requirementsStatus,
      classification: classification,
      batch: batch,
      academicYear: academicYear,
      message: message,
      examDetails: examDetails != null ? ExamDetails.fromJson(examDetails) : null,
      interviewDetails: interviewDetails != null ? InterviewDetails.fromJson(interviewDetails) : null,
      requirementsDetails: requirementsDetails != null ? RequirementsDetails.fromJson(requirementsDetails) : null,
      submittedAt: submittedAt,
      spesId: spesId,
      spesBatch: spesBatch,
      scholarStatus: scholarStatus,
    );
  }

  factory ApplicationCheckResult.error(String error) {
    return ApplicationCheckResult._(
      isSuccess: false,
      error: error,
    );
  }
}

// Exam details model
class ExamDetails {
  final String? schedule;
  final String? location;
  final String? building;
  final String? room;
  final String? results;

  ExamDetails({
    this.schedule,
    this.location,
    this.building,
    this.room,
    this.results,
  });

  factory ExamDetails.fromJson(Map<String, dynamic> json) {
    return ExamDetails(
      schedule: json['schedule'],
      location: json['location'],
      building: json['building'],
      room: json['room'],
      results: json['results'],
    );
  }
}

// Interview details model
class InterviewDetails {
  final String? schedule;
  final String? location;
  final String? results;

  InterviewDetails({
    this.schedule,
    this.location,
    this.results,
  });

  factory InterviewDetails.fromJson(Map<String, dynamic> json) {
    return InterviewDetails(
      schedule: json['schedule'],
      location: json['location'],
      results: json['results'],
    );
  }
}

// Requirements details model
class RequirementsDetails {
  final String folder1Status;
  final String folder2Status;
  final String folder3Status;
  final String folder4Status;

  RequirementsDetails({
    required this.folder1Status,
    required this.folder2Status,
    required this.folder3Status,
    required this.folder4Status,
  });

  factory RequirementsDetails.fromJson(Map<String, dynamic> json) {
    return RequirementsDetails(
      folder1Status: json['folder1_status'] ?? 'Incomplete',
      folder2Status: json['folder2_status'] ?? 'Incomplete',
      folder3Status: json['folder3_status'] ?? 'Incomplete',
      folder4Status: json['folder4_status'] ?? 'Incomplete',
    );
  }
}

// Application result model
class ApplicationResult {
  final bool isSuccess;
  final String? error;
  final String? applicationId;
  final String? status;
  final String? message;

  ApplicationResult._({
    required this.isSuccess,
    this.error,
    this.applicationId,
    this.status,
    this.message,
  });

  factory ApplicationResult.success({
    String? applicationId,
    String? status,
    String? message,
  }) {
    return ApplicationResult._(
      isSuccess: true,
      applicationId: applicationId,
      status: status,
      message: message,
    );
  }

  factory ApplicationResult.error(String error) {
    return ApplicationResult._(
      isSuccess: false,
      error: error,
    );
  }
}
