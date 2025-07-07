// lib/models/location_item.dart

// Enum để định nghĩa các loại địa điểm
enum ItemCategory { sightseeing, food, shopping, other }

class LocationItem {
  final String id;
  String name;
  String address;
  String notes;
  ItemCategory category;
  double estimatedCost;
  String costNotes;
  String referenceUrl; // Link Google Maps, blog review...

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
}