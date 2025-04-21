library core_services_package;

// Base
export 'src/base/app_base.dart';
export 'src/base/base_service.dart';

// Network
export 'src/network/api_manager.dart';
export 'src/network/connectivity_manager.dart';

// Storage
export 'src/storage/storage_manager.dart';

// Database
export 'src/database/database_manager.dart';
export 'src/database/base_model.dart';
export 'src/database/base_repository.dart' hide BaseRepository;

// Logging
export 'src/logging/logger.dart';

// Utils
export 'src/utils/auth_manager.dart';
export 'src/utils/settings_manager.dart';
export 'src/utils/navigation_manager.dart';
export 'src/utils/service_initializer.dart';

// Theme
export 'src/theme/theme_manager.dart';

// Translations
export 'src/translations/language_manager.dart';
export 'src/translations/app_translations.dart';
export 'src/translations/en.dart';
export 'src/translations/ar.dart';
export 'src/translations/es.dart';

// State
export 'src/state/custom_state_manager.dart';

// DI
export 'src/di/dependency_injection.dart';

// Forms
export 'src/forms/form_manager.dart';

// Notifications
export 'src/notifications/notification_manager.dart';

// Updates - Removed to avoid duplication with auto_update_package

// Values
export 'src/values/app_colors.dart';

// Widgets
export 'src/widgets/buttons/custom_button.dart';
export 'src/widgets/cards/custom_card.dart';
export 'src/widgets/dialogs/custom_dialog.dart';
export 'src/widgets/inputs/custom_text_field.dart';
export 'src/widgets/responsive/responsive_view.dart';
export 'src/widgets/getx_widgets.dart';
