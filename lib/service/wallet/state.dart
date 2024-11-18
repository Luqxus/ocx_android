import 'package:equatable/equatable.dart';

class WalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InvalidUnlockPinState extends WalletState {}

class WalletUnlockedState extends WalletState {}

class WalletLoadingState extends WalletState {}

class NoWalletState extends WalletState {}

class WalletNotSecuredState extends WalletState {}

class OnBoardingState extends WalletState {}

class WalletInitialState extends WalletState {}

class UnlockWalletState extends WalletState {}
