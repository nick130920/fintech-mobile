import '../../../budget/data/models/category_model.dart';

/// Estados posibles de un viaje
enum TripStatus { planning, active, completed, cancelled }

extension TripStatusX on TripStatus {
  String get apiValue {
    switch (this) {
      case TripStatus.planning:
        return 'planning';
      case TripStatus.active:
        return 'active';
      case TripStatus.completed:
        return 'completed';
      case TripStatus.cancelled:
        return 'cancelled';
    }
  }

  static TripStatus fromString(String value) {
    switch (value) {
      case 'planning':
        return TripStatus.planning;
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.planning;
    }
  }
}

/// Tipos de split para los gastos compartidos
enum ExpenseShareType { equal, percentage, exact, shares }

extension ExpenseShareTypeX on ExpenseShareType {
  String get apiValue {
    switch (this) {
      case ExpenseShareType.equal:
        return 'equal';
      case ExpenseShareType.percentage:
        return 'percentage';
      case ExpenseShareType.exact:
        return 'exact';
      case ExpenseShareType.shares:
        return 'shares';
    }
  }

  static ExpenseShareType fromString(String value) {
    switch (value) {
      case 'percentage':
        return ExpenseShareType.percentage;
      case 'exact':
        return ExpenseShareType.exact;
      case 'shares':
        return ExpenseShareType.shares;
      default:
        return ExpenseShareType.equal;
    }
  }

  String get label {
    switch (this) {
      case ExpenseShareType.equal:
        return 'Igual';
      case ExpenseShareType.percentage:
        return 'Por %';
      case ExpenseShareType.exact:
        return 'Exacto';
      case ExpenseShareType.shares:
        return 'Por partes';
    }
  }
}

/// Roles de un miembro del viaje
enum TripMemberRole { owner, admin, member, viewer }

extension TripMemberRoleX on TripMemberRole {
  String get apiValue => name;

  static TripMemberRole fromString(String value) {
    switch (value) {
      case 'owner':
        return TripMemberRole.owner;
      case 'admin':
        return TripMemberRole.admin;
      case 'viewer':
        return TripMemberRole.viewer;
      default:
        return TripMemberRole.member;
    }
  }

  String get label {
    switch (this) {
      case TripMemberRole.owner:
        return 'Propietario';
      case TripMemberRole.admin:
        return 'Administrador';
      case TripMemberRole.member:
        return 'Miembro';
      case TripMemberRole.viewer:
        return 'Solo lectura';
    }
  }
}

/// Tipos de items dentro del itinerario
enum TripItineraryType { flight, hotel, transport, activity, food, other }

extension TripItineraryTypeX on TripItineraryType {
  String get apiValue => name;

  static TripItineraryType fromString(String value) {
    for (final t in TripItineraryType.values) {
      if (t.name == value) return t;
    }
    return TripItineraryType.other;
  }

  String get label {
    switch (this) {
      case TripItineraryType.flight:
        return 'Vuelo';
      case TripItineraryType.hotel:
        return 'Hospedaje';
      case TripItineraryType.transport:
        return 'Transporte';
      case TripItineraryType.activity:
        return 'Actividad';
      case TripItineraryType.food:
        return 'Comida';
      case TripItineraryType.other:
        return 'Otro';
    }
  }
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _asInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

DateTime _asDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

class TripMember {
  final int id;
  final int? userId;
  final String displayName;
  final String email;
  final String avatarUrl;
  final TripMemberRole role;
  final bool isGhost;
  final DateTime joinedAt;

  const TripMember({
    required this.id,
    required this.displayName,
    required this.role,
    required this.isGhost,
    required this.joinedAt,
    this.userId,
    this.email = '',
    this.avatarUrl = '',
  });

  factory TripMember.fromJson(Map<String, dynamic> json) => TripMember(
        id: _asInt(json['id']),
        userId: json['user_id'] == null ? null : _asInt(json['user_id']),
        displayName: json['display_name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString() ?? '',
        role: TripMemberRoleX.fromString(json['role']?.toString() ?? 'member'),
        isGhost: json['is_ghost'] == true,
        joinedAt: _asDate(json['joined_at']),
      );
}

class TripAllocation {
  final int id;
  final CategoryModel? category;
  final double estimatedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double progressPercent;
  final double dailySuggested;
  final bool isOverBudget;
  final String currency;
  final String notes;

  const TripAllocation({
    required this.id,
    required this.estimatedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.progressPercent,
    required this.dailySuggested,
    required this.isOverBudget,
    required this.currency,
    this.category,
    this.notes = '',
  });

  factory TripAllocation.fromJson(Map<String, dynamic> json) => TripAllocation(
        id: _asInt(json['id']),
        category: json['category'] is Map<String, dynamic>
            ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        estimatedAmount: _asDouble(json['estimated_amount']),
        spentAmount: _asDouble(json['spent_amount']),
        remainingAmount: _asDouble(json['remaining_amount']),
        progressPercent: _asDouble(json['progress_percent']),
        dailySuggested: _asDouble(json['daily_suggested']),
        isOverBudget: json['is_over_budget'] == true,
        currency: json['currency']?.toString() ?? 'USD',
        notes: json['notes']?.toString() ?? '',
      );
}

class TripItineraryItem {
  final int id;
  final DateTime day;
  final String time;
  final TripItineraryType type;
  final String title;
  final String description;
  final String location;
  final double estimatedCost;
  final String currency;
  final int? expenseId;
  final double actualAmount;
  final double variance;

  const TripItineraryItem({
    required this.id,
    required this.day,
    required this.type,
    required this.title,
    required this.estimatedCost,
    required this.currency,
    this.time = '',
    this.description = '',
    this.location = '',
    this.expenseId,
    this.actualAmount = 0,
    this.variance = 0,
  });

  factory TripItineraryItem.fromJson(Map<String, dynamic> json) =>
      TripItineraryItem(
        id: _asInt(json['id']),
        day: _asDate(json['day']),
        time: json['time']?.toString() ?? '',
        type: TripItineraryTypeX.fromString(json['type']?.toString() ?? 'other'),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        estimatedCost: _asDouble(json['estimated_cost']),
        currency: json['currency']?.toString() ?? 'USD',
        expenseId: json['expense_id'] == null ? null : _asInt(json['expense_id']),
        actualAmount: _asDouble(json['actual_amount']),
        variance: _asDouble(json['variance']),
      );
}

class Trip {
  final int id;
  final int ownerUserId;
  final String name;
  final String destination;
  final String countryCode;
  final DateTime startDate;
  final DateTime endDate;
  final String primaryCurrency;
  final TripStatus status;
  final String coverImageUrl;
  final double estimatedTotal;
  final double spentTotal;
  final double remainingAmount;
  final double progressPercent;
  final int daysTotal;
  final int daysRemaining;
  final bool isActiveNow;
  final String notes;
  final List<TripMember> members;
  final List<TripAllocation> allocations;
  final List<TripItineraryItem> itinerary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.primaryCurrency,
    required this.status,
    required this.estimatedTotal,
    required this.spentTotal,
    required this.remainingAmount,
    required this.progressPercent,
    required this.daysTotal,
    required this.daysRemaining,
    required this.isActiveNow,
    required this.createdAt,
    required this.updatedAt,
    this.countryCode = '',
    this.coverImageUrl = '',
    this.notes = '',
    this.members = const [],
    this.allocations = const [],
    this.itinerary = const [],
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: _asInt(json['id']),
        ownerUserId: _asInt(json['owner_user_id']),
        name: json['name']?.toString() ?? '',
        destination: json['destination']?.toString() ?? '',
        countryCode: json['country_code']?.toString() ?? '',
        startDate: _asDate(json['start_date']),
        endDate: _asDate(json['end_date']),
        primaryCurrency: json['primary_currency']?.toString() ?? 'USD',
        status: TripStatusX.fromString(json['status']?.toString() ?? 'planning'),
        coverImageUrl: json['cover_image_url']?.toString() ?? '',
        estimatedTotal: _asDouble(json['estimated_total']),
        spentTotal: _asDouble(json['spent_total']),
        remainingAmount: _asDouble(json['remaining_amount']),
        progressPercent: _asDouble(json['progress_percent']),
        daysTotal: _asInt(json['days_total']),
        daysRemaining: _asInt(json['days_remaining']),
        isActiveNow: json['is_active_now'] == true,
        notes: json['notes']?.toString() ?? '',
        members: ((json['members'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(TripMember.fromJson)
            .toList(),
        allocations: ((json['allocations'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(TripAllocation.fromJson)
            .toList(),
        itinerary: ((json['itinerary'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(TripItineraryItem.fromJson)
            .toList(),
        createdAt: _asDate(json['created_at']),
        updatedAt: _asDate(json['updated_at']),
      );
}

class TripExpenseSplit {
  final int id;
  final int memberId;
  final String memberName;
  final ExpenseShareType shareType;
  final double shareValue;
  final double shareAmount;
  final bool isPaid;

  const TripExpenseSplit({
    required this.id,
    required this.memberId,
    required this.shareType,
    required this.shareValue,
    required this.shareAmount,
    required this.isPaid,
    this.memberName = '',
  });

  factory TripExpenseSplit.fromJson(Map<String, dynamic> json) =>
      TripExpenseSplit(
        id: _asInt(json['id']),
        memberId: _asInt(json['member_id']),
        memberName: json['member_name']?.toString() ?? '',
        shareType: ExpenseShareTypeX.fromString(json['share_type']?.toString() ?? 'equal'),
        shareValue: _asDouble(json['share_value']),
        shareAmount: _asDouble(json['share_amount']),
        isPaid: json['is_paid'] == true,
      );
}

class TripExpense {
  final int id;
  final int tripId;
  final int categoryId;
  final CategoryModel? category;
  final double amount;
  final double amountPrimary;
  final String currency;
  final double exchangeRate;
  final String description;
  final DateTime date;
  final String location;
  final String merchant;
  final String notes;
  final String receiptUrl;
  final int? paidByMemberId;
  final String paidByName;
  final List<TripExpenseSplit> splits;

  const TripExpense({
    required this.id,
    required this.tripId,
    required this.categoryId,
    required this.amount,
    required this.amountPrimary,
    required this.currency,
    required this.exchangeRate,
    required this.description,
    required this.date,
    required this.splits,
    this.category,
    this.location = '',
    this.merchant = '',
    this.notes = '',
    this.receiptUrl = '',
    this.paidByMemberId,
    this.paidByName = '',
  });

  factory TripExpense.fromJson(Map<String, dynamic> json) => TripExpense(
        id: _asInt(json['id']),
        tripId: _asInt(json['trip_id']),
        categoryId: _asInt(json['category_id']),
        category: json['category'] is Map<String, dynamic>
            ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        amount: _asDouble(json['amount']),
        amountPrimary: _asDouble(json['amount_primary']),
        currency: json['currency']?.toString() ?? 'USD',
        exchangeRate: _asDouble(json['exchange_rate']),
        description: json['description']?.toString() ?? '',
        date: _asDate(json['date']),
        location: json['location']?.toString() ?? '',
        merchant: json['merchant']?.toString() ?? '',
        notes: json['notes']?.toString() ?? '',
        receiptUrl: json['receipt_url']?.toString() ?? '',
        paidByMemberId:
            json['paid_by_member_id'] == null ? null : _asInt(json['paid_by_member_id']),
        paidByName: json['paid_by_name']?.toString() ?? '',
        splits: ((json['splits'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(TripExpenseSplit.fromJson)
            .toList(),
      );
}

class TripBalanceMember {
  final int memberId;
  final String memberName;
  final double netAmount;

  const TripBalanceMember({
    required this.memberId,
    required this.memberName,
    required this.netAmount,
  });

  factory TripBalanceMember.fromJson(Map<String, dynamic> json) =>
      TripBalanceMember(
        memberId: _asInt(json['member_id']),
        memberName: json['member_name']?.toString() ?? '',
        netAmount: _asDouble(json['net_amount']),
      );
}

class TripBalanceTransfer {
  final int fromMemberId;
  final String fromName;
  final int toMemberId;
  final String toName;
  final double amount;

  const TripBalanceTransfer({
    required this.fromMemberId,
    required this.fromName,
    required this.toMemberId,
    required this.toName,
    required this.amount,
  });

  factory TripBalanceTransfer.fromJson(Map<String, dynamic> json) =>
      TripBalanceTransfer(
        fromMemberId: _asInt(json['from_member_id']),
        fromName: json['from_name']?.toString() ?? '',
        toMemberId: _asInt(json['to_member_id']),
        toName: json['to_name']?.toString() ?? '',
        amount: _asDouble(json['amount']),
      );
}

class TripBalance {
  final int tripId;
  final String currency;
  final List<TripBalanceMember> netByMember;
  final List<TripBalanceTransfer> transfers;

  const TripBalance({
    required this.tripId,
    required this.currency,
    required this.netByMember,
    required this.transfers,
  });

  factory TripBalance.fromJson(Map<String, dynamic> json) => TripBalance(
        tripId: _asInt(json['trip_id']),
        currency: json['currency']?.toString() ?? 'USD',
        netByMember: ((json['net_by_member'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(TripBalanceMember.fromJson)
            .toList(),
        transfers: ((json['transfers'] ?? const []) as List)
            .whereType<Map<String, dynamic>>()
            .map(TripBalanceTransfer.fromJson)
            .toList(),
      );
}

class Settlement {
  final int id;
  final int tripId;
  final int fromMemberId;
  final String fromName;
  final int toMemberId;
  final String toName;
  final double amount;
  final String currency;
  final double fxRate;
  final DateTime paidAt;
  final String notes;
  final DateTime createdAt;

  const Settlement({
    required this.id,
    required this.tripId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    required this.currency,
    required this.fxRate,
    required this.paidAt,
    required this.createdAt,
    this.fromName = '',
    this.toName = '',
    this.notes = '',
  });

  factory Settlement.fromJson(Map<String, dynamic> json) => Settlement(
        id: _asInt(json['id']),
        tripId: _asInt(json['trip_id']),
        fromMemberId: _asInt(json['from_member_id']),
        fromName: json['from_name']?.toString() ?? '',
        toMemberId: _asInt(json['to_member_id']),
        toName: json['to_name']?.toString() ?? '',
        amount: _asDouble(json['amount']),
        currency: json['currency']?.toString() ?? 'USD',
        fxRate: _asDouble(json['fx_rate']),
        paidAt: _asDate(json['paid_at']),
        notes: json['notes']?.toString() ?? '',
        createdAt: _asDate(json['created_at']),
      );
}

class TripInvitation {
  final int id;
  final int tripId;
  final String token;
  final String email;
  final TripMemberRole role;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final DateTime createdAt;

  const TripInvitation({
    required this.id,
    required this.tripId,
    required this.token,
    required this.role,
    required this.expiresAt,
    required this.createdAt,
    this.email = '',
    this.usedAt,
  });

  factory TripInvitation.fromJson(Map<String, dynamic> json) => TripInvitation(
        id: _asInt(json['id']),
        tripId: _asInt(json['trip_id']),
        token: json['token']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        role: TripMemberRoleX.fromString(json['role']?.toString() ?? 'member'),
        expiresAt: _asDate(json['expires_at']),
        usedAt: json['used_at'] == null ? null : _asDate(json['used_at']),
        createdAt: _asDate(json['created_at']),
      );
}

class TripImportSuggestion {
  final int expenseId;
  final double amount;
  final String currency;
  final String description;
  final DateTime date;
  final int categoryId;
  final String merchant;

  const TripImportSuggestion({
    required this.expenseId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.categoryId,
    this.merchant = '',
  });

  factory TripImportSuggestion.fromJson(Map<String, dynamic> json) =>
      TripImportSuggestion(
        expenseId: _asInt(json['expense_id']),
        amount: _asDouble(json['amount']),
        currency: json['currency']?.toString() ?? 'USD',
        description: json['description']?.toString() ?? '',
        date: _asDate(json['date']),
        categoryId: _asInt(json['category_id']),
        merchant: json['merchant']?.toString() ?? '',
      );
}

class TripReportCategoryTotal {
  final int categoryId;
  final String categoryName;
  final double estimatedAmount;
  final double spentAmount;
  final double variance;

  const TripReportCategoryTotal({
    required this.categoryId,
    required this.categoryName,
    required this.estimatedAmount,
    required this.spentAmount,
    required this.variance,
  });

  factory TripReportCategoryTotal.fromJson(Map<String, dynamic> json) =>
      TripReportCategoryTotal(
        categoryId: _asInt(json['category_id']),
        categoryName: json['category_name']?.toString() ?? '',
        estimatedAmount: _asDouble(json['estimated_amount']),
        spentAmount: _asDouble(json['spent_amount']),
        variance: _asDouble(json['variance']),
      );
}

class TripReportMemberTotal {
  final int memberId;
  final String memberName;
  final double paid;
  final double owed;
  final double net;

  const TripReportMemberTotal({
    required this.memberId,
    required this.memberName,
    required this.paid,
    required this.owed,
    required this.net,
  });

  factory TripReportMemberTotal.fromJson(Map<String, dynamic> json) =>
      TripReportMemberTotal(
        memberId: _asInt(json['member_id']),
        memberName: json['member_name']?.toString() ?? '',
        paid: _asDouble(json['paid']),
        owed: _asDouble(json['owed']),
        net: _asDouble(json['net']),
      );
}

class TripReport {
  final Trip trip;
  final List<TripReportCategoryTotal> totalsByCategory;
  final List<TripReportMemberTotal> totalsByMember;
  final double estimatedTotal;
  final double spentTotal;
  final double variance;
  final bool overBudget;
  final List<Settlement> settlements;
  final DateTime generatedAt;

  const TripReport({
    required this.trip,
    required this.totalsByCategory,
    required this.totalsByMember,
    required this.estimatedTotal,
    required this.spentTotal,
    required this.variance,
    required this.overBudget,
    required this.settlements,
    required this.generatedAt,
  });

  factory TripReport.fromJson(Map<String, dynamic> json) {
    final estVsReal = (json['estimated_vs_real'] ?? const {}) as Map<String, dynamic>;
    return TripReport(
      trip: Trip.fromJson((json['trip'] ?? const {}) as Map<String, dynamic>),
      totalsByCategory: ((json['totals_by_category'] ?? const []) as List)
          .whereType<Map<String, dynamic>>()
          .map(TripReportCategoryTotal.fromJson)
          .toList(),
      totalsByMember: ((json['totals_by_member'] ?? const []) as List)
          .whereType<Map<String, dynamic>>()
          .map(TripReportMemberTotal.fromJson)
          .toList(),
      estimatedTotal: _asDouble(estVsReal['estimated_total']),
      spentTotal: _asDouble(estVsReal['spent_total']),
      variance: _asDouble(estVsReal['variance']),
      overBudget: estVsReal['over_budget'] == true,
      settlements: ((json['settlements'] ?? const []) as List)
          .whereType<Map<String, dynamic>>()
          .map(Settlement.fromJson)
          .toList(),
      generatedAt: _asDate(json['generated_at']),
    );
  }
}
