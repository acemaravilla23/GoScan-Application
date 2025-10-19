import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class DeploymentScreen extends StatefulWidget {
  const DeploymentScreen({super.key});

  @override
  State<DeploymentScreen> createState() => _DeploymentScreenState();
}

class _DeploymentScreenState extends State<DeploymentScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _deployments = [];

  @override
  void initState() {
    super.initState();
    _loadDeployments();
  }

  Future<void> _loadDeployments() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.get('/scholar/deployments?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _deployments = List<Map<String, dynamic>>.from(response['data']['deployments'] ?? []);
          _isLoading = false;
        });
      } else {
        _showError('Failed to load deployments: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error loading deployments: $e');
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
                      'Deployments',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your SPES deployment history and organization assignments.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Expanded(
                      child: _deployments.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: _deployments.length,
                              itemBuilder: (context, index) {
                                final deployment = _deployments[index];
                                return _buildDeploymentCard(deployment);
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
            Icons.work_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Deployments Found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your deployment records will appear here',
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

  Widget _buildDeploymentCard(Map<String, dynamic> deployment) {
    final status = deployment['status'] ?? 'Undeployed';
    final isDeployed = status == 'Deployed';
    final isCompleted = status == 'Completed';
    final isUndeployed = status == 'Undeployed';
    
    Color statusColor;
    IconData statusIcon;
    
    if (isDeployed) {
      statusColor = const Color(0xFF2563EB); // Blue
      statusIcon = Icons.work;
    } else if (isCompleted) {
      statusColor = const Color(0xFF10B981); // Green
      statusIcon = Icons.check_circle;
    } else if (isUndeployed) {
      statusColor = const Color(0xFFF59E0B); // Orange
      statusIcon = Icons.schedule;
    } else {
      statusColor = const Color(0xFF6B7280); // Gray
      statusIcon = Icons.pending;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
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
                      deployment['organization'] ?? 'Organization',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '${deployment['availment']} - ${deployment['spes_batch']}',
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
          
          // Deployment Details
          _buildDetailRow('Position', deployment['position'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Department', deployment['department'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Organization Type', deployment['org_type'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Address', deployment['org_address'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Supervisor', deployment['contact_person'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Contact', deployment['contact_number'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Start Date', deployment['start_date'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('End Date', deployment['end_date'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildDetailRow('Work Schedule', deployment['work_schedule'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
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

