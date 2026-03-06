// Exportaciones principales del módulo de cuentas bancarias

// Modelos de datos
export 'data/models/bank_account_model.dart';
export 'data/models/bank_notification_pattern_model.dart';
export 'data/models/transaction_model.dart';

// Repositorios
export 'data/repositories/bank_account_repository.dart';
export 'data/repositories/bank_notification_pattern_repository.dart';

// Providers
export 'presentation/providers/bank_account_provider.dart';
export 'presentation/providers/bank_notification_pattern_provider.dart';

// Pantallas
export 'presentation/screens/bank_accounts_screen.dart';
export 'presentation/screens/add_bank_account_screen.dart';
export 'presentation/screens/notification_patterns_screen.dart';
export 'presentation/screens/add_notification_pattern_screen.dart';
export 'presentation/screens/process_notification_screen.dart';
export 'presentation/screens/automatic_transactions_settings_screen.dart';
export 'presentation/screens/pending_transactions_screen.dart';
export 'presentation/screens/edit_pending_transaction_screen.dart';

// Widgets
export 'presentation/widgets/bank_account_card.dart';
export 'presentation/widgets/notification_pattern_card.dart';
export 'presentation/widgets/automatic_transactions_stats_widget.dart';
export 'presentation/widgets/pending_transactions_fab.dart';
