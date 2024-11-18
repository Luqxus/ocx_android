import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offconnectx/service/authentication/event.dart';
import 'package:offconnectx/service/authentication/state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitialState()) {
    on<AppStartedEvent>(_appStarted);
    on<UnlockEvent>(_unlockWallet);
    on<CreateAccountEvent>(_createAccount);
  }

  _appStarted(AppStartedEvent event, Emitter emit) async {
    // TODO: check if wallet if created
  }

  _unlockWallet(UnlockEvent event, Emitter emit) async {
    // TODO: unlock wallet
  }

  _createAccount(CreateAccountEvent event, Emitter emit) async {
    // TODO: create account/ wallet
  }

  _logout(LogoutEvent event, Emitter emit) async {
    // TODO: logout event
  }
}
