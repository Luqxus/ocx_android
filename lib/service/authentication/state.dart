import 'package:equatable/equatable.dart';
import 'package:offconnectx/utils/authenticate.dart';

class AuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthenticationInitialState extends AuthenticationState {}

class AuthenticationUnauthenticatedState extends AuthenticationState {
  final AuthenticationType type;

  AuthenticationUnauthenticatedState(this.type);

  @override
  List<Object?> get props => [type];
}

class AuthenticationAuthenticatedState extends AuthenticationState {}

class AuthenticationLoadingState extends AuthenticationState {}
