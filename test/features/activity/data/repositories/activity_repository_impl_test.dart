import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splito_flutter/core/errors/exceptions.dart';
import 'package:splito_flutter/features/activity/data/datasources/activity_local_datasource.dart';
import 'package:splito_flutter/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:splito_flutter/features/activity/data/models/activity_item_model.dart';
import 'package:splito_flutter/features/activity/data/repositories/activity_repository_impl.dart';

class MockIActivityRemoteDatasource extends Mock implements IActivityRemoteDatasource {}
class MockIActivityLocalDatasource extends Mock implements IActivityLocalDatasource {}

void main() {
  late MockIActivityRemoteDatasource mockRemote;
  late MockIActivityLocalDatasource mockLocal;
  late ActivityRepositoryImpl repository;

  const tModel = ActivityItemModel(
    type: 'EXPENSE_CREATED',
    actor: 'Mandeep Singh',
    createdAt: '2026-01-01T00:00:00Z',
  );

  setUp(() {
    mockRemote = MockIActivityRemoteDatasource();
    mockLocal = MockIActivityLocalDatasource();
    repository = ActivityRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('getGroupActivities', () {
    test('fetches remote, caches, returns ActivityFeed', () async {
      when(() => mockRemote.getGroupActivities(groupId: 'group-1'))
          .thenAnswer((_) async => [tModel]);
      when(() => mockLocal.cacheActivities(
            groupId: 'group-1',
            items: [tModel],
          )).thenAnswer((_) async {});

      final result = await repository.getGroupActivities(groupId: 'group-1', page: 1);

      expect(result.items.first.type, equals('EXPENSE_CREATED'));
      verify(() => mockRemote.getGroupActivities(groupId: 'group-1')).called(1);
      verify(() => mockLocal.cacheActivities(
            groupId: 'group-1',
            items: [tModel],
          )).called(1);
    });

    test('returns cached feed on NetworkException', () async {
      when(() => mockRemote.getGroupActivities(groupId: 'group-1'))
          .thenThrow(const NetworkException('No connection'));
      when(() => mockLocal.getCachedActivities('group-1'))
          .thenAnswer((_) async => [tModel]);

      final result = await repository.getGroupActivities(groupId: 'group-1', page: 1);

      expect(result.items.length, equals(1));
      expect(result.items.first.actorName, equals('Mandeep Singh'));
      // hasMore is false since totalPages: 1
      expect(result.page < result.totalPages, isFalse);
    });

    test('throws when remote fails and cache empty', () async {
      when(() => mockRemote.getGroupActivities(groupId: 'group-1'))
          .thenThrow(const NetworkException('No connection'));
      when(() => mockLocal.getCachedActivities('group-1'))
          .thenAnswer((_) async => null);

      expect(
        () => repository.getGroupActivities(groupId: 'group-1', page: 1),
        throwsA(isA<NetworkException>()),
      );
    });

    test('description derived correctly in cached path', () async {
      const tCachedModel = ActivityItemModel(
        type: 'SETTLEMENT_RECORDED',
        actor: 'Rahul',
        createdAt: '2026-01-01T00:00:00Z',
      );

      when(() => mockRemote.getGroupActivities(groupId: 'group-1'))
          .thenThrow(const NetworkException('No connection'));
      when(() => mockLocal.getCachedActivities('group-1'))
          .thenAnswer((_) async => [tCachedModel]);

      final result = await repository.getGroupActivities(groupId: 'group-1', page: 1);

      expect(result.items.first.description, contains('Rahul'));
    });
  });
}
