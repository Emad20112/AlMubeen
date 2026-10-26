import 'dart:io';

void main(List<String> args) {
  final isDryRun = !args.contains('--apply');
  final targetDir = args.firstWhere(
    (a) => !a.startsWith('--'),
    orElse: () => 'lib',
  );

  stdout.writeln('====================================================');
  stdout.writeln('  Al-Mubeen Design System Migration Tool (Codemod)  ');
  stdout.writeln('====================================================');
  stdout.writeln('Target directory: $targetDir');
  stdout.writeln('Mode: ${isDryRun ? "DRY RUN (preview only)" : "APPLY (writing changes)"}\n');

  final dir = Directory(targetDir);
  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: $targetDir');
    exit(1);
  }

  final dartFiles = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.contains(RegExp(r'[\\/]app[\\/]theme[\\/]')))
      .toList();

  int totalFilesModified = 0;
  int totalReplacements = 0;
  final stats = <String, int>{};

  void recordStat(String key, int count) {
    stats[key] = (stats[key] ?? 0) + count;
    totalReplacements += count;
  }

  for (final file in dartFiles) {
    final originalContent = file.readAsStringSync();
    var content = originalContent;
    int fileChanges = 0;

    // 1. BorderRadius replacements
    final radiusRules = <RegExp, String>{
      RegExp(r'BorderRadius\.circular\(4(\.0)?\)'): 'BorderRadius.circular(AppRadii.xs)',
      RegExp(r'BorderRadius\.circular\(8(\.0)?\)'): 'BorderRadius.circular(AppRadii.sm)',
      RegExp(r'BorderRadius\.circular\(10(\.0)?\)'): 'BorderRadius.circular(AppRadii.sm)',
      RegExp(r'BorderRadius\.circular\(12(\.0)?\)'): 'BorderRadius.circular(AppRadii.md)',
      RegExp(r'BorderRadius\.circular\(14(\.0)?\)'): 'BorderRadius.circular(AppRadii.md)',
      RegExp(r'BorderRadius\.circular\(16(\.0)?\)'): 'BorderRadius.circular(AppRadii.lg)',
      RegExp(r'BorderRadius\.circular\(18(\.0)?\)'): 'BorderRadius.circular(AppRadii.lg)',
      RegExp(r'BorderRadius\.circular\(20(\.0)?\)'): 'BorderRadius.circular(AppRadii.lg)',
      RegExp(r'BorderRadius\.circular\(24(\.0)?\)'): 'BorderRadius.circular(AppRadii.xl)',
      RegExp(r'BorderRadius\.circular\(28(\.0)?\)'): 'BorderRadius.circular(AppRadii.xl)',
      RegExp(r'BorderRadius\.circular\(999(\.0)?\)'): 'BorderRadius.circular(AppRadii.pill)',
      RegExp(r'Radius\.circular\(8(\.0)?\)'): 'Radius.circular(AppRadii.sm)',
      RegExp(r'Radius\.circular\(12(\.0)?\)'): 'Radius.circular(AppRadii.md)',
      RegExp(r'Radius\.circular\(16(\.0)?\)'): 'Radius.circular(AppRadii.lg)',
      RegExp(r'Radius\.circular\(20(\.0)?\)'): 'Radius.circular(AppRadii.lg)',
      RegExp(r'Radius\.circular\(24(\.0)?\)'): 'Radius.circular(AppRadii.xl)',
      RegExp(r'Radius\.circular\(28(\.0)?\)'): 'Radius.circular(AppRadii.xl)',
    };

    bool needsRadiiImport = false;
    for (final entry in radiusRules.entries) {
      final matches = entry.key.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(entry.key, entry.value);
        recordStat('BorderRadius tokens', matches);
        fileChanges += matches;
        needsRadiiImport = true;
      }
    }

    // 2. SizedBox spacing replacements
    final spacingRules = <RegExp, String>{
      RegExp(r'SizedBox\(height:\s*4(\.0)?\)'): 'SizedBox(height: AppSpacing.xs)',
      RegExp(r'SizedBox\(height:\s*8(\.0)?\)'): 'SizedBox(height: AppSpacing.sm)',
      RegExp(r'SizedBox\(height:\s*12(\.0)?\)'): 'SizedBox(height: AppSpacing.md)',
      RegExp(r'SizedBox\(height:\s*16(\.0)?\)'): 'SizedBox(height: AppSpacing.lg)',
      RegExp(r'SizedBox\(height:\s*24(\.0)?\)'): 'SizedBox(height: AppSpacing.xl)',
      RegExp(r'SizedBox\(height:\s*32(\.0)?\)'): 'SizedBox(height: AppSpacing.xxl)',
      RegExp(r'SizedBox\(width:\s*4(\.0)?\)'): 'SizedBox(width: AppSpacing.xs)',
      RegExp(r'SizedBox\(width:\s*8(\.0)?\)'): 'SizedBox(width: AppSpacing.sm)',
      RegExp(r'SizedBox\(width:\s*12(\.0)?\)'): 'SizedBox(width: AppSpacing.md)',
      RegExp(r'SizedBox\(width:\s*16(\.0)?\)'): 'SizedBox(width: AppSpacing.lg)',
      RegExp(r'SizedBox\(width:\s*24(\.0)?\)'): 'SizedBox(width: AppSpacing.xl)',
      RegExp(r'SizedBox\(width:\s*32(\.0)?\)'): 'SizedBox(width: AppSpacing.xxl)',
    };

    bool needsSpacingImport = false;
    for (final entry in spacingRules.entries) {
      final matches = entry.key.allMatches(content).length;
      if (matches > 0) {
        content = content.replaceAll(entry.key, entry.value);
        recordStat('Spacing tokens (SizedBox)', matches);
        fileChanges += matches;
        needsSpacingImport = true;
      }
    }

    // 3. Ensure imports if modified
    if (fileChanges > 0) {
      if (needsRadiiImport && !content.contains('app_radii.dart')) {
        content = _addImport(content, "import 'package:al_mubeen/app/theme/app_radii.dart';");
      }
      if (needsSpacingImport && !content.contains('app_spacing.dart')) {
        content = _addImport(content, "import 'package:al_mubeen/app/theme/app_spacing.dart';");
      }

      totalFilesModified++;
      final relPath = file.path.replaceAll(r'\', '/');
      stdout.writeln('  [MODIFIED] $relPath ($fileChanges replacements)');

      if (!isDryRun) {
        file.writeAsStringSync(content);
      }
    }
  }

  stdout.writeln('\n---------------- SUMMARY ----------------');
  stdout.writeln('Total files scanned: ${dartFiles.length}');
  stdout.writeln('Total files with changes: $totalFilesModified');
  stdout.writeln('Total replacements made: $totalReplacements');
  stats.forEach((key, count) {
    stdout.writeln('  • $key: $count');
  });
  stdout.writeln('-----------------------------------------');

  if (isDryRun) {
    stdout.writeln('\n[!] Run with --apply to write these changes to disk.');
  } else {
    stdout.writeln('\n[✓] Changes applied successfully.');
  }
}

String _addImport(String content, String importStatement) {
  final importRegex = RegExp(r"^import\s+['\x22][^'\x22]+['\x22];", multiLine: true);
  final matches = importRegex.allMatches(content).toList();

  if (matches.isNotEmpty) {
    final insertPos = matches.last.end;
    return '${content.substring(0, insertPos)}\n$importStatement${content.substring(insertPos)}';
  } else {
    return '$importStatement\n\n$content';
  }
}
