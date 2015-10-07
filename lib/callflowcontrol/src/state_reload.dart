part of or_test_fw;

abstract class StateReload {
  static Logger log = new Logger('$libraryName.CallFlowControl.UserState');

  static void _validateCallLists(
      Iterable<Model.Call> list1, Iterable<Model.Call> list2) {

    log.info('List 1:\n  ${list1.map((c) => c.toJson()).join('\n  ')}');
    log.info('List 2:\n  ${list2.map((c) => c.toJson()).join('\n  ')}');

    expect(list1.length, equals(list2.length));

    list2.forEach((Model.Call updatedCall) {
      Model.Call originalCall =
          list1.firstWhere((Model.Call c) => c.ID == updatedCall.ID);

      expect(originalCall.arrived.difference(updatedCall.arrived).inMilliseconds
          .abs(), lessThan(1000));
      expect(originalCall.assignedTo, equals(updatedCall.assignedTo));
      expect(originalCall.b_Leg, equals(updatedCall.b_Leg));
      expect(originalCall.callerID, equals(updatedCall.callerID));
      expect(originalCall.channel, equals(updatedCall.channel));
      expect(originalCall.contactID, equals(updatedCall.contactID));
      expect(originalCall.destination, equals(updatedCall.destination));
      expect(originalCall.greetingPlayed, equals(updatedCall.greetingPlayed));
      expect(originalCall.ID, equals(updatedCall.ID));
      expect(originalCall.inbound, equals(updatedCall.inbound));
      expect(originalCall.isActive, equals(updatedCall.isActive));
      expect(originalCall.locked, equals(updatedCall.locked));
      expect(originalCall.receptionID, equals(updatedCall.receptionID));
      expect(originalCall.state, equals(updatedCall.state));
    });
  }

  static Future inboundUnansweredCall(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340001';

    Iterable<Model.Call> orignalCallQueue;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Waiting for the call to be queued'))
        .then((_) => receptionist.waitFor(eventType: Event.Key.queueJoin))
        .then((_) => log.info('Fetching call list'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(1));
            expect(calls.first.assignedTo, equals(Model.User.noID));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future inboundAnsweredCall(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340001';

    Iterable<Model.Call> orignalCallQueue;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist hunt down the call'))
        .then((_) => receptionist.huntNextCall())
        .then((_) => log.info('Receptionist got call'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(1));
            expect(calls.first.assignedTo, equals(receptionist.user.ID));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future inboundParkedCall(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340001';

    Iterable<Model.Call> orignalCallQueue;
    Model.Call assignedCall;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist hunt down the call'))
        .then((_) => receptionist.huntNextCall().then((Model.Call call)
           => assignedCall = call))
        .then((_) => log.info('Receptionist got call'))
        .then((_) => log.info('Receptionist parks call'))
        .then((_) => receptionist.park(assignedCall, waitForEvent: true))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(1));
            expect(calls.first.assignedTo, equals(receptionist.user.ID));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future inboundUnparkedCall(
      Receptionist receptionist, Customer caller) {
    String receptionNumber = '12340001';

    Iterable<Model.Call> orignalCallQueue;
    Model.Call assignedCall;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist hunt down the call'))
        .then((_) => receptionist.huntNextCall().then((Model.Call call)
           => assignedCall = call))
        .then((_) => log.info('Receptionist got call'))
        .then((_) => log.info('Receptionist parks call'))
        .then((_) => receptionist.park(assignedCall, waitForEvent: true))
        .then((_) => log.info('Receptionist picks up call again'))
        .then((_) => receptionist.pickup(assignedCall, waitForEvent: true))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(1));
            expect(calls.first.assignedTo, equals(receptionist.user.ID));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future outboundUnansweredCall (Receptionist receptionist, Customer callee) {
    Iterable<Model.Call> orignalCallQueue;
    Model.Call outboundCall;

    return Future
        .wait([])
        .then((_) => log.info('Receptionist dials the callee at ${callee.extension}'))
        .then((_) => receptionist.originate(callee.extension, 1,2)
          .then((Model.Call call)
            => outboundCall = call))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(1));
            expect(calls.first.assignedTo, equals(receptionist.user.ID));
            expect(calls, contains(outboundCall));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future outboundAnsweredCall (Receptionist receptionist, Customer callee) {
    Iterable<Model.Call> orignalCallQueue;
    Model.Call outboundCall;

    return Future
        .wait([])
        .then((_) => log.info('Receptionist dials the callee at ${callee.extension}'))
        .then((_) => receptionist.originate(callee.extension, 2,3)
          .then((Model.Call call) => outboundCall = call))
        .then((_) => callee.waitForInboundCall())
        .then((_) => callee.pickupCall())
        .then((_) => receptionist.waitFor(eventType: Event.Key.callPickup))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(1));
            expect(calls.first.assignedTo, equals(receptionist.user.ID));
            expect(calls, contains(outboundCall));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }

  static Future transferredCalls
    (Receptionist receptionist, Customer caller, Customer callee) {
    final String receptionNumber = '12340001';

    Iterable<Model.Call> orignalCallQueue;

    Model.Call inboundCall;
    Model.Call outboundCall;

    return Future
        .wait([])
        .then((_) => log.info('Caller dials the reception at $receptionNumber'))
        .then((_) => caller.dial(receptionNumber))
        .then((_) => log.info('Receptionist hunt down the call'))
        .then((_) => receptionist.huntNextCall().then((Model.Call call)
           => inboundCall = call))
        .then((_) => log.info('Receptionist parks call'))
        .then((_) => receptionist.park(inboundCall, waitForEvent: true))
        .then((_) => log.info('Receptionist dials the callee at ${callee.extension}'))
        .then((_) => receptionist.originate(callee.extension, 2,3)
          .then((Model.Call call) => outboundCall = call))
        .then((_) => callee.waitForInboundCall())
        .then((_) => callee.pickupCall())
        .then((_) => receptionist.waitFor(eventType: Event.Key.callPickup, callID: outboundCall.ID))
        .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(2));
            expect(calls.first.assignedTo, equals(receptionist.user.ID));
            expect(calls, contains(outboundCall));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => receptionist.transferCall(outboundCall, inboundCall))
        .then((_) => receptionist.waitFor(eventType: Event.Key.callTransfer))
                .then((_) => log.info('Fetching original call list'))
        .then((_) => receptionist.callFlowControl.callList()
          .then((Iterable<Model.Call> calls) {
            expect(calls.length, equals(2));
            expect(calls.first.assignedTo, equals(receptionist.user.ID));
            expect(calls, contains(outboundCall));
            orignalCallQueue = calls;
          }))
        .then((_) => log.info('Performing state reload'))
        .then((_) => receptionist.callFlowControl.stateReload())
        .then((_) => log.info('Comparing reloaded list with original list'))
        .then((_) => receptionist.callFlowControl
            .callList()
            .then((Iterable<Model.Call> calls) =>
                _validateCallLists(orignalCallQueue, calls)))
        .then((_) => log.info('Test Succeeded'));
  }
}