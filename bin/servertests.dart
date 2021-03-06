import '../lib/or_test_fw.dart';

import 'package:logging/logging.dart';
import 'package:unittest/unittest.dart';
import 'package:junitconfiguration/junitconfiguration.dart';

void main(List<String> arguments) {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord
      .listen((LogRecord record) => logMessage(record.toString()));

  if (!arguments.contains('--no-xml')) {
    JUnitConfiguration.install();
  }
  SupportTools st;

  /*
   * We treat the test framework as a test itself. This gives us the
   * possibility to output the test state, and to wait for setup and teardown.
   */
  group('TestFramework', () {
    setUp(() {
      return SupportTools.instance.then((SupportTools init) => st = init);
    });

    test('Setup', () {
      expect(st, isNotNull);
      expect(st.customers, isNotEmpty);
      expect(st.peerMap, isNotEmpty);
      expect(st.receptionists, isNotEmpty);
      expect(st.tokenMap, isNotEmpty);
      expect(st.tokenMap, isNotEmpty);
    });
  });

  runPeerAccountTests();
  runAuthServerTests();
  runBenchmarkTests();
  runCalendarTests();
  runConfigServerTests();
  runContactTests();
  runCallFlowTests();
  runDialplanTests();
  runDialplanDeploymentTests();
  runUserTests();
  runIvrTests();
  runMessageTests();
  runNotificationTests();
  runOrganizationTests();
  runDatabaseTests();

  runReceptionTests();
  //runUseCaseTests();

  group('TestFramework', () {
    tearDown(() {
      return SupportTools.instance.then((SupportTools st) => st.tearDown());
    });

    test('Teardown', () => true);
  });
}
