import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:try_out_bayog/core/api_exception.dart';
import 'package:try_out_bayog/services/attempt_service.dart';
import 'package:try_out_bayog/screens/result_screen.dart';

/// AttemptService palsu yang mensimulasikan backend menolak hasil karena attempt
/// belum selesai (HTTP 409).
class _NotFinishedService extends AttemptService {
  @override
  Future<ResultBundle> result(String attemptId) async {
    throw ApiException('Attempt belum selesai.', statusCode: 409);
  }
}

class _OtherErrorService extends AttemptService {
  @override
  Future<ResultBundle> result(String attemptId) async {
    throw ApiException('Server bermasalah.', statusCode: 500);
  }
}

void main() {
  testWidgets('409 "belum selesai" → tampilkan opsi Lanjutkan Tryout (bukan error buntu)',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResultScreen(attemptId: '1', service: _NotFinishedService()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tryout Belum Selesai'), findsOneWidget);
    expect(find.text('Lanjutkan Tryout'), findsOneWidget);
    // Tidak menampilkan tombol "Coba Lagi" milik error umum.
    expect(find.text('Coba Lagi'), findsNothing);
  });

  testWidgets('error lain tetap memakai Coba Lagi', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResultScreen(attemptId: '1', service: _OtherErrorService()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tryout Belum Selesai'), findsNothing);
    expect(find.text('Coba Lagi'), findsOneWidget);
  });
}
