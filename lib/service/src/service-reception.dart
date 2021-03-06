part of or_test_fw;

abstract class Reception {
  static Logger log = new Logger('Test.Reception_Store');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.receptionStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.headers['access-control-allow-origin'] == null &&
          response.headers['Access-Control-Allow-Origin'] == null) {
        fail('No CORS headers on path $uri');
      }
    })).then((_) {
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.Reception.single(Config.receptionStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) => request
          .close()
          .then((HttpClientResponse response) {
        if (response.headers['access-control-allow-origin'] == null &&
            response.headers['Access-Control-Allow-Origin'] == null) {
          fail('No CORS headers on path $uri');
        }
      }));
    });
  }

  /**
   * Test server behaviour when trying to access a resource not associated with
   * a handler.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static Future nonExistingPath(HttpClient client) {
    Uri uri = Uri.parse(
        '${Config.receptionStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) => request
            .close()
            .then((HttpClientResponse response) {
      if (response.statusCode != 404) {
        fail('Expected to received a 404 on path $uri');
      }
    }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
   * Test server behaviour when trying to aquire a reception event object that
   * does not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingReception(Storage.Reception receptionStore) {
    log.info('Checking server behaviour on a non-existing reception.');

    return expect(
        receptionStore.get(-1), throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a reception event object that
   * exists.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static Future existingReception(Storage.Reception receptionStore) {
    const int receptionID = 1;
    log.info('Checking server behaviour on an existing reception.');

    return receptionStore.get(receptionID).then((Model.Reception reception) =>
        expect(reception, isNotNull));
  }

  /**
   * Test server behaviour when trying to aquire a list of reception objects
   *
   * The expected behaviour is that the server should return a list of
   * Reception objects.
   */
  static Future listReceptions(Storage.Reception receptionStore) {
    log.info('Checking server behaviour on list of receptions.');

    return receptionStore.list().then((Iterable<Model.Reception> receptions) {
      expect(receptions, isNotNull);
      expect(receptions, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to create a new reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object.
   *
   * TODO: Cleanup and check creation time is after now().
   */
  static Future create(Storage.Reception receptionStore) {
    Model.Reception reception = Randomizer.randomReception();

    reception.organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore
        .create(reception)
        .then((Model.Reception createdReception) {
      expect(createdReception.ID, greaterThan(Model.Reception.noID));
      expect(reception.addresses, createdReception.addresses);
      expect(reception.alternateNames, createdReception.alternateNames);
      expect(reception.attributes, createdReception.attributes);
      expect(reception.bankingInformation, createdReception.bankingInformation);
      expect(reception.customerTypes, createdReception.customerTypes);
      expect(reception.emailAddresses, createdReception.emailAddresses);
      expect(reception.dialplan, createdReception.dialplan);
      expect(reception.extraData, createdReception.extraData);
      expect(reception.fullName, createdReception.fullName);
      expect(reception.greeting, createdReception.greeting);
      expect(reception.handlingInstructions,
          createdReception.handlingInstructions);
      expect(reception.openingHours, createdReception.openingHours);
      expect(reception.otherData, createdReception.otherData);
      expect(reception.product, createdReception.product);
      expect(reception.salesMarketingHandling,
          createdReception.salesMarketingHandling);
      expect(reception.shortGreeting, createdReception.shortGreeting);
      expect(reception.telephoneNumbers, createdReception.telephoneNumbers);
      expect(reception.vatNumbers, createdReception.vatNumbers);
      expect(reception.websites, createdReception.websites);
      expect(reception.fullName, createdReception.fullName);

      return receptionStore.remove(createdReception.ID);
    });
  }

  /**
   * Test server behaviour when trying to update a reception object that
   * do not exists.
   *
   * The expected behaviour is that the server should return Not Found error
   */
  static Future updateNonExisting(Storage.Reception receptionStore) {
    return receptionStore.list().then((Iterable<Model.Reception> orgs) {

      // Update the last event in list.
      Model.Reception reception = orgs.last;
      reception.ID = -1;

      return expect(receptionStore.update(reception),
          throwsA(new isInstanceOf<Storage.NotFound>()));
    });
  }

  /**
   * Test server behaviour when trying to update a reception object that
   * exists but with invalid data.
   *
   * The expected behaviour is that the server should return Server Error
   */
  static Future updateInvalid(Storage.Reception receptionStore) {
    return receptionStore.list().then((Iterable<Model.Reception> receptions) {

      // Update the last event in list.
      Model.Reception reception = receptions.last;
      reception.fullName = null;

      return expect(receptionStore.update(reception),
          throwsA(new isInstanceOf<Storage.ServerError>()));
    });
  }

  /**
   * Test server behaviour when trying to update a reception event object that
   * exists.
   *
   * The expected behaviour is that the server should return the updated
   * Reception object.
   */
  static Future update(Storage.Reception receptionStore) {

    return receptionStore
            .create(Randomizer.randomReception())
            .then((Model.Reception createdReception) {

      log.info('Created reception ${createdReception.asMap}');
      {
        Model.Reception randOrg = Randomizer.randomReception();
        log.info('Updating with info ${randOrg.asMap}');

        randOrg.ID = createdReception.ID;
        randOrg.organizationId = createdReception.organizationId;
        randOrg.lastChecked = createdReception.lastChecked;
        createdReception = randOrg;
      }
      return receptionStore
          .update(createdReception)
          .then((Model.Reception updatedReception) {
        expect(updatedReception.ID, greaterThan(Model.Reception.noID));
        expect(updatedReception.ID, equals(createdReception.ID));
        expect(createdReception.addresses, updatedReception.addresses);
        expect(createdReception.alternateNames, updatedReception.alternateNames);
        expect(createdReception.attributes, updatedReception.attributes);
        expect(
createdReception.bankingInformation, updatedReception.bankingInformation);
        expect(createdReception.customerTypes, updatedReception.customerTypes);
        expect(createdReception.emailAddresses, updatedReception.emailAddresses);
        expect(createdReception.dialplan, updatedReception.dialplan);
        expect(createdReception.extraData, updatedReception.extraData);
        expect(createdReception.fullName, updatedReception.fullName);
        expect(createdReception.greeting, updatedReception.greeting);
        expect(createdReception.handlingInstructions,
            updatedReception.handlingInstructions);
        //TODO: Update this one to greaterThan when the resolution of timestamps in the system has increased.
        expect(updatedReception.lastChecked.millisecondsSinceEpoch,
            greaterThanOrEqualTo(createdReception.lastChecked.millisecondsSinceEpoch));
        expect(createdReception.openingHours, updatedReception.openingHours);
        expect(createdReception.otherData, updatedReception.otherData);
        expect(createdReception.product, updatedReception.product);
        expect(createdReception.salesMarketingHandling,
            updatedReception.salesMarketingHandling);
        expect(createdReception.shortGreeting, updatedReception.shortGreeting);
        expect(createdReception.telephoneNumbers, updatedReception.telephoneNumbers);
        expect(createdReception.vatNumbers, updatedReception.vatNumbers);
        expect(createdReception.websites, updatedReception.websites);
        expect(createdReception.fullName, updatedReception.fullName);

        return receptionStore.remove(createdReception.ID);
      });
    });
  }

  /**
   * Test server behaviour when trying to delete an reception that exists.
   *
   * The expected behaviour is that the server should succeed.
   */
  static Future remove(Storage.Reception receptionStore) {
    Model.Reception reception = Randomizer.randomReception()
      ..organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore.create(reception).then(
        (Model.Reception createdReception) => receptionStore
            .remove(createdReception.ID)
            .then((_) {
      return expect(receptionStore.get(reception.ID),
          throwsA(new isInstanceOf<Storage.NotFound>()));
    }));
  }

  /**
   * Test server behaviour when trying to create a new reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object and send out a ReceptionChange notification.
   */
  static Future createEvent(
      Storage.Reception receptionStore, Receptionist receptionist) {
    Model.Reception reception = Randomizer.randomReception();
    reception.organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore.create(reception).then(
        (Model.Reception createdReception) => receptionist
            .waitFor(eventType: Event.Key.receptionChange)
            .then((Event.ReceptionChange event) {
      expect(event.receptionID, equals(createdReception.ID));
      expect(event.state, equals(Event.ReceptionState.CREATED));
    }));
  }

  /**
   * Test server behaviour when trying to update an reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object and send out a ReceptionChange notification.
   */
  static Future updateEvent(
      Storage.Reception receptionStore, Receptionist receptionist) {
    return receptionStore.list().then((Iterable<Model.Reception> orgs) {

      // Update the last event in list.
      Model.Reception reception = orgs.last;

      log.info('Got reception ${reception.asMap}');

      return receptionStore.update(reception).then(
          (Model.Reception updatedReception) => receptionist
              .waitFor(eventType: Event.Key.receptionChange)
              .then((Event.ReceptionChange event) {
        expect(event.receptionID, equals(updatedReception.ID));
        expect(event.state, equals(Event.ReceptionState.UPDATED));
      }));
    });
  }

  /**
   * Test server behaviour when trying to delete an reception.
   *
   * The expected behaviour is that the server should return the created
   * Reception object and send out a ReceptionChange notification.
   */
  static Future deleteEvent(
      Storage.Reception receptionStore, Receptionist receptionist) {
    Model.Reception reception = Randomizer.randomReception()
      ..organizationId = 1;

    log.info('Creating a new reception ${reception.asMap}');

    return receptionStore
        .create(reception)
        .then((Model.Reception createdReception) {
      return receptionist
          .waitFor(eventType: Event.Key.receptionChange)
          .then((_) => receptionist.eventStack.clear())
          .then((_) => receptionStore.remove(createdReception.ID).then((_) {
        return receptionist
            .waitFor(eventType: Event.Key.receptionChange)
            .then((Event.ReceptionChange event) {
          expect(event.receptionID, equals(createdReception.ID));
          expect(event.state, equals(Event.ReceptionState.DELETED));
        });
      }));
    });
  }

  /**
   * Test server behaviour when trying to aquire a reception event object that
   * exists using its extension as key.
   *
   * The expected behaviour is that the server should return the
   * Reception object.
   */
  static Future byExtension(Storage.Reception receptionStore) async {
    log.info('byExtension test starting.');
    const String extension = '12340001';
    log.info('byExtension: Looking up reception with extension $extension');

    final  Model.Reception reception =
        await receptionStore.getByExtension(extension);

    expect(reception, isNotNull);
    log.info('byExtension test done.');
  }

  /**
   * Test server behaviour when trying to aquire the reception extenion of a
   * reception that exists.
   *
   * The expected behaviour is that the server should return the the extension.
   */
  static Future extensionOf(Storage.Reception receptionStore) async {
    log.info('extensionOf test starting.');
    const int receptionId = 1;
    final String expectedExtension = '1234000$receptionId';
    log.info('extensionOf: Looking up extension of reception with id $receptionId');

    final String extension = await receptionStore.extensionOf(receptionId);

    expect(extension, expectedExtension);
    log.info('extensionOf test done.');
  }


}
