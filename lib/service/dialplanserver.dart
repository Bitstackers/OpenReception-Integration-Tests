part of or_test_fw;

runDialplanTests() {
  group('Service.Dialplan', () {
    Transport.Client transport = null;
    Service.RESTDialplanStore rdpStore = null;
    Service.RESTReceptionStore receptionStore = null;

    test(
        'CORS headers present (existingUri)',
        () => isCORSHeadersPresent(
            Resource.ReceptionDialplan.list(Config.dialplanStoreUri)));

    test(
        'CORS headers present (non-existingUri)',
        () => isCORSHeadersPresent(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath')));

    test(
        'Non-existing path',
        () => nonExistingPath(
            Uri.parse('${Config.dialplanStoreUri}/nonexistingpath'
                '?token=${Config.serverToken}')));

    setUp(() {
      transport = new Transport.Client();
      rdpStore = new Service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      rdpStore = null;
      transport.client.close(force: true);
    });

    test('create', () => ReceptionDialplanStore.create(rdpStore));

    test('get', () => ReceptionDialplanStore.get(rdpStore));

    test('list', () => ReceptionDialplanStore.list(rdpStore));

    test('remove', () => ReceptionDialplanStore.remove(rdpStore));

    test('update', () => ReceptionDialplanStore.update(rdpStore));

    setUp(() {
      transport = new Transport.Client();
      rdpStore = new Service.RESTDialplanStore(
          Config.dialplanStoreUri, Config.serverToken, transport);
      receptionStore = new Service.RESTReceptionStore(
          Config.receptionStoreUri, Config.serverToken, transport);
    });

    tearDown(() {
      rdpStore = null;
      receptionStore = null;
      transport.client.close(force: true);
    });

    test('deploy',
        () => ReceptionDialplanStore.deploy(rdpStore, receptionStore));
  });
}
