import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class AvailmentScreen extends StatefulWidget {
  const AvailmentScreen({super.key});

  @override
  State<AvailmentScreen> createState() => _AvailmentScreenState();
}

class _AvailmentScreenState extends State<AvailmentScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _availments = [];

  @override
  void initState() {
    super.initState();
    _loadAvailments();
  }

  Future<void> _loadAvailments() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.get('/scholar/availments?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _availments = List<Map<String, dynamic>>.from(response['data']['availments'] ?? []);
          _isLoading = false;
        });
      } else {
        _showError('Failed to load availments: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error loading availments: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Availments',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your scholarship availment history and status.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Expanded(
                      child: _availments.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: _availments.length,
                              itemBuilder: (context, index) {
                                final availment = _availments[index];
                                return _buildAvailmentCard(availment);
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Availments Found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your availment records will appear here',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailmentCard(Map<String, dynamic> availment) {
    final status = availment['status'] ?? 'Ongoing';
    final isOngoing = status == 'Ongoing';
    final isForRenewal = status == 'For Renewal';
    final isCompleted = status == 'Completed';
    
    Color statusColor;
    IconData statusIcon;
    
    if (isOngoing) {
      statusColor = const Color(0xFF2563EB); // Blue
      statusIcon = Icons.schedule;
    } else if (isForRenewal) {
      statusColor = const Color(0xFFF59E0B); // Orange
      statusIcon = Icons.refresh;
    } else if (isCompleted) {
      statusColor = const Color(0xFF10B981); // Green
      statusIcon = Icons.check_circle;
    } else {
      statusColor = const Color(0xFF6B7280); // Gray
      statusIcon = Icons.school;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOngoing ? null : Border.all(color: statusColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      availment['availment'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      availment['academic_year'],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Availment Details
          _buildDetailRow('Classification', availment['classification']),
          const SizedBox(height: 8),
          _buildDetailRow('Start Date', availment['avail_from'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('End Date', availment['avail_to'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(
          ': ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Color(0xFF1F2937),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

}
