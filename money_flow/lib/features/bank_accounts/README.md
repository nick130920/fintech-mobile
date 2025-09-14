# 🏦 Bank Accounts Module

Módulo completo para gestión de cuentas bancarias y patrones de notificación inteligentes.

## 📁 Estructura

```
bank_accounts/
├── data/
│   ├── models/                     # Modelos de datos
│   │   ├── bank_account_model.dart
│   │   ├── bank_notification_pattern_model.dart
│   │   └── transaction_model.dart
│   └── repositories/               # Repositorios HTTP
│       ├── bank_account_repository.dart
│       └── bank_notification_pattern_repository.dart
├── presentation/
│   ├── providers/                  # Gestión de estado
│   │   ├── bank_account_provider.dart
│   │   └── bank_notification_pattern_provider.dart
│   ├── screens/                    # Pantallas principales
│   │   ├── bank_accounts_screen.dart
│   │   ├── add_bank_account_screen.dart
│   │   ├── notification_patterns_screen.dart
│   │   ├── add_notification_pattern_screen.dart
│   │   └── process_notification_screen.dart
│   └── widgets/                    # Widgets reutilizables
│       ├── bank_account_card.dart
│       └── notification_pattern_card.dart
└── bank_accounts.dart              # Exportaciones
```

## 🎯 Funcionalidades

### Cuentas Bancarias
- ✅ **CRUD completo**: Crear, leer, actualizar, eliminar
- ✅ **Tipos de cuenta**: Corriente, Ahorros, Crédito, Débito, Inversión
- ✅ **Gestión visual**: Colores e iconos personalizables
- ✅ **Notificaciones**: Configuración por cuenta
- ✅ **Balance tracking**: Seguimiento de saldos
- ✅ **Estados**: Activo/Inactivo

### Patrones de Notificación
- ✅ **Procesamiento IA**: Análisis inteligente de mensajes
- ✅ **Múltiples canales**: SMS, Push, Email, App
- ✅ **Palabras clave**: Sistema de inclusión/exclusión
- ✅ **Regex avanzado**: Extracción de datos personalizables
- ✅ **Auto-validación**: Basada en confianza del IA
- ✅ **Estadísticas**: Métricas de rendimiento

### Procesador de Notificaciones
- ✅ **Simulador**: Prueba notificaciones en tiempo real
- ✅ **Extracción automática**: Monto, fecha, comercio, descripción
- ✅ **Confianza IA**: Cálculo de precisión (0-100%)
- ✅ **Vista previa**: Datos extraídos antes de crear transacción

## 🎨 Diseño

### Siguiendo Money Flow Design System
- ✅ **Glassmorphism**: Efectos glass avanzados
- ✅ **Animaciones**: Entrada suave y hover effects
- ✅ **Colores temáticos**: Sin hardcodeo, todo dinámico
- ✅ **Espaciado consistente**: 8, 16, 24, 32px
- ✅ **Tipografía**: Jerarquía clara y legible

### Estados UX
- ✅ **Loading states**: Indicadores de progreso
- ✅ **Error states**: Manejo elegante de errores
- ✅ **Empty states**: Call-to-actions motivadores
- ✅ **Success feedback**: SnackBars informativos

## 🔌 Integración

### Uso Básico

```dart
// 1. Agregar providers al main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => BankAccountProvider()),
    ChangeNotifierProvider(create: (_) => BankNotificationPatternProvider()),
  ],
  child: MyApp(),
)

// 2. Usar en pantallas
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const BankAccountsScreen(),
  ),
);
```

### Dependencias Requeridas

```yaml
dependencies:
  provider: ^6.1.1
  json_annotation: ^4.8.1
  http: ^1.1.0

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

### Generación de Código

```bash
# Generar archivos .g.dart
dart run build_runner build

# Watch mode para desarrollo
dart run build_runner watch
```

## 🚀 API Endpoints

### Cuentas Bancarias
- `GET /bank-accounts` - Listar cuentas
- `POST /bank-accounts` - Crear cuenta
- `GET /bank-accounts/{id}` - Obtener cuenta
- `PUT /bank-accounts/{id}` - Actualizar cuenta
- `DELETE /bank-accounts/{id}` - Eliminar cuenta
- `PUT /bank-accounts/{id}/active` - Cambiar estado
- `PUT /bank-accounts/{id}/balance` - Actualizar balance

### Patrones de Notificación
- `GET /notification-patterns` - Listar patrones
- `POST /notification-patterns` - Crear patrón
- `GET /notification-patterns/{id}` - Obtener patrón
- `PUT /notification-patterns/{id}` - Actualizar patrón
- `DELETE /notification-patterns/{id}` - Eliminar patrón
- `PUT /notification-patterns/{id}/status` - Cambiar estado
- `POST /notification-patterns/process` - Procesar notificación
- `GET /notification-patterns/statistics` - Estadísticas

## 🧪 Testing

### Flujo de Prueba
1. **Crear cuenta bancaria** → Agregar información básica
2. **Configurar patrón** → Definir reglas de procesamiento
3. **Procesar notificación** → Probar con mensaje real
4. **Revisar estadísticas** → Verificar rendimiento

### Casos de Prueba
- Crear cuentas de diferentes tipos
- Configurar patrones por canal
- Procesar notificaciones reales
- Validar extracción de datos
- Verificar estados y transiciones

## 🔮 Próximas Funcionalidades

- [ ] **Pantalla de detalles** de cuenta bancaria
- [ ] **Edición de patrones** existentes
- [ ] **Importación masiva** de patrones
- [ ] **Machine Learning** mejorado
- [ ] **Notificaciones push** automáticas
- [ ] **Sincronización** con APIs bancarias
- [ ] **Backup/restore** de configuración

---

**Nota**: Este módulo está completamente integrado con el sistema de diseño Money Flow y sigue todas las mejores prácticas de Flutter y Clean Architecture.
