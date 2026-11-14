import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch wallet overview and balances
  /// GET /api/restaurants/wallet
  Future<WalletDetailsModel> getWallet() async {
    try {
      final response = await _dio.get(ApiConstants.wallet);
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final walletData = data['data'] as Map<String, dynamic>? ?? {};
        appLog("✅ Fetched Wallet: balance=${walletData['currentBalance']}, pending=${walletData['pendingAmount']}");
        return WalletDetailsModel.fromJson(walletData);
      }
      return WalletDetailsModel.initial();
    } on DioException catch (e) {
      appLog("❌ Get Wallet Error: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Get Wallet General Error: $e");
      throw 'An error occurred while fetching wallet details.';
    }
  }

  /// Fetch wallet transactions list
  /// GET /api/restaurants/wallet/transactions?page=1&limit=20
  Future<List<WalletTransactionItem>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (type != null && type.isNotEmpty) 'type': type,
        if (dateFrom != null && dateFrom.isNotEmpty) 'dateFrom': dateFrom,
        if (dateTo != null && dateTo.isNotEmpty) 'dateTo': dateTo,
      };
      final response = await _dio.get(
        ApiConstants.walletTransactions,
        queryParameters: queryParams,
      );
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final txList = data['data']?['transactions'] as List<dynamic>? ?? [];
        appLog("✅ Fetched ${txList.length} wallet transactions");
        return txList
            .map((item) => WalletTransactionItem.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      appLog("❌ Get Wallet Transactions Error: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Get Wallet Transactions General Error: $e");
      throw 'An error occurred while fetching wallet transactions.';
    }
  }
}
