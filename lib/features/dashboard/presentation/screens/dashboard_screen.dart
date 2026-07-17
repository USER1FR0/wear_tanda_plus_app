import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/circular_safe_area.dart';

// Mock variables to simulate the 3 states
enum PaymentStatus { pending, late, collect }

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Change this variable to test different states:
  // PaymentStatus.pending, PaymentStatus.late, PaymentStatus.collect
  final PaymentStatus currentStatus = PaymentStatus.pending;

  @override
  Widget build(BuildContext context) {
    String mainText;
    Color statusColor;
    String subText;

    switch (currentStatus) {
      case PaymentStatus.late:
        mainText = 'Pago atrasado';
        statusColor = AppColors.statusLate;
        subText = '\$500';
        break;
      case PaymentStatus.collect:
        mainText = '¡Te toca cobrar!';
        statusColor = AppColors.statusCollect;
        subText = '\$5,000 en 3 días';
        break;
      case PaymentStatus.pending:
        mainText = 'Pago en 2 días';
        statusColor = AppColors.statusPending;
        subText = '\$500';
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CircularSafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Contenido principal centrado y escalable
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon/Avatar
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.blueGrey,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Context text
                      const Text(
                        'Tanda Familiar',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Urgent Status
                      Text(
                        mainText,
                        style: AppTextStyles.urgentStatus
                            .copyWith(color: statusColor, fontSize: 18),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Amount or details
                      Text(
                        subText,
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Swipe hint (posicionado al fondo, no compite por espacio)
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Desliza',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 9,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.secondaryText,
                    size: 9,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
