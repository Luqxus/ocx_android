import 'dart:math';

import 'package:crypt/crypt.dart';
import 'package:ether_dart/ether_dart.dart';
import 'package:offconnectx/models/local_account.dart';
import 'package:offconnectx/repository/wallet_repository.dart';
import 'package:offconnectx/store/secure_storage.dart';

const SALT = r'$2b$06$C6UzMDM.H6dfI/f/IKxGhu';

class WalletRepositoryimpl implements WalletRepository {
  LocalAccount? _localAccount;
  final SecureStorage _secureStorage;

  WalletRepositoryimpl(this._secureStorage);

  @override
  Future<void> secureWallet({required String pin}) async {
    /// read memonic phrase from secure storage
    String? phrase = await _secureStorage.getMnemonic();

    final etherDart = EtherDart();

    /// TODO: Verify seed phrase
    // if (phrase != null) {
    //   etherDart.verifyMemonicPhrase(phrase);

    // }

    /// create new [EtherWallet] from phrase
    final etherWallet = etherDart.walletFromMemonicPhrase(phrase!);

    /// create privKey from Hex String
    EthPrivateKey privKey = EthPrivateKey.fromHex(etherWallet!.privateKey!);

    /// generate secure random
    var rng = Random.secure();

    /// create encrypted wallet from privkey, provided pin, and generated secure random
    Wallet wallet = Wallet.createNew(privKey, pin, rng);

    final hash = Crypt.sha256(pin, salt: SALT);

    /// persist wallet to secure storage
    await _secureStorage.persistAccount(
      wallet: wallet.toJson(),
      pin: hash.hash,
    );

    /// create localaccount instance from wallet, balance and transactions
    _localAccount = LocalAccount(
      wallet,
      balance: 0,
      transactions: List.empty(),
    );
  }

  @override
  Future<void> unlockWallet({required String pin}) async {
    /// get wallet, balance
    Map<String, String?> encryptedAccount = await _secureStorage.getAccount();

    /// decrypt wallet
    Wallet wallet = Wallet.fromJson(encryptedAccount['wallet']!, pin);

    /// create local account from wallet, balance, and transactions
    _localAccount = LocalAccount(
      wallet,
      balance: double.parse(encryptedAccount['balance'] ?? "0.00"),
      transactions: List.empty(),
    );
  }

  @override
  Future<void> createWallet() async {
    try {
      ///Create EtherDart without immediate connection
      final etherDart = EtherDart();

      ///Generate memomic phrase (can be called seed phrase (Eg : cow ram pig goat ))
      final memonicPhrase = etherDart.generateMemonicPhrase();

      // persist unsecured memonic phrase
      await _secureStorage.persistMnemonic(memonicPhrase!);

      // persist unsecured mnemonic
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasPhrase() async {
    return await _secureStorage.hasPhrase();
  }

  @override
  Future<bool> validPin(String pin) async {
    String? hashedPin = await _secureStorage.getHashedPin();

    final h = Crypt(hashedPin!);

    return !h.match(pin);
  }
}



 // ///Verify seed phrase
      // if (memonicPhrase != null) {
      //   etherDart.verifyMemonicPhrase(memonicPhrase);
      // }

      // final wallet = etherDart.walletFromMemonicPhrase(memonicPhrase!);

      // EthPrivateKey privKey = EthPrivateKey.fromHex(wallet!.privateKey!);

      // return
