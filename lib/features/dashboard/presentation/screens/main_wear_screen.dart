import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../cobros/presentation/screens/cobros_lista_screen.dart';
import '../../../notificaciones/presentation/screens/pagos_lista_screen.dart';
import 'dashboard_screen.dart';

class MainWearScreen extends StatefulWidget {
  final VoidCallback? onCerrarSesion;

  const MainWearScreen({super.key, this.onCerrarSesion});

  @override
  State<MainWearScreen> createState() => _MainWearScreenState();
}

class _MainWearScreenState extends State<MainWearScreen> {
  // viewportFraction < 1.0 da la pista visual de la siguiente página
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irAPagina(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Total de páginas: Dashboard + lista de pagos pendientes + lista de
    // pagos recibidos.
    const totalPages = 3;
    final currentIndex = _currentIndex >= totalPages ? totalPages - 1 : _currentIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: totalPages,
            itemBuilder: (context, index) {
              if (index == 0) {
                return DashboardScreen(
                  onCerrarSesion: widget.onCerrarSesion,
                  onSiguiente: () => _irAPagina(1),
                );
              }
              if (index == 1) {
                return PagosListaScreen(
                  onAnterior: () => _irAPagina(0),
                  onSiguiente: () => _irAPagina(2),
                );
              }
              return CobrosListaScreen(onAnterior: () => _irAPagina(1));
            },
          ),

          // Indicador de página (dots)
          Positioned(
            bottom: 12, // Respetando zona segura circular
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2.0),
                  height: 6,
                  width: currentIndex == index ? 6 : 4,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.primaryText
                        : AppColors.secondaryText.withAlpha(127),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
