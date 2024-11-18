import 'package:equatable/equatable.dart';

class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStartedEvent extends AuthenticationEvent {}

class UnlockEvent extends AuthenticationEvent {
  final String pin;

  UnlockEvent(this.pin);

  @override
  List<Object?> get props => [pin];
}

class CreateAccountEvent extends AuthenticationEvent {}

class LogoutEvent extends AuthenticationEvent {}
