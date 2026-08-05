import 'package:http/http.dart' as http;
import '../providers/wallet_provider.dart';

class WalletRepository {
  final WalletProvider walletProvider;

  WalletRepository(this.walletProvider);

  Future<http.Response> recharge({
    required String method,
    required double amount,
    required String transactionId,
    required String senderNumber,
    String? note,
  }) async {
    return await walletProvider.recharge(
      method: method,
      amount: amount,
      transactionId: transactionId,
      senderNumber: senderNumber,
      note: note,
    );
  }

  Future<http.Response> getWallet() async {
    return await walletProvider.getWallet();
  }

  Future<http.Response> getSubscriptionPlans() async {
    return await walletProvider.getSubscriptionPlans();
  }
}
