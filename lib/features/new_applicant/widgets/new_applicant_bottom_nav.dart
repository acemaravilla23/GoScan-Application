import 'package:flutter/material.dart';

class NewApplicantBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NewApplicantBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.upload_outlined,
                activeIcon: Icons.upload,
                label: 'To Submit',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.document_scanner_outlined,
                activeIcon: Icons.document_scanner,
                label: 'GoScan',
                index: 2,
                isCenter: true,
              ),
              _buildNavItem(
                icon: Icons.school_outlined,
                activeIcon: Icons.school,
                label: 'Exam',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.person_search_outlined,
                activeIcon: Icons.person_search,
                label: 'Interview',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isActive = currentIndex == index;
    
    if (isCenter) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ] : null,
          ),
          child: Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 28,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFF2563EB) : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF2563EB) : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
