import 'package:intl/intl.dart';

// The text in these exceptions are for public facing modals.
class UnknownException implements Exception {
  String devDescription;
  UnknownException(this.devDescription);
  String toString() => Intl.message("We're unsure what happened, but we're looking into it.", name: 'unknownException');
}

class ConnectivityException implements Exception {
  String toString() => Intl.message('You are not connected to the internet at this time.', name: 'notConnected');
}

class RetryFailureException implements Exception {
  String toString() => Intl.message('There is a problem with the internet connection, please retry later.', name: 'retryFailure');
}

class UnexpectedResponseException implements Exception {
  String toString() => Intl.message('There is an unexpected issue. Please try again later.', name: 'unexpectedResponseFailure');
}