/// Paket tryout berbayar (dari GET /packages).
class Package {
  final int id;
  final String name;
  final String? description;
  final int priceMonthly;
  final int priceYearly;
  final int durationDays;
  final List<String> features;
  final bool isPopular;

  Package({
    required this.id,
    required this.name,
    this.description,
    required this.priceMonthly,
    required this.priceYearly,
    required this.durationDays,
    required this.features,
    required this.isPopular,
  });

  bool get isFree => priceMonthly == 0 && priceYearly == 0;

  int priceFor(bool yearly) => yearly ? priceYearly : priceMonthly;

  factory Package.fromJson(Map<String, dynamic> j) => Package(
        id: j['id'] as int,
        name: j['name'] as String,
        description: j['description'] as String?,
        priceMonthly: (j['price_monthly'] ?? 0) as int,
        priceYearly: (j['price_yearly'] ?? 0) as int,
        durationDays: (j['duration_days'] ?? 30) as int,
        features: ((j['features'] as List?) ?? []).map((e) => e.toString()).toList(),
        isPopular: (j['is_popular'] ?? false) as bool,
      );
}
