// lib/models/location_item.dart

enum ItemCategory { sightseeing, food, shopping, other }

class LocationItem {
  final String id;
  String name;
  String address;
  String notes;
  ItemCategory category;
  double estimatedCost;
  String costNotes;
  String referenceUrl;

  LocationItem({
    required this.id,
    required this.name,
    this.address = '',
    this.notes = '',
    this.category = ItemCategory.other,
    this.estimatedCost = 0.0,
    this.costNotes = '',
    this.referenceUrl = '',
  });

  // HÀM 1: Chuyển đối tượng thành Map để gửi lên Firestore
  Map<String, dynamic> toMap() {
    return {
      // KHÔNG lưu 'id' ở đây nữa. ID của document sẽ là ID của chúng ta.
      'name': name,
      'address': address,
      'notes': notes,
      'category': category.name, // Lưu enum dưới dạng chuỗi
      'estimatedCost': estimatedCost,
      'costNotes': costNotes,
      'referenceUrl': referenceUrl,
    };
  }

  // HÀM 2: Tạo đối tượng từ Map lấy từ Firestore
  // **HÀM NÀY ĐƯỢC SỬA LẠI ĐỂ NHẬN 2 THAM SỐ**
  factory LocationItem.fromMap(Map<String, dynamic> map, String documentId) {
    return LocationItem(
      id: documentId, // Lấy ID từ tham số thứ hai
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      notes: map['notes'] ?? '',
      category: ItemCategory.values.firstWhere(
            (e) => e.name == map['category'],
        orElse: () => ItemCategory.other,
      ),
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      costNotes: map['costNotes'] ?? '',
      referenceUrl: map['referenceUrl'] ?? '',
    );
  }
}