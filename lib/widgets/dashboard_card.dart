import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon section
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBackgroundColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconBackgroundColor, size: 28),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: iconBackgroundColor,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(description, style: Theme.of(context).textTheme.bodyMedium),

              const Spacer(),

              // Open button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: iconBackgroundColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Open',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: iconBackgroundColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: iconBackgroundColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
