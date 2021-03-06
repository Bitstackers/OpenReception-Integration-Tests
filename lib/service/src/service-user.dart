part of or_test_fw;

abstract class User {
  static Logger log = new Logger('$libraryName.User');

  /**
   * Test for the presence of CORS headers.
   */
  static Future isCORSHeadersPresent(HttpClient client) {
    Uri uri = Uri.parse('${Config.userStoreUri}/nonexistingpath');

    log.info('Checking CORS headers on a non-existing URL.');
    return client
        .getUrl(uri)
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.headers['access-control-allow-origin'] == null &&
                  response.headers['Access-Control-Allow-Origin'] == null) {
                fail('No CORS headers on path $uri');
              }
            }))
        .then((_) {
      log.info('Checking CORS headers on an existing URL.');
      uri = Resource.User.single(Config.userStoreUri, 1);
      return client.getUrl(uri).then((HttpClientRequest request) =>
          request.close().then((HttpClientResponse response) {
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
        '${Config.userStoreUri}/nonexistingpath?token=${Config.serverToken}');

    log.info('Checking server behaviour on a non-existing path.');

    return client
        .getUrl(uri)
        .then((HttpClientRequest request) =>
            request.close().then((HttpClientResponse response) {
              if (response.statusCode != 404) {
                fail('Expected to received a 404 on path $uri');
              }
            }))
        .then((_) => log.info('Got expected status code 404.'))
        .whenComplete(() => client.close(force: true));
  }

  /**
   * Test server behaviour when trying to aquire a user object that does
   * not exist.
   *
   * The expected behaviour is that the server should return a Not Found error.
   */
  static void nonExistingUser(Storage.User userStore) {
    log.info('Checking server behaviour on a non-existing user.');

    return expect(
        userStore.get(-1), throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   * Test server behaviour when trying to aquire a user object that exists.
   *
   * The expected behaviour is that the server should return the
   * User object.
   */
  static Future existingUser(Storage.User userStore) async {
    log.info('Checking server behaviour on an existing user.');

    final Model.User createdUser =
        await userStore.create(Randomizer.randomUser());

    final Model.User fetchedUser = await userStore.get(createdUser.ID);

    expect(createdUser.address, equals(fetchedUser.address));
    expect(createdUser.googleAppcode, equals(fetchedUser.googleAppcode));
    expect(createdUser.googleUsername, equals(fetchedUser.googleUsername));
    expect(createdUser.ID, equals(fetchedUser.ID));
    expect(createdUser.name, equals(fetchedUser.name));
    expect(createdUser.peer, equals(fetchedUser.peer));
    expect(createdUser.portrait, equals(fetchedUser.portrait));

    /// Finalization - cleanup.
    await userStore.remove(createdUser.ID);
  }

  /**
   *
   */
  static Future createUser(Storage.User userStore) async {
    log.info('Checking server behaviour on an user creation.');

    final Model.User newUser = Randomizer.randomUser();
    final Model.User createdUser = await userStore.create(newUser);

    expect(createdUser.address, equals(newUser.address));
    expect(createdUser.googleAppcode, equals(newUser.googleAppcode));
    expect(createdUser.googleUsername, equals(newUser.googleUsername));
    expect(createdUser.ID, isNotNull);
    expect(createdUser.ID, greaterThan(Model.User.noID));
    expect(createdUser.name, equals(newUser.name));
    expect(createdUser.peer, equals(newUser.peer));
    expect(createdUser.portrait, equals(newUser.portrait));

    await userStore.remove(createdUser.ID);
  }

  /**
   *
   */
  static Future createUserEvent(
      Storage.User userStore, Receptionist receptionist) {
    log.info('Checking server behaviour on an user creation.');

    Model.User newUser = Randomizer.randomUser();

    return userStore.create(newUser).then((Model.User createdUser) {
      bool eventMatches(Event.Event event) {
        if (event is Event.UserChange) {
          return event.state == Event.UserObjectState.CREATED &&
              event.userID == createdUser.ID;
        }

        return false;
      }

      return receptionist.notificationSocket.eventStream
          .firstWhere(eventMatches)
          .timeout(new Duration(seconds: 10))
          .then((_) => userStore.remove(createdUser.ID));
    });
  }

  /**
   *
   */
  static Future updateUser(Storage.User userStore) {
    log.info('Checking server behaviour on an user updating.');

    return userStore
        .create(Randomizer.randomUser())
        .then((Model.User createdUser) {
      Model.User changedUser = Randomizer.randomUser()..ID = createdUser.ID;

      return userStore.update(changedUser).then((Model.User updatedUser) {
        expect(changedUser.address, equals(updatedUser.address));
        expect(changedUser.googleAppcode, equals(updatedUser.googleAppcode));
        expect(changedUser.googleUsername, equals(updatedUser.googleUsername));
        expect(changedUser.ID, equals(updatedUser.ID));
        expect(changedUser.name, equals(updatedUser.name));
        expect(changedUser.peer, equals(updatedUser.peer));
        expect(changedUser.portrait, equals(updatedUser.portrait));

        return userStore.remove(createdUser.ID);
      });
    });
  }

  /**
   *
   */
  static Future updateUserEvent(
      Storage.User userStore, Receptionist receptionist) async {
    log.info('Checking server behaviour on an user updating.');

    final Model.User createdUser =
        await userStore.create(Randomizer.randomUser());

    final Model.User changedUser = Randomizer.randomUser()..ID = createdUser.ID;

    Future expectedEvent = receptionist.notificationSocket.eventStream
        .firstWhere((event) => event is Event.UserChange &&
            event.userID == createdUser.ID &&
            event.state == Event.UserObjectState.UPDATED);

    await userStore.update(changedUser);
    await expectedEvent.timeout(new Duration(seconds: 10));
  }

  /**
   *
   */
  static Future removeUser(Storage.User userStore) async {
    log.info('Checking server behaviour on an user removal.');

    Model.User createdUser = await userStore.create(Randomizer.randomUser());
    expect(createdUser.ID, greaterThan(Model.User.noID));

    await userStore.remove(createdUser.ID);

    return expect(userStore.get(createdUser.ID),
        throwsA(new isInstanceOf<Storage.NotFound>()));
  }

  /**
   *
   */
  static Future removeUserEvent(
      Storage.User userStore, Receptionist receptionist) async {
    log.info('Checking server behaviour on an user removal.');

    Model.User createdUser = await userStore.create(Randomizer.randomUser());

    expect(createdUser.ID, greaterThan(Model.User.noID));

    Future expectedEvent = receptionist.notificationSocket.eventStream
        .firstWhere((event) => event is Event.UserChange &&
            event.userID == createdUser.ID &&
            event.state == Event.UserObjectState.DELETED);
    await userStore.remove(createdUser.ID);

    return expectedEvent;
  }

  /**
   * Test server behaviour when trying to aquire a list of user objects
   *
   * The expected behaviour is that the server should return a list of
   * User objects.
   */
  static Future listUsers(Storage.User userStore) {
    log.info('Checking server behaviour on list of users.');

    return userStore.list().then((Iterable<Model.User> users) {
      expect(users, isNotNull);
      expect(users, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to list all available groups
   *
   * The expected behaviour is that the server should return a list of
   * UserGroup objects.
   */
  static Future listAllGroups(Storage.User userStore) {
    log.info('Looking up group list.');

    return userStore.groups().then((Iterable<Model.UserGroup> groups) {
      expect(groups, isNotNull);
      expect(groups, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to list all available groups
   *
   * The expected behaviour is that the server should return a list of
   * UserGroup objects.
   */
  static Future listGroupsOfUser(Storage.User userStore) {
    log.info('Looking up group list of user.');

    return userStore.userGroups(2).then((Iterable<Model.UserGroup> groups) {
      expect(groups, isNotNull);
      expect(groups, isNotEmpty);
    });
  }

  /**
   * Test server behaviour when trying to list all available groups
   *
   * The expected behaviour is that the server should return a list of
   * UserGroup objects.
   */
  static Future listGroupsOfNonExistingUser(Storage.User userStore) {
    log.info('Looking up group list of user.');

    return userStore.userGroups(-1).then((Iterable<Model.UserGroup> groups) {
      expect(groups, isNotNull);
      expect(groups, isEmpty);
    });
  }

  /**
   * Add a user to a group.
   */

  static Future joinGroup(Storage.User userStore) async {
    final Model.User createdUser =
        await userStore.create(Randomizer.randomUser());

    expect(await userStore.userGroups(createdUser.ID), isEmpty);

    final Model.UserGroup joinedGroup =
        Randomizer.randomChoice((await userStore.groups()).toList());
    await userStore.joinGroup(createdUser.ID, joinedGroup.id);

    expect(await userStore.userGroups(createdUser.ID), isNotEmpty);
    expect(await userStore.userGroups(createdUser.ID), contains(joinedGroup));

    /// Finalization - cleanup.
    await userStore.remove(createdUser.ID);
  }

  /**
   * Remove a user from a group.
   */

  static Future leaveGroup(Storage.User userStore) async {
    final Model.User createdUser =
        await userStore.create(Randomizer.randomUser());

    expect(await userStore.userGroups(createdUser.ID), isEmpty);

    final Model.UserGroup joinedGroup =
        Randomizer.randomChoice((await userStore.groups()).toList());
    await userStore.joinGroup(createdUser.ID, joinedGroup.id);
    await userStore.leaveGroup(createdUser.ID, joinedGroup.id);

    expect(await userStore.userGroups(createdUser.ID), isEmpty);

    /// Finalization - cleanup.
    await userStore.remove(createdUser.ID);
  }

  /**
   * Add an identity to a user.
   */
  static Future getUserByIdentity(Storage.User userStore) async {
    final Model.User createdUser =
        await userStore.create(Randomizer.randomUser());

    expect(await userStore.identities(createdUser.id), isEmpty);

    Model.UserIdentity identity = new Model.UserIdentity.empty()
      ..identity = Randomizer.randomUserEmail()
      ..userId = createdUser.id;

    await userStore.addIdentity(identity);
    final fetchedUser = await userStore.getByIdentity(identity.identity);
    expect(createdUser.address, equals(fetchedUser.address));
    expect(createdUser.enabled, equals(fetchedUser.enabled));
    expect(createdUser.googleAppcode, equals(fetchedUser.googleAppcode));
    expect(createdUser.googleUsername, equals(fetchedUser.googleUsername));
    expect(createdUser.id, equals(fetchedUser.id));
    expect(createdUser.name, equals(fetchedUser.name));
    expect(createdUser.peer, equals(fetchedUser.peer));
    expect(createdUser.portrait, equals(fetchedUser.portrait));

    /// Finalization - cleanup.
    await userStore.remove(createdUser.ID);
  }

  /**
   * Add an identity to a user.
   */
  static Future addUserIdentity(Storage.User userStore) async {
    final Model.User createdUser =
        await userStore.create(Randomizer.randomUser());

    expect(await userStore.identities(createdUser.ID), isEmpty);

    Model.UserIdentity identity = new Model.UserIdentity.empty()
      ..identity = Randomizer.randomUserEmail()
      ..userId = createdUser.ID;

    await userStore.addIdentity(identity);
    expect(await userStore.identities(createdUser.ID), contains(identity));

    /// Finalization - cleanup.
    await userStore.remove(createdUser.ID);
  }

  /**
   * Remove an identity from a user.
   */
  static Future removeUserIdentity(Storage.User userStore) async {
    final Model.User createdUser =
        await userStore.create(Randomizer.randomUser());

    expect(await userStore.identities(createdUser.ID), isEmpty);
    Model.UserIdentity identity = new Model.UserIdentity.empty()
      ..identity = Randomizer.randomUserEmail()
      ..userId = createdUser.ID;

    await userStore.addIdentity(identity);
    await userStore.removeIdentity(identity);
    expect(await userStore.identities(createdUser.ID), isEmpty);

    /// Finalization - cleanup.
    await userStore.remove(createdUser.ID);
  }

  /**
   *
   */
  static Future stateChange(Service.RESTUserStore userService) async {
    log.info('Checking server behaviour on an user state change.');
    Model.User createdUser = await userService.create(Randomizer.randomUser());

    await userService.userStateReady(createdUser.ID);
    expect((await userService.userStatus(createdUser.ID)).paused, isFalse);
    await userService.userStatePaused(createdUser.ID);
    expect((await userService.userStatus(createdUser.ID)).paused, isTrue);
    await userService.userStateReady(createdUser.ID);
    expect((await userService.userStatus(createdUser.ID)).paused, isFalse);
  }

  /**
   *
   */
  static Future stateChangeEvent(
      Storage.User userStore, Receptionist receptionist) async {
    log.info('Checking server behaviour on an user removal.');

    Model.User createdUser = await userStore.create(Randomizer.randomUser());

    expect(createdUser.ID, greaterThan(Model.User.noID));

    Future expectedEvent = receptionist.notificationSocket.eventStream
        .firstWhere((event) => event is Event.UserChange &&
            event.userID == createdUser.ID &&
            event.state == Event.UserObjectState.DELETED);
    await userStore.remove(createdUser.ID);

    return expectedEvent;
  }
}
