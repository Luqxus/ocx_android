abstract class WalletRepository {
  Future<void> createWallet();
  Future<void> unlockWallet({required String pin});
  Future<void> secureWallet({required String pin});
  Future<bool> hasPhrase();
  Future<bool> validPin(String pin);
}
