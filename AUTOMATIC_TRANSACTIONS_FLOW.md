# 📱 Flujo de Transacciones Automáticas - Money Flow

## 🔄 Flujo Completo: SMS → Transacción Procesada

### 1️⃣ **Recepción de SMS**

```
📱 SMS Llega al Dispositivo
    ↓
🔔 Sistema Android detecta SMS entrante
    ↓
📨 SmsService.syncInbox() procesa el mensaje
    ↓
⚙️ smsSyncHandler() valida y procesa
```

**Validaciones:**
- ✅ ¿Hay sesión activa? (`AuthProvider`)
- ✅ ¿Procesamiento automático activado? (`SmsSettingsProvider`)
- ✅ ¿Hay cuentas bancarias con SMS activo? (`BankAccountProvider`)
- ✅ ¿El SMS cumple con el rango de fechas configurado?

---

### 2️⃣ **Procesamiento con IA (Gemini)**

```
📨 Mensaje SMS
    ↓
🤖 Backend: /notifications/process
    ↓
🧠 Gemini AI extrae información:
    • Tipo de transacción (gasto/ingreso/transferencia)
    • Monto
    • Fecha y hora
    • Merchant/comercio
    • Categoría sugerida
    • Confidence score (0-100)
    ↓
📊 Se crea TransactionModel con:
    • validation_status: "auto" (si confidence > 80)
                        "pending_review" (si confidence < 80)
    • needs_review: true/false
    • source: "notification"
```

---

### 3️⃣ **Almacenamiento y Estado**

```
✅ Transacción creada en BD con estado: "pending"
    ↓
📍 Se almacena:
    • raw_notification (mensaje original)
    • ai_confidence (0.0 - 1.0)
    • validation_status
    • bank_account_id
    • suggested_category
    ↓
🔔 Notificación al usuario (opcional)
```

---

### 4️⃣ **Clasificación de Transacciones**

#### A) **Transacciones AUTO (Confidence > 80%)**
```
validation_status: "auto"
needs_review: false
    ↓
✅ Alta confianza
✅ Se puede aprobar automáticamente o en batch
✅ Categoría sugerida por IA confiable
```

#### B) **Transacciones PENDING_REVIEW (Confidence < 80%)**
```
validation_status: "pending_review"
needs_review: true
    ↓
⚠️ Requiere revisión manual
⚠️ Usuario debe verificar:
    • Categoría correcta
    • Monto correcto
    • Comercio/descripción
```

---

### 5️⃣ **Revisión en la App**

#### **Pantalla: Pending Transactions Screen**

**Ubicación:** `/pending-transactions`

**Vista Principal:**
```
╔═══════════════════════════════════════╗
║  📊 Transacciones Pendientes          ║
║                                       ║
║  [Filtros: Todas | Revisar | Auto]   ║
║  [Acciones en lote ✓]                ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ 🏪 OXXO                         │ ║
║  │ -$150.00 • Hace 2 horas        │ ║
║  │ 🤖 Confidence: 95%              │ ║
║  │ 🏷️ Categoría: Alimentos        │ ║
║  │ ✅ [Aprobar] ❌ [Rechazar]      │ ║
║  └─────────────────────────────────┘ ║
║                                       ║
║  ┌─────────────────────────────────┐ ║
║  │ ⚠️ Comercio Desconocido         │ ║
║  │ -$2,500.00 • Hace 1 día        │ ║
║  │ 🤖 Confidence: 65% ⚠️           │ ║
║  │ 🏷️ Categoría: Sin categoría   │ ║
║  │ ✏️ [Editar y Aprobar]           │ ║
║  └─────────────────────────────────┘ ║
╚═══════════════════════════════════════╝
```

**Acciones Disponibles:**
- ✅ **Aprobar** → Status: "completed"
- ❌ **Rechazar** → Status: "cancelled"
- ✏️ **Editar** → Modificar categoría/monto antes de aprobar
- 📦 **Batch** → Aprobar/rechazar múltiples a la vez

---

### 6️⃣ **Estadísticas y Monitoreo**

#### **Widget: AutomaticTransactionsStatsWidget**

**Ubicación:** Dashboard / Bank Accounts Screen

```
╔════════════════════════════════════════╗
║  🤖 Transacciones Automáticas         ║
║                                        ║
║  📊 Total Procesadas:        142      ║
║  ✅ Aprobadas:               120      ║
║  ❌ Rechazadas:               15      ║
║  ⏳ Pendientes:                7      ║
║                                        ║
║  📈 Tasa de Aprobación:      84.5%   ║
║  🎯 Confidence Promedio:     87.3%   ║
║                                        ║
║  ⚠️ 7 transacciones requieren        ║
║     tu revisión                       ║
║  [Ver Pendientes →]                   ║
╚════════════════════════════════════════╝
```

**Métricas Disponibles:**
- Total de transacciones procesadas
- Aprobadas vs Rechazadas
- Pendientes de revisión
- Tasa de aprobación automática
- Confidence promedio de la IA
- Transacciones por periodo

---

### 7️⃣ **Integración con Patrones**

#### **Patrones de Notificación**

**Pantalla:** `/notification-patterns`

```
╔════════════════════════════════════════╗
║  📋 Patrones de Notificación          ║
║                                        ║
║  ┌──────────────────────────────────┐ ║
║  │ BBVA - Compras                   │ ║
║  │ 🏦 BBVA Bancomer                 │ ║
║  │                                   │ ║
║  │ Pattern: Compra por \$(.+) en    │ ║
║  │          (.+) el (.+)            │ ║
║  │                                   │ ║
║  │ ✅ Activo • 45 coincidencias     │ ║
║  └──────────────────────────────────┘ ║
║                                        ║
║  ┌──────────────────────────────────┐ ║
║  │ Santander - Retiros              │ ║
║  │ 🏦 Santander                     │ ║
║  │                                   │ ║
║  │ Pattern: Retiro ATM \$(.+)       │ ║
║  │          Saldo: \$(.+)           │ ║
║  │                                   │ ║
║  │ ✅ Activo • 23 coincidencias     │ ║
║  └──────────────────────────────────┘ ║
╚════════════════════════════════════════╝
```

**Proceso de Patrones:**
1. SMS llega → Backend intenta hacer match con patrones existentes
2. Si encuentra match → Extrae datos estructurados
3. Si NO encuentra match → Crea sugerencia de nuevo patrón
4. Usuario puede crear/editar patrones manualmente

---

## 📊 Estados de una Transacción

### **Estado del Ciclo de Vida:**

```
┌─────────────┐
│   PENDING   │ ← Recién creada por SMS
└──────┬──────┘
       │
       ├──→ Revisión Manual
       │      │
       │      ├──→ Usuario edita
       │      └──→ Usuario aprueba/rechaza
       │
       ├──→ Aprobación Automática (high confidence)
       │
       ↓
┌─────────────┐           ┌─────────────┐
│  COMPLETED  │    o      │  CANCELLED  │
└─────────────┘           └─────────────┘
     ↓                          ↓
Se crea Expense/Income    Se archiva
en el presupuesto         (no afecta presupuesto)
```

---

## 🎯 Validation Status

### **Estados de Validación:**

| Status | Descripción | Confidence | Acción |
|--------|-------------|------------|--------|
| `auto` | IA muy confiada | > 80% | Aprobación automática sugerida |
| `pending_review` | IA poco confiada | < 80% | Requiere revisión manual |
| `manual_validated` | Usuario validó | N/A | Editada y aprobada manualmente |
| `rejected` | Usuario rechazó | N/A | No se procesará |

---

## 🔍 Filtros Disponibles

### **En Pending Transactions Screen:**

1. **Por Estado de Validación:**
   - ✅ Auto (alta confianza)
   - ⚠️ Needs Review (baja confianza)
   - 📝 Manual Validated
   - ❌ Rejected

2. **Por Tipo:**
   - 💸 Gastos (expense)
   - 💰 Ingresos (income)
   - 🔄 Transferencias (transfer)

3. **Por Cuenta Bancaria:**
   - Filtrar por cuenta específica

4. **Por Rango de Fechas:**
   - Hoy
   - Esta semana
   - Este mes
   - Personalizado

---

## 📱 Navegación en la App

### **Acceso a Transacciones Automáticas:**

```
Perfil → Cuentas Bancarias → [Ver Estadísticas]
   ↓
Dashboard → Widget de Estadísticas → [Ver Pendientes]
   ↓
/pending-transactions
```

### **Flujo de Usuario Típico:**

```
1. SMS llega automáticamente
2. Usuario recibe notificación (opcional)
3. Usuario abre app
4. Dashboard muestra: "⚠️ 3 transacciones pendientes"
5. Usuario hace click en "Ver Pendientes"
6. Revisa transacciones:
   • Aprueba las de alta confianza
   • Edita y aprueba las de baja confianza
   • Rechaza las incorrectas
7. Transacciones aprobadas → Se crean gastos/ingresos automáticamente
```

---

## 🚀 Acciones Batch (Procesamiento en Lote)

### **Funcionalidad:**

```
┌────────────────────────────────────────┐
│  Modo Selección Múltiple              │
│                                        │
│  ☑️ Transacción 1  (Confidence: 95%) │
│  ☑️ Transacción 2  (Confidence: 92%) │
│  ☑️ Transacción 3  (Confidence: 88%) │
│  ☐ Transacción 4  (Confidence: 65%) │
│                                        │
│  [✅ Aprobar 3 seleccionadas]         │
│  [❌ Rechazar seleccionadas]          │
└────────────────────────────────────────┘
```

**Resultado del Batch:**
```
╔════════════════════════════════════════╗
║  ✅ Procesamiento Completado          ║
║                                        ║
║  Aprobadas: 3                         ║
║  Fallidas: 0                          ║
║                                        ║
║  Las transacciones aprobadas se han   ║
║  agregado a tu presupuesto.           ║
╚════════════════════════════════════════╝
```

---

## 🎨 Indicadores Visuales

### **Colores de Confidence:**

- 🟢 **90-100%** → Verde (muy confiable)
- 🟡 **70-89%** → Amarillo (confiable)
- 🟠 **50-69%** → Naranja (revisar)
- 🔴 **< 50%** → Rojo (requiere atención)

### **Iconos por Tipo:**

- 💸 **Expense** → trending_down
- 💰 **Income** → trending_up
- 🔄 **Transfer** → swap_horiz

### **Badges de Estado:**

- ✅ **AUTO** → Badge verde
- ⚠️ **NEEDS REVIEW** → Badge naranja
- 📝 **MANUAL** → Badge azul
- ❌ **REJECTED** → Badge rojo

---

## 📊 Endpoints Backend Utilizados

### **Principal:**
- `POST /notifications/process` - Procesar SMS con IA
- `GET /transactions?status=pending` - Obtener pendientes
- `GET /transactions/stats` - Obtener estadísticas
- `PUT /transactions/:id/approve` - Aprobar transacción
- `PUT /transactions/:id/reject` - Rechazar transacción
- `POST /transactions/batch` - Procesar múltiples
- `PUT /transactions/:id` - Editar transacción

---

## 🔔 Notificaciones

### **Cuándo se Notifica:**

1. ✅ **Transacción Procesada con Alta Confianza**
   - "Nueva transacción detectada: -$150.00 en OXXO"

2. ⚠️ **Transacción Requiere Revisión**
   - "Transacción de -$2,500 requiere tu revisión"

3. 📊 **Resumen Diario** (opcional)
   - "Tienes 5 transacciones pendientes de revisar"

---

## 💡 Mejores Prácticas

### **Para el Usuario:**

1. ✅ Revisar transacciones pendientes diariamente
2. ✅ Aprobar en batch las de alta confianza
3. ✅ Editar y corregir las de baja confianza
4. ✅ Crear patrones para bancos comunes
5. ✅ Mantener configuración de SMS actualizada

### **Flujo Óptimo:**

```
Morning Routine:
1. Abrir app
2. Ver estadísticas en dashboard
3. Si hay pendientes → Revisar
4. Aprobar batch de alta confianza
5. Revisar individualmente las dudosas
6. ✅ Done!
```

---

## 🐛 Casos Edge y Manejo de Errores

### **Casos Especiales:**

1. **SMS Duplicado**
   - Backend detecta y rechaza automáticamente

2. **SMS Sin Monto**
   - Se marca como "needs_review" con confidence bajo

3. **SMS de Banco Desconocido**
   - Gemini intenta extraer info igual
   - Usuario puede crear patrón nuevo

4. **Múltiples Transacciones en un SMS**
   - Se crea una por cada transacción detectada

5. **SMS en Formato No Estándar**
   - Confidence bajo → needs_review

---

## 📈 Próximas Mejoras Sugeridas

### **En Consideración:**

1. 🎯 **Aprobación Automática Total**
   - Config: Auto-aprobar si confidence > 90%

2. 📊 **Dashboard de Patrones**
   - Ver qué patrones funcionan mejor
   - Ver cuáles necesitan ajuste

3. 🔔 **Notificaciones Inteligentes**
   - Solo notificar si needs_review

4. 🤖 **Machine Learning Personalizado**
   - Aprender de tus aprobaciones/rechazos
   - Mejorar categorización con el tiempo

5. 📱 **Widget de Home Screen**
   - Ver pendientes sin abrir app

---

## 📚 Archivos Relacionados

### **Frontend (Flutter):**
- `pending_transactions_screen.dart` - Pantalla principal de revisión
- `automatic_transactions_stats_widget.dart` - Widget de estadísticas
- `pending_transaction_card.dart` - Card individual de transacción
- `automatic_transactions_provider.dart` - Estado y lógica
- `automatic_transactions_repository.dart` - API calls
- `transaction_model.dart` - Modelo de datos

### **Backend (Go):**
- `internal/entity/transaction.go` - Entidad
- `internal/controller/http/v1/transaction_handler.go` - Endpoints
- `internal/usecase/webapi/gemini_service.go` - IA processing
- `pkg/repository/transaction_postgres.go` - Repositorio

---

¡Este es el flujo completo de Transacciones Automáticas en Money Flow! 🚀

