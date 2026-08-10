import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  // ============================================================
  // NISAB
  // ============================================================

  static const double goldNisabGrams = 87.48;
  static const double silverNisabGrams = 612.36;

  bool _useSilverNisab = true;

  // ============================================================
  // ASSET CONTROLLERS
  // ============================================================

  final TextEditingController _cashController = TextEditingController();

  final TextEditingController _bankController = TextEditingController();

  final TextEditingController _goldWeightController = TextEditingController();

  final TextEditingController _goldPriceController = TextEditingController();

  final TextEditingController _silverWeightController = TextEditingController();

  final TextEditingController _silverPriceController = TextEditingController();

  final TextEditingController _businessController = TextEditingController();

  final TextEditingController _receivableController = TextEditingController();

  final TextEditingController _investmentController = TextEditingController();

  // ============================================================
  // LIABILITIES
  // ============================================================

  final TextEditingController _debtController = TextEditingController();

  final TextEditingController _duePaymentController = TextEditingController();

  // ============================================================
  // HELPERS
  // ============================================================

  double _parse(TextEditingController controller) {
    return double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0;
  }

  double get _cash => _parse(_cashController);

  double get _bank => _parse(_bankController);

  double get _goldWeight => _parse(_goldWeightController);

  double get _goldPrice => _parse(_goldPriceController);

  double get _silverWeight => _parse(_silverWeightController);

  double get _silverPrice => _parse(_silverPriceController);

  double get _business => _parse(_businessController);

  double get _receivable => _parse(_receivableController);

  double get _investment => _parse(_investmentController);

  double get _debt => _parse(_debtController);

  double get _duePayment => _parse(_duePaymentController);

  // ============================================================
  // CALCULATIONS
  // ============================================================

  double get _goldValue {
    return _goldWeight * _goldPrice;
  }

  double get _silverValue {
    return _silverWeight * _silverPrice;
  }

  double get _totalAssets {
    return _cash +
        _bank +
        _goldValue +
        _silverValue +
        _business +
        _receivable +
        _investment;
  }

  double get _totalLiabilities {
    return _debt + _duePayment;
  }

  double get _netZakatableWealth {
    final result = _totalAssets - _totalLiabilities;

    if (result < 0) {
      return 0;
    }

    return result;
  }

  double get _nisabValue {
    if (_useSilverNisab) {
      return silverNisabGrams * _silverPrice;
    }

    return goldNisabGrams * _goldPrice;
  }

  bool get _eligible {
    if (_nisabValue <= 0) {
      return false;
    }

    return _netZakatableWealth >= _nisabValue;
  }

  double get _zakatAmount {
    if (!_eligible) {
      return 0;
    }

    return _netZakatableWealth * 0.025;
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    _goldWeightController.dispose();
    _goldPriceController.dispose();
    _silverWeightController.dispose();
    _silverPriceController.dispose();
    _businessController.dispose();
    _receivableController.dispose();
    _investmentController.dispose();
    _debtController.dispose();
    _duePaymentController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'যাকাত ক্যালকুলেটর',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'রিসেট',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetCalculator,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(context),

            const SizedBox(height: 18),

            _buildNisabCard(context),

            const SizedBox(height: 22),

            _buildSectionHeader(
              context,
              icon: Icons.payments_outlined,
              title: 'নগদ ও সঞ্চয়',
            ),

            const SizedBox(height: 10),

            _buildMoneyField(
              context,
              controller: _cashController,
              label: 'হাতে থাকা নগদ টাকা',
              hint: 'উদাহরণ: 50000',
              icon: Icons.account_balance_wallet_outlined,
            ),

            _buildMoneyField(
              context,
              controller: _bankController,
              label: 'ব্যাংক / মোবাইল ব্যাংকিং',
              hint: 'উদাহরণ: 150000',
              icon: Icons.account_balance_outlined,
            ),

            _buildMoneyField(
              context,
              controller: _investmentController,
              label: 'বিনিয়োগ / শেয়ার',
              hint: 'বর্তমান মূল্য',
              icon: Icons.trending_up_rounded,
            ),

            const SizedBox(height: 18),

            _buildSectionHeader(
              context,
              icon: Icons.diamond_outlined,
              title: 'স্বর্ণ ও রৌপ্য',
            ),

            const SizedBox(height: 10),

            _buildMetalCard(
              context,
              title: 'স্বর্ণ',
              subtitle: 'ওজন ও বর্তমান প্রতি গ্রাম মূল্য',
              icon: Icons.diamond_outlined,
              weightController: _goldWeightController,
              priceController: _goldPriceController,
              weightLabel: 'স্বর্ণের ওজন (গ্রাম)',
              priceLabel: 'প্রতি গ্রাম দাম',
              calculatedValue: _goldValue,
            ),

            const SizedBox(height: 12),

            _buildMetalCard(
              context,
              title: 'রৌপ্য',
              subtitle: 'ওজন ও বর্তমান প্রতি গ্রাম মূল্য',
              icon: Icons.circle_outlined,
              weightController: _silverWeightController,
              priceController: _silverPriceController,
              weightLabel: 'রৌপ্যের ওজন (গ্রাম)',
              priceLabel: 'প্রতি গ্রাম দাম',
              calculatedValue: _silverValue,
            ),

            const SizedBox(height: 18),

            _buildSectionHeader(
              context,
              icon: Icons.storefront_outlined,
              title: 'ব্যবসা ও পাওনা',
            ),

            const SizedBox(height: 10),

            _buildMoneyField(
              context,
              controller: _businessController,
              label: 'ব্যবসার পণ্য / স্টক',
              hint: 'বর্তমান বাজারমূল্য',
              icon: Icons.inventory_2_outlined,
            ),

            _buildMoneyField(
              context,
              controller: _receivableController,
              label: 'আপনার পাওনা টাকা',
              hint: 'ফেরত পাওয়ার সম্ভাব্য অর্থ',
              icon: Icons.call_received_outlined,
            ),

            const SizedBox(height: 18),

            _buildSectionHeader(
              context,
              icon: Icons.remove_circle_outline,
              title: 'দায় ও ঋণ',
            ),

            const SizedBox(height: 10),

            _buildMoneyField(
              context,
              controller: _debtController,
              label: 'পরিশোধযোগ্য ঋণ',
              hint: 'প্রযোজ্য স্বল্পমেয়াদি ঋণ',
              icon: Icons.money_off_csred_outlined,
            ),

            _buildMoneyField(
              context,
              controller: _duePaymentController,
              label: 'নিকটবর্তী পরিশোধযোগ্য খরচ',
              hint: 'প্রযোজ্য বকেয়া',
              icon: Icons.receipt_long_outlined,
            ),

            const SizedBox(height: 22),

            _buildCalculationSummary(context),

            const SizedBox(height: 18),

            _buildHawlNote(context),

            const SizedBox(height: 18),

            _buildDisclaimer(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INTRO CARD
  // ============================================================

  Widget _buildIntroCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.calculate_rounded, color: primary, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আপনার যাকাত হিসাব করুন',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'আপনার যাকাতযোগ্য সম্পদ, দায় এবং Nisab-এর ভিত্তিতে আনুমানিক বার্ষিক যাকাত নির্ণয় করুন।',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.55,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: .75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NISAB CARD
  // ============================================================

  Widget _buildNisabCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: primary),
              const SizedBox(width: 9),
              Text(
                'Nisab নির্বাচন',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildNisabOption(
                  context,
                  title: 'রৌপ্য',
                  subtitle: '612.36 g',
                  selected: _useSilverNisab,
                  onTap: () {
                    setState(() {
                      _useSilverNisab = true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNisabOption(
                  context,
                  title: 'স্বর্ণ',
                  subtitle: '87.48 g',
                  selected: !_useSilverNisab,
                  onTap: () {
                    setState(() {
                      _useSilverNisab = false;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 19, color: primary),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _useSilverNisab
                        ? 'রৌপ্য Nisab = 612.36 গ্রাম × প্রতি গ্রাম রৌপ্যের বর্তমান দাম'
                        : 'স্বর্ণ Nisab = 87.48 গ্রাম × প্রতি গ্রাম স্বর্ণের বর্তমান দাম',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),

          if (_nisabValue > 0) ...[
            const SizedBox(height: 12),
            _buildMiniValueRow(
              context,
              'বর্তমান Nisab',
              _formatMoney(_nisabValue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNisabOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: .10) : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected
                      ? primary.withValues(alpha: .35)
                      : primary.withValues(alpha: .08),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color:
                    selected
                        ? primary
                        : theme.iconTheme.color?.withValues(alpha: .45),
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: .60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: primary),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MONEY FIELD
  // ============================================================

  Widget _buildMoneyField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 21),
          prefixText: '৳ ',
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primary.withValues(alpha: .07)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primary.withValues(alpha: .07)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primary.withValues(alpha: .35)),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // METAL CARD
  // ============================================================

  Widget _buildMetalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required TextEditingController weightController,
    required TextEditingController priceController,
    required String weightLabel,
    required String priceLabel,
    required double calculatedValue,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: .60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (calculatedValue > 0)
                Text(
                  _formatMoney(calculatedValue),
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: _buildSmallField(
                  context,
                  controller: weightController,
                  label: weightLabel,
                  suffix: 'g',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallField(
                  context,
                  controller: priceController,
                  label: priceLabel,
                  suffix: '৳',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String suffix,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withValues(alpha: .07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withValues(alpha: .07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withValues(alpha: .35)),
        ),
      ),
    );
  }

  // ============================================================
  // CALCULATION SUMMARY
  // ============================================================

  Widget _buildCalculationSummary(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: primary),
              const SizedBox(width: 9),
              Text(
                'হিসাবের সারাংশ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _buildSummaryRow(
            context,
            'মোট যাকাতযোগ্য সম্পদ',
            _formatMoney(_totalAssets),
          ),

          _buildSummaryRow(
            context,
            'বাদযোগ্য দায়',
            _formatMoney(_totalLiabilities),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: primary.withValues(alpha: .10)),
          ),

          _buildSummaryRow(
            context,
            'নিট যাকাতযোগ্য সম্পদ',
            _formatMoney(_netZakatableWealth),
            bold: true,
          ),

          _buildSummaryRow(context, 'Nisab', _formatMoney(_nisabValue)),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color:
                  _eligible
                      ? primary.withValues(alpha: .10)
                      : theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    _eligible
                        ? primary.withValues(alpha: .18)
                        : primary.withValues(alpha: .06),
              ),
            ),
            child: Column(
              children: [
                Text(
                  _eligible
                      ? 'আপনার আনুমানিক যাকাত'
                      : 'বর্তমানে Nisab পূরণ হয়নি',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        _eligible ? primary : theme.textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _formatMoney(_zakatAmount),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color:
                        _eligible ? primary : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _eligible
                      ? 'নিট সম্পদের ২.৫%'
                      : 'Nisab পূরণ হলে ২.৫% প্রযোজ্য',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: .65,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    String value, {
    bool bold = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: bold ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniValueRow(BuildContext context, String title, String value) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HAWL NOTE
  // ============================================================

  Widget _buildHawlNote(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.calendar_month_outlined, color: primary, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'যাকাতের জন্য সাধারণভাবে Nisab পরিমাণ সম্পদের ওপর এক হিজরি (চন্দ্র) বছর অতিবাহিত হওয়ার বিষয়টি বিবেচনা করা হয়। আপনার ব্যক্তিগত মাজহাব ও পরিস্থিতি অনুযায়ী আলেমের পরামর্শ নিন।',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.55),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISCLAIMER
  // ============================================================

  Widget _buildDisclaimer(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'এটি একটি হিসাব সহায়ক, ফতোয়া নয়। স্বর্ণ/রৌপ্যের মূল্য, ঋণ, ব্যবসায়িক সম্পদ, পাওনা এবং আপনার মাজহাব অনুযায়ী যাকাতের বিধানে পার্থক্য থাকতে পারে। জটিল ক্ষেত্রে যোগ্য আলেমের পরামর্শ নিন।',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.55),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMAT
  // ============================================================

  String _formatMoney(double value) {
    final rounded = value.round();

    final text = rounded.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );

    return '৳ $text';
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetCalculator() {
    for (final controller in [
      _cashController,
      _bankController,
      _goldWeightController,
      _goldPriceController,
      _silverWeightController,
      _silverPriceController,
      _businessController,
      _receivableController,
      _investmentController,
      _debtController,
      _duePaymentController,
    ]) {
      controller.clear();
    }

    setState(() {
      _useSilverNisab = true;
    });
  }
}
