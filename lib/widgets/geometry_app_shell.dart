import 'package:flutter/material.dart';
import 'package:todoey/features/linear_transformation_visualization/linear_transformation_home_page.dart';
import 'package:todoey/features/matrix_rref/matrix_rref_home_page.dart';
import 'package:todoey/features/triangle_intersection/geometry_home_page.dart';

enum GeometryAppPage {
  barycentric,
  matrixRref,
  linearTransformation,
}

class GeometryAppShell extends StatefulWidget {
  const GeometryAppShell({super.key});

  @override
  State<GeometryAppShell> createState() => _GeometryAppShellState();
}

class _GeometryAppShellState extends State<GeometryAppShell> {
  GeometryAppPage _selectedPage = GeometryAppPage.barycentric;
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  void _selectPage(GeometryAppPage page) {
    setState(() {
      _selectedPage = page;
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedPage.index,
            children: const [
              GeometryHomePage(),
              MatrixRrefHomePage(),
              LinearTransformationHomePage(),
            ],
          ),
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleMenu,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ),
            ),
          if (_isMenuOpen)
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 76, right: 24),
                  child: _FloatingMenuPanel(
                    selectedPage: _selectedPage,
                    onSelectPage: _selectPage,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 24),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _toggleMenu,
                    icon: Icon(
                      _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                    ),
                    color: Colors.white,
                    tooltip: 'Menu',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingMenuPanel extends StatelessWidget {
  const _FloatingMenuPanel({
    required this.selectedPage,
    required this.onSelectPage,
  });

  final GeometryAppPage selectedPage;
  final ValueChanged<GeometryAppPage> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuItemButton(
            label: '삼각형 교차 시각화',
            icon: Icons.change_history_rounded,
            selected: selectedPage == GeometryAppPage.barycentric,
            onTap: () => onSelectPage(GeometryAppPage.barycentric),
          ),
          const SizedBox(height: 10),
          _MenuItemButton(
            label: '행렬 연산 + Ax=b + RREF 시각화',
            icon: Icons.grid_view_rounded,
            selected: selectedPage == GeometryAppPage.matrixRref,
            onTap: () => onSelectPage(GeometryAppPage.matrixRref),
          ),
          const SizedBox(height: 10),
          _MenuItemButton(
            label: '선형변환 시각화',
            icon: Icons.transform_rounded,
            selected: selectedPage == GeometryAppPage.linearTransformation,
            onTap: () => onSelectPage(GeometryAppPage.linearTransformation),
          ),
        ],
      ),
    );
  }
}

class _MenuItemButton extends StatelessWidget {
  const _MenuItemButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF8A3D).withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF8A3D).withValues(alpha: 0.36)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFFFC08A) : Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
