import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:try_out_bayog/core/ui/ui.dart';
import 'package:try_out_bayog/models/exam.dart';
import 'package:try_out_bayog/features/shell/presentation/widgets/exam_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('StatCard menampilkan value & label', (tester) async {
    await tester.pumpWidget(_wrap(const StatCard(icon: Icons.star, value: '42', label: 'Skor')));
    expect(find.text('42'), findsOneWidget);
    expect(find.text('Skor'), findsOneWidget);
  });

  testWidgets('StatusBadge menampilkan label', (tester) async {
    await tester.pumpWidget(_wrap(const StatusBadge(label: 'Lulus', tone: BadgeTone.success)));
    expect(find.text('Lulus'), findsOneWidget);
  });

  testWidgets('ScoreBar menampilkan skor/maks & ikon lulus', (tester) async {
    await tester.pumpWidget(_wrap(const ScoreBar(label: 'TWK', score: 80, max: 100, passingGrade: 65)));
    expect(find.text('TWK'), findsOneWidget);
    expect(find.text('80 / 100'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget); // 80 >= 65 → lulus
  });

  testWidgets('AnswerOption menampilkan label+teks dan memanggil onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(AnswerOption(
      label: 'A',
      text: 'Jawaban A',
      onTap: () => tapped = true,
    )));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Jawaban A'), findsOneWidget);
    await tester.tap(find.text('Jawaban A'));
    expect(tapped, isTrue);
  });

  testWidgets('QuestionNumber menampilkan nomor & bisa ditekan', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(QuestionNumber(
      number: 7,
      status: QNumStatus.answered,
      onTap: () => tapped = true,
    )));
    expect(find.text('7'), findsOneWidget);
    await tester.tap(find.byType(QuestionNumber));
    expect(tapped, isTrue);
  });

  testWidgets('ContentWidth membatasi lebar maksimum', (tester) async {
    await tester.pumpWidget(_wrap(
      const ContentWidth(maxWidth: 400, child: SizedBox(height: 10, width: double.infinity)),
    ));
    final box = tester.widget<ConstrainedBox>(find.descendant(
      of: find.byType(ContentWidth),
      matching: find.byType(ConstrainedBox),
    ).first);
    expect(box.constraints.maxWidth, 400);
  });

  group('ExamTile', () {
    Exam exam({bool premium = false, String mode = 'tryout'}) => Exam(
          id: '1',
          nomorSesi: 'S1',
          namaSesi: 'Tryout SKD #1',
          durasiMenit: 100,
          urutanSoal: 'acak',
          isPublished: true,
          mode: mode,
          isPremium: premium,
        );

    testWidgets('menampilkan nama & durasi', (tester) async {
      await tester.pumpWidget(_wrap(ExamTile(exam: exam(), onTap: () {})));
      expect(find.text('Tryout SKD #1'), findsOneWidget);
      expect(find.text('100 mnt'), findsOneWidget);
    });

    testWidgets('locked menampilkan ikon gembok & badge Premium', (tester) async {
      await tester.pumpWidget(_wrap(ExamTile(exam: exam(premium: true), onTap: () {}, locked: true)));
      expect(find.text('Premium'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    });
  });
}
