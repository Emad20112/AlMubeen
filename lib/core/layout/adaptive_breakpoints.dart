enum AdaptiveWindowClass { compact, medium, expanded }

abstract final class AdaptiveBreakpoints {
  static const double compactMaxWidth = 600;
  static const double expandedMinWidth = 1024;

  static AdaptiveWindowClass fromWidth(double width) {
    if (width < compactMaxWidth) {
      return AdaptiveWindowClass.compact;
    }

    if (width < expandedMinWidth) {
      return AdaptiveWindowClass.medium;
    }

    return AdaptiveWindowClass.expanded;
  }
}
