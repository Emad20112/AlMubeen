# File Sharing & Export — share_plus, PDF, Excel

```yaml
dependencies:
  share_plus: ^9.0.0
  path_provider: ^2.1.3
  pdf: ^3.11.1               # PDF generation
  printing: ^5.13.1          # PDF preview & print
  excel: ^4.0.2              # Excel generation
  open_filex: ^4.3.4         # Open files natively
  file_picker: ^8.0.7        # Pick files
```

---

## share_plus — Share Anything

```dart
@lazySingleton
class ShareService {
  /// Share plain text
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// Share a single file
  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
    );
  }

  /// Share multiple files
  Future<void> shareFiles(List<File> files, {String? text}) async {
    await Share.shareXFiles(
      files.map((f) => XFile(f.path)).toList(),
      text: text,
    );
  }

  /// Share with result (know if user shared or dismissed)
  Future<bool> shareWithResult(String text) async {
    final result = await Share.share(text);
    return result.status == ShareResultStatus.success;
  }

  /// Share app link
  Future<void> shareAppLink() => Share.share(
    'Check out ${AppConfig.appName}!\n${AppConfig.storeUrl}',
    subject: '${AppConfig.appName} — VPN App',
  );
}
```

---

## PDF Generation

```dart
@lazySingleton
class PdfService {
  /// Generate a PDF report/invoice
  Future<File> generateReport({
    required String title,
    required List<Map<String, dynamic>> data,
    required List<String> columns,
  }) async {
    final pdf = pw.Document();

    // Load fonts
    final regularFont = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(title, boldFont),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTable(data, columns, regularFont, boldFont),
        ],
      ),
    );

    // Save to temp directory
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${title.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(String title, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title,
            style: pw.TextStyle(font: boldFont, fontSize: 20)),
        pw.Text(DateFormat('MMM dd, yyyy').format(DateTime.now())),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
      ],
    );
  }

  pw.Widget _buildTable(
    List<Map<String, dynamic>> data,
    List<String> columns,
    pw.Font regular,
    pw.Font bold,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        for (int i = 0; i < columns.length; i++)
          i: const pw.FlexColumnWidth(),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: columns
              .map((col) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(col,
                        style: pw.TextStyle(font: bold, fontSize: 12)),
                  ))
              .toList(),
        ),
        // Data rows
        ...data.map((row) => pw.TableRow(
          children: columns
              .map((col) => pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(row[col]?.toString() ?? '',
                        style: pw.TextStyle(font: regular, fontSize: 11)),
                  ))
              .toList(),
        )),
      ],
    );
  }

  /// Preview PDF in-app
  Future<void> previewPdf(File file, {String? title}) async {
    await Printing.layoutPdf(
      name: title ?? 'Document',
      onLayout: (_) async => file.readAsBytes(),
    );
  }

  /// Share PDF
  Future<void> sharePdf(File file, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: subject,
    );
  }
}
```

---

## Excel Export

```dart
@lazySingleton
class ExcelService {
  Future<File> exportToExcel({
    required String fileName,
    required String sheetName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];

    // Style for headers
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.blue100,
      fontColorHex: ExcelColor.black,
    );

    // Write headers
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Write data rows
    for (int rowIdx = 0; rowIdx < rows.length; rowIdx++) {
      for (int colIdx = 0; colIdx < rows[rowIdx].length; colIdx++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: colIdx, rowIndex: rowIdx + 1));
        final value = rows[rowIdx][colIdx];
        cell.value = switch (value) {
          int v => IntCellValue(v),
          double v => DoubleCellValue(v),
          bool v => BoolCellValue(v),
          DateTime v => DateTimeCellValue(
              year: v.year, month: v.month, day: v.day),
          _ => TextCellValue(value.toString()),
        };
      }
    }

    // Auto-fit column widths
    sheet.setColumnAutoFit(0);

    // Save file
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.xlsx');
    await file.writeAsBytes(excel.encode()!);
    return file;
  }
}
```

---

## Open Files Natively

```dart
Future<void> openFile(File file) async {
  final result = await OpenFilex.open(file.path);
  if (result.type != ResultType.done) {
    getIt<FeedbackService>().showError('Cannot open file: ${result.message}');
  }
}

// Open with specific MIME type
Future<void> openPdf(File file) =>
    OpenFilex.open(file.path, type: 'application/pdf');

Future<void> openExcel(File file) =>
    OpenFilex.open(file.path,
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
```

---

## Download File from URL

```dart
Future<File> downloadFile(String url, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');

  final response = await Dio().download(
    url,
    file.path,
    onReceiveProgress: (received, total) {
      if (total != -1) {
        final progress = received / total;
        downloadProgress.value = progress; // RxDouble for UI
      }
    },
  );

  if (response.statusCode == 200) return file;
  throw Exception('Download failed: ${response.statusCode}');
}
```
