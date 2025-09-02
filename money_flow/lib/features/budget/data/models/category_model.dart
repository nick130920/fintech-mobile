import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final int id;
  final String name;
  final String description;
  @JsonKey(fromJson: _iconFromJson, toJson: _iconToJson)
  final IconData icon;
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color color;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'is_user_category')
  final bool isUserCategory;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'can_be_deleted')
  final bool canBeDeleted;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.displayName,
    required this.isActive,
    required this.isDefault,
    required this.isUserCategory,
    required this.sortOrder,
    required this.canBeDeleted,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
  
  // Helper methods para UI
  IconData get iconData => icon;

  bool get isSystemCategory => isDefault && !isUserCategory;

  @override
  String toString() => displayName.isNotEmpty ? displayName : name;

  // Categorías predefinidas para la configuración inicial
  static List<CategoryModel> get defaultCategories => [
        const CategoryModel(
          id: 1,
          name: 'Alimentación',
          description: 'Comida, supermercado, restaurantes',
          icon: Icons.restaurant,
          color: Color(0xFFFF6B35),
          displayName: '🍽️ Alimentación',
          isActive: true,
          isDefault: true,
          isUserCategory: false,
          sortOrder: 1,
          canBeDeleted: false,
        ),
        const CategoryModel(
          id: 2,
          name: 'Transporte',
          description: 'Gasolina, transporte público, Uber',
          icon: Icons.directions_car,
          color: Color(0xFF4ECDC4),
          displayName: '🚗 Transporte',
          isActive: true,
          isDefault: true,
          isUserCategory: false,
          sortOrder: 2,
          canBeDeleted: false,
        ),
        const CategoryModel(
          id: 3,
          name: 'Ocio',
          description: 'Entretenimiento, cine, salidas',
          icon: Icons.sports_esports,
          color: Color(0xFF45B7D1),
          displayName: '🎭 Ocio',
          isActive: true,
          isDefault: true,
          isUserCategory: false,
          sortOrder: 3,
          canBeDeleted: false,
        ),
        const CategoryModel(
          id: 4,
          name: 'Servicios',
          description: 'Luz, agua, internet, teléfono',
          icon: Icons.home,
          color: Color(0xFF96CEB4),
          displayName: '🏠 Servicios',
          isActive: true,
          isDefault: true,
          isUserCategory: false,
          sortOrder: 4,
          canBeDeleted: false,
        ),
        const CategoryModel(
          id: 5,
          name: 'Salud',
          description: 'Médico, medicinas, seguros',
          icon: Icons.healing,
          color: Color(0xFFFFEAA7),
          displayName: '⚕️ Salud',
          isActive: true,
          isDefault: true,
          isUserCategory: false,
          sortOrder: 5,
          canBeDeleted: false,
        ),
        const CategoryModel(
          id: 6,
          name: 'Compras',
          description: 'Ropa, electrónicos, compras varias',
          icon: Icons.shopping_bag,
          color: Color(0xFFDDA0DD),
          displayName: '🛍️ Compras',
          isActive: true,
          isDefault: true,
          isUserCategory: false,
          sortOrder: 6,
          canBeDeleted: false,
        ),
        const CategoryModel(
          id: 8,
          name: 'Otros',
          description: 'Gastos varios no clasificados',
          icon: Icons.category,
          color: Color(0xFFFDCB6E),
          displayName: '💼 Otros',
          isActive: true,
          isDefault: true,
          isUserCategory: false,
          sortOrder: 8,
          canBeDeleted: false,
        ),
      ];

  // Porcentajes sugeridos por defecto
  static Map<int, double> get defaultPercentages => {
    1: 35.0, // Alimentación - 35%
    2: 20.0, // Transporte - 20%
    3: 15.0, // Ocio - 15%
    4: 20.0, // Servicios - 20%
    5: 5.0,  // Salud - 5%
    6: 3.0,  // Compras - 3%
    8: 2.0,  // Otros - 2%
  };
}

// Funciones para serialización de IconData y Color
IconData _iconFromJson(Map<String, dynamic> json) {
  return IconData(
    json['codePoint'] as int,
    fontFamily: json['fontFamily'] as String? ?? 'MaterialIcons',
  );
}

Map<String, dynamic> _iconToJson(IconData icon) => <String, dynamic>{
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
    };

Color _colorFromJson(String hexColor) =>
    Color(int.parse(hexColor.replaceFirst('#', '0xFF')));

String _colorToJson(Color color) =>
    '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8)}';
