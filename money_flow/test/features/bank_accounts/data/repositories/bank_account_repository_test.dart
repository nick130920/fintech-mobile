import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:money_flow/core/services/api_service.dart';
import 'package:money_flow/features/bank_accounts/data/repositories/bank_account_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const accessToken = 'test-token';
  late BankAccountRepository repository;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({'access_token': accessToken});
    repository = BankAccountRepository();
  });

  tearDown(() {
    ApiService.resetClientForTesting();
  });

  test('setActiveStatus sends the authenticated PATCH contract', () async {
    late http.Request capturedRequest;
    ApiService.setClientForTesting(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      }),
    );

    await repository.setActiveStatus(42, false);

    expect(capturedRequest.method, 'PATCH');
    expect(capturedRequest.url.path, '/api/v1/bank-accounts/42/active');
    expect(capturedRequest.headers['authorization'], 'Bearer $accessToken');
    expect(capturedRequest.headers['content-type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {'is_active': false});
  });

  test('updateBalance sends the authenticated PATCH contract', () async {
    late http.Request capturedRequest;
    ApiService.setClientForTesting(
      MockClient((request) async {
        capturedRequest = request;
        return http.Response('', 204);
      }),
    );

    await repository.updateBalance(42, 123.45);

    expect(capturedRequest.method, 'PATCH');
    expect(capturedRequest.url.path, '/api/v1/bank-accounts/42/balance');
    expect(capturedRequest.headers['authorization'], 'Bearer $accessToken');
    expect(capturedRequest.headers['content-type'], 'application/json');
    expect(jsonDecode(capturedRequest.body), {'balance': 123.45});
  });
}
