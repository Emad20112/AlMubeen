import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    required this.title,
    this.message,
    this.progress,
    super.key,
  });

  final String title;
  final String? message;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final normalizedProgress = progress?.clamp(0.0, 1.0).toDouble();

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        color: AppColors.maroon800,
                        size: textScaler.scale(52).clamp(44, 76).toDouble(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.maroon800,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          message!,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.ink),
                        ),
                      ],
                      const SizedBox(height: 26),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: normalizedProgress,
                          minHeight: 8,
                          backgroundColor: AppColors.maroon800.withValues(
                            alpha: 0.14,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.maroon800,
                          ),
                        ),
                      ),
                      if (normalizedProgress != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${(normalizedProgress * 100).toStringAsFixed(0)}%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.maroon700),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
