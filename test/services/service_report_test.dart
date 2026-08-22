import 'dart:io';

import 'package:eureka/interfaces/repository_report.dart';
import 'package:eureka/models/model_report.dart';
import 'package:eureka/services/service_report.dart';
import 'package:eureka/services/service_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;
  late UserService userService;

  setUpAll(() async {
    tempDirectory = Directory.systemTemp.createTempSync('eureka_report_test_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('user_report_test');
    userService = UserService(box);
  });

  tearDownAll(() async {
    await Hive.close();
    tempDirectory.deleteSync(recursive: true);
  });

  test('não envia relatório vazio sem motivos nem detalhes', () async {
    final fakeRepo = _MockReportRepository();
    final service = ReportService(
      repository: fakeRepo,
      userService: userService,
    );

    final success = await service.sendReport(reasons: const [], details: '   ');

    expect(success, isFalse);
    expect(fakeRepo.submittedReports, isEmpty);
  });

  test('envia relatório com motivos e persiste no repositório', () async {
    final fakeRepo = _MockReportRepository();
    final service = ReportService(
      repository: fakeRepo,
      userService: userService,
    );

    final success = await service.sendReport(
      reasons: const [
        'O áudio parece incorreto',
        'Conteúdo com erro de escrita.',
      ],
      details: 'Texto na questão 2 tem erro de grafia.',
      lessonId: 'math_lesson_1',
      lessonTitle: 'Frações',
      questionId: 'q_123',
      questionPrompt: 'Qual é a fração?',
      subjectId: 'mathematics',
      pageNumber: 2,
    );

    expect(success, isTrue);
    expect(fakeRepo.submittedReports.length, 1);
    final report = fakeRepo.submittedReports.first;
    expect(report.reasons, [
      'O áudio parece incorreto',
      'Conteúdo com erro de escrita.',
    ]);
    expect(report.details, 'Texto na questão 2 tem erro de grafia.');
    expect(report.lessonId, 'math_lesson_1');
    expect(report.lessonTitle, 'Frações');
    expect(report.questionId, 'q_123');
    expect(report.questionPrompt, 'Qual é a fração?');
    expect(report.subjectId, 'mathematics');
    expect(report.pageNumber, 2);
    expect(report.status, 'pending');
  });

  test('ReportModel converte de/para Map corretamente', () {
    final now = DateTime.now();
    final model = ReportModel(
      id: 'rep_1',
      userId: 'user_1',
      reasons: const ['Outro erro.'],
      details: 'Algo estranho',
      lessonId: 'l1',
      createdAt: now,
    );

    final map = model.toMap();
    expect(map['id'], 'rep_1');
    expect(map['userId'], 'user_1');
    expect(map['reasons'], ['Outro erro.']);
    expect(map['details'], 'Algo estranho');
    expect(map['lessonId'], 'l1');
    expect(map['status'], 'pending');

    final parsed = ReportModel.fromMap(map);
    expect(parsed.id, model.id);
    expect(parsed.userId, model.userId);
    expect(parsed.reasons, model.reasons);
    expect(parsed.details, model.details);
    expect(parsed.lessonId, model.lessonId);
  });
}

class _MockReportRepository implements ReportRepository {
  final List<ReportModel> submittedReports = [];

  @override
  Future<void> submitReport(ReportModel report) async {
    submittedReports.add(report);
  }
}
