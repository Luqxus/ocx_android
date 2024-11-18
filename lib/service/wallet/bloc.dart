import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offconnectx/repository/wallet_repository.dart';
import 'package:offconnectx/service/wallet/event.dart';
import 'package:offconnectx/service/wallet/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  // repository wallet
  final WalletRepository _walletRepository;

  /// bloc constructor
  WalletBloc(this._walletRepository) : super(WalletInitialState()) {
    //
    /// event handler
    on<AppStartedEvent>(_appStarted);
    on<UnlockWalletEvent>(_unlockWallet);
    on<CreateWalletEvent>(_createWallet);
    on<SecureWalletEvent>(_secureWallet);
  }

  ///app started event handler
  _appStarted(AppStartedEvent event, Emitter emit) async {
    emit(WalletLoadingState());

    final prefs = await SharedPreferences.getInstance();

    if (!await _walletRepository.hasPhrase()) {
      if (!(prefs.getBool('is_first_run') ?? false)) {
        emit(OnBoardingState());
        return;
      }

      emit(NoWalletState());
      return;
    }

    if (!(prefs.getBool('is_wallet_secured') ?? false)) {
      emit(WalletNotSecuredState());
      return;
    }

    emit(UnlockWalletState());
  }

  /// unlock wallet event handlet
  _unlockWallet(UnlockWalletEvent event, Emitter emit) async {
    /// emit loading state
    emit(WalletLoadingState());

    /// check validate pin
    if (await _walletRepository.validPin(event.pin)) {
      /// unlock wallet
      await _walletRepository.unlockWallet(pin: event.pin);

      // emit wallet unlocked state
      emit(WalletUnlockedState());

      return;
    }

    emit(InvalidUnlockPinState());
  }

  /// create wallet event handler
  _createWallet(CreateWalletEvent event, Emitter emit) async {
    emit(WalletLoadingState());

    await _walletRepository.createWallet();

    emit(WalletNotSecuredState());
  }

  _secureWallet(SecureWalletEvent event, Emitter emit) async {
    emit(WalletLoadingState());

    await _walletRepository.secureWallet(pin: event.pin);

    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('is_wallet_secured', true);

    emit(WalletUnlockedState());
  }
}
