/// Membungkus respons paginated backend: { items: [...], pagination: {...} }.
class Paginated<T> {
  final List<T> items;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  Paginated({
    required this.items,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final p = Map<String, dynamic>.from(data['pagination'] ?? {});
    return Paginated<T>(
      items: (data['items'] as List?)
              ?.map((e) => itemFromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          <T>[],
      total: (p['total'] ?? 0) as int,
      perPage: (p['per_page'] ?? 0) as int,
      currentPage: (p['current_page'] ?? 1) as int,
      lastPage: (p['last_page'] ?? 1) as int,
    );
  }

  bool get hasMore => currentPage < lastPage;
}
