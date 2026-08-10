import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumProvider extends ChangeNotifier {
  // ============================================================
  // SharedPreferences Keys
  // ============================================================

  static const String _premiumKey = 'nurverse_premium_active';

  // Future billing infrastructure.
  // These keys remain separate so Google Play Billing can later
  // replace the local development activation without changing
  // the UI/provider contract.
  static const String _productIdKey = 'nurverse_premium_product_id';
  static const String _purchaseDateKey = 'nurverse_premium_purchase_date';

  // ============================================================
  // Premium Product
  // ============================================================

  static const String premiumProductId = 'nurverse_premium_monthly';

  // ============================================================
  // State
  // ============================================================

  bool _isPremium = false;
  bool _isLoading = false;

  String? _productId;
  DateTime? _purchaseDate;

  // ============================================================
  // Getters
  // ============================================================

  bool get isPremium => _isPremium;

  bool get isLoading => _isLoading;

  String? get productId => _productId;

  DateTime? get purchaseDate => _purchaseDate;

  // ============================================================
  // Constructor
  // ============================================================

  PremiumProvider();

  // ============================================================
  // INITIALIZE / RESTORE PREMIUM STATE
  // ============================================================

  Future<void> checkPremiumStatus() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      _isPremium = prefs.getBool(_premiumKey) ?? false;

      _productId = prefs.getString(_productIdKey);

      final String? savedPurchaseDate = prefs.getString(_purchaseDateKey);

      if (savedPurchaseDate != null && savedPurchaseDate.trim().isNotEmpty) {
        _purchaseDate = DateTime.tryParse(savedPurchaseDate);
      } else {
        _purchaseDate = null;
      }
    } catch (_) {
      // Safe fallback.
      _isPremium = false;
      _productId = null;
      _purchaseDate = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============================================================
  // ACTIVATE PREMIUM
  //
  // DEVELOPMENT / TESTING IMPLEMENTATION ONLY.
  //
  // Later Google Play Billing should call the same internal
  // state-update flow after a verified purchase.
  // ============================================================

  Future<void> activatePremium({String productId = premiumProductId}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final DateTime purchaseDate = DateTime.now();

      await prefs.setBool(_premiumKey, true);
      await prefs.setString(_productIdKey, productId);
      await prefs.setString(_purchaseDateKey, purchaseDate.toIso8601String());

      _isPremium = true;
      _productId = productId;
      _purchaseDate = purchaseDate;

      notifyListeners();
    } catch (_) {
      // Keep current in-memory state if persistence fails.
    }
  }

  // ============================================================
  // DEACTIVATE PREMIUM
  //
  // DEVELOPMENT / TESTING ONLY.
  // Do not expose this through normal production UI.
  // ============================================================

  Future<void> deactivatePremium() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_premiumKey, false);
      await prefs.remove(_productIdKey);
      await prefs.remove(_purchaseDateKey);

      _isPremium = false;
      _productId = null;
      _purchaseDate = null;

      notifyListeners();
    } catch (_) {
      // Keep current in-memory state if persistence fails.
    }
  }

  // ============================================================
  // PREMIUM FEATURE GATE
  // ============================================================

  bool canUsePremiumFeature() {
    return _isPremium;
  }

  // ============================================================
  // NAMED FEATURE GATE
  //
  // Ready for individual premium entitlements in the future.
  // ============================================================

  bool canUse(String featureId) {
    if (!_isPremium) {
      return false;
    }

    switch (featureId) {
      case 'premium_themes':
      case 'premium_recitations':
      case 'premium_quran_features':
      case 'cloud_sync':
      case 'advanced_tools':
        return true;

      default:
        return true;
    }
  }

  // ============================================================
  // REQUIRE PREMIUM
  //
  // Simple gate for UI navigation.
  // ============================================================

  bool requirePremium() {
    return _isPremium;
  }

  // ============================================================
  // PREMIUM STATUS LABEL
  // ============================================================

  String get statusLabel {
    return _isPremium ? 'Premium' : 'Free';
  }

  // ============================================================
  // PURCHASE DATE LABEL
  // ============================================================

  String? get purchaseDateIso {
    return _purchaseDate?.toIso8601String();
  }

  // ============================================================
  // DEBUG / TESTING
  //
  // Not connected to normal production UI.
  // ============================================================

  @visibleForTesting
  Future<void> setPremiumForTesting(bool value) async {
    if (value) {
      await activatePremium();
    } else {
      await deactivatePremium();
    }
  }
}
