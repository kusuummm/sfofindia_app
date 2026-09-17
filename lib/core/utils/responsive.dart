import 'package:flutter/material.dart';

/// Screen classification based on common device breakpoints
enum ScreenType {
  mobileCompact, // < 360px (e.g. iPhone SE 1st gen, small Androids)
  mobileStandard, // 360px - 600px (standard modern smartphones)
  tablet, // 600px - 950px (tablets, foldables, small laptops)
  desktop, // >= 950px (desktop monitors, wide web browsers)
}

/// Centralized Responsive utility for Shaheed Foundation app
class Responsive {
  static const double mobileCompactMax = 360.0;
  static const double mobileMax = 600.0;
  static const double tabletMax = 950.0;
  static const double desktopMin = 950.0;
  static const double maxContentWidth = 1140.0;

  static bool isMobileCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileCompactMax;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width < desktopMin;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMin;

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileCompactMax) return ScreenType.mobileCompact;
    if (width < mobileMax) return ScreenType.mobileStandard;
    if (width < desktopMin) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileCompactMax) return 10.0;
    if (width < mobileMax) return 16.0;
    if (width < desktopMin) return 24.0;
    return 32.0;
  }

  /// Calculates dynamic childAspectRatio for metric/stat cards in 2-column grids
  /// to strictly prevent RenderFlex bottom overflow on ultra-compact devices.
  static double metricCardAspectRatio(double availableWidth) {
    if (availableWidth < 340) return 0.78;
    if (availableWidth < 380) return 0.88;
    if (availableWidth < 500) return 1.05;
    if (availableWidth < 700) return 1.18;
    return 1.35;
  }

  /// Calculates dynamic childAspectRatio for document quick action cards
  static double docCardAspectRatio(double availableWidth) {
    if (availableWidth < 340) return 0.80;
    if (availableWidth < 380) return 0.90;
    if (availableWidth < 500) return 1.05;
    if (availableWidth < 700) return 1.18;
    return 1.32;
  }

  /// Responsive column count for image galleries or card lists
  static int galleryColumns(double availableWidth) {
    if (availableWidth >= 1200) return 4;
    if (availableWidth >= 800) return 3;
    return 2;
  }
}

/// Container that limits maximum content width and centers content on wide screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

/// Builder widget that supplies constraints and screen type
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, ScreenType screenType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final ScreenType type;
        if (width < Responsive.mobileCompactMax) {
          type = ScreenType.mobileCompact;
        } else if (width < Responsive.mobileMax) {
          type = ScreenType.mobileStandard;
        } else if (width < Responsive.desktopMin) {
          type = ScreenType.tablet;
        } else {
          type = ScreenType.desktop;
        }
        return builder(context, constraints, type);
      },
    );
  }
}
