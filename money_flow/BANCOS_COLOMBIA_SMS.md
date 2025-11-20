# 🇨🇴 Estructuras de SMS Bancarios Colombianos

## 📱 Códigos Cortos y Estructuras de Mensajes

Este documento detalla las estructuras reales de mensajes SMS que envían los principales bancos colombianos para notificar transacciones.

---

## 1️⃣ Bancolombia

**Códigos SMS**: 891602 (Débito), 891333 (Crédito)  
**Package App**: `co.com.bancolombia.personas.superapp`

### Estructura de Transacción Inusual

```
¿Es tu transacción?
Compra en [COMERCIO], $[MONTO], tarjeta final [XXXX], [FECHA] a las [HORA].
Si fuiste tú, responde SÍ. Si no, responde NO
```

**Ejemplo real**:
```
¿Es tu transacción?
Compra en STARBUCKS, $45.800, tarjeta final 1234, 07/11 a las 10:30.
Si fuiste tú, responde SÍ. Si no, responde NO
```

### Características
- ✅ Sin enlaces, solo confirmación SÍ o NO
- ✅ Formato de monto: $45.800 (punto como separador de miles)
- ✅ Incluye comercio, monto, últimos dígitos de tarjeta, fecha y hora

---

## 2️⃣ Nequi

**Código SMS**: 85954  
**Package App**: `com.nequi.MobileApp`

### Estructura de Transacción Recibida

```
[NOMBRE USUARIO]: has recibido $[MONTO] de [REMITENTE].
Movimientos: [SALDO DISPONIBLE]
```

**Ejemplo real**:
```
Juan: has recibido $50.000 de Maria Pérez.
Movimientos: $250.000
```

### Estructura de Transacción Enviada

```
[NOMBRE USUARIO]: enviaste $[MONTO] a [DESTINATARIO].
Movimientos: [SALDO DISPONIBLE]
```

**Ejemplo real**:
```
Juan: enviaste $30.000 a Pedro González.
Movimientos: $220.000
```

### Características
- ✅ Siempre desde código 85954
- ✅ Incluye nombre del usuario al inicio
- ✅ Muestra saldo disponible después de la transacción
- ✅ Sin enlaces

---

## 3️⃣ Davivienda / DaviPlata

**Código SMS**: 85888  
**Package App**: `com.davivienda.daviviendaapp` (Davivienda) / `com.daviplata.daviplataapp` (DaviPlata)

### Estructura de Transferencia Recibida

```
Una transferencia de $[MONTO] ha sido recibida en tu DaviPlata.
Saldo: $[NUEVO SALDO]
Desde: [REMITENTE]
```

**Ejemplo real**:
```
Una transferencia de $100.000 ha sido recibida en tu DaviPlata.
Saldo: $450.000
Desde: Carlos Rodríguez
```

### Características
- ✅ Confirmación de recepción automática
- ✅ Muestra saldo actualizado
- ✅ Incluye información del remitente
- ✅ Sin enlaces
- ⚠️ **IMPORTANTE**: No requiere "aceptar" en enlace. Si recibes SMS pidiendo aceptar con enlace, es FRAUDE

---

## 4️⃣ Banco Popular

**Código SMS**: 85676 (Alertas)  
**Package App**: `com.grupoavalpo.bancamovil`

### Estructura Típica de Transacción

```
Banco Popular: Se realizó [TIPO TRANSACCIÓN] por $[MONTO] en [COMERCIO] [FECHA] [HORA].
Si no fue usted, contacte: [TELÉFONO]
```

**Ejemplo real**:
```
Banco Popular: Se realizó compra por $75.500 en ÉXITO 07/11 14:25.
Si no fue usted, contacte: 018000123456
```

### Características
- ✅ Incluye tipo de transacción explícito
- ✅ Proporciona número de contacto para reportes
- ✅ Formato claro de fecha y hora

---

## 5️⃣ BBVA Colombia

**Código SMS**: Aproximadamente 87703  
**Package App**: `co.com.bbva.mb`

### Estructura de Código OTP

```
Tu código de verificación es: [XXXX-XXXX]
No compartas este código con nadie.
```

**Ejemplo real**:
```
Tu código de verificación es: 1234-5678
No compartas este código con nadie.
```

### Estructura de Transacción

```
BBVA: Compra por $[MONTO] en [COMERCIO] el [FECHA].
```

**Ejemplo real**:
```
BBVA: Compra por $120.000 en ALKOSTO el 07/11/2025.
```

### Características
- ✅ Solo números para OTP
- ✅ Nunca incluye enlaces
- ✅ Advertencia de seguridad en códigos OTP

---

## 6️⃣ AV Villas

**Código SMS**: 85228 (Retiros)  
**Package App**: `com.grupoavalav1.bancamovil`

### Estructura de Retiro

```
AV Villas: Retiro de $[MONTO] en [OFICINA/CAJERO] el [FECHA] a las [HORA].
Saldo: $[NUEVO SALDO]
```

**Ejemplo real**:
```
AV Villas: Retiro de $200.000 en CAJERO CALLE 80 el 07/11 a las 16:45.
Saldo: $800.000
```

### Características
- ✅ Identifica ubicación del cajero u oficina
- ✅ Muestra saldo actualizado
- ✅ Información completa de fecha y hora

---

## 7️⃣ Banco Falabella

**Código SMS**: 87884 (Transacciones)  
**Package App**: `co.com.bancofallabella.mobile.omc`

### Estructura de Compra

```
Banco Falabella: Compra por $[MONTO] con tarjeta final [XXXX] en [COMERCIO] el [FECHA].
¿Fue usted? Responda SÍ o NO
```

**Ejemplo real**:
```
Banco Falabella: Compra por $89.900 con tarjeta final 5678 en HOMECENTER el 07/11.
¿Fue usted? Responda SÍ o NO
```

### Características
- ✅ Solicita confirmación de la transacción
- ✅ Incluye últimos dígitos de tarjeta
- ✅ Respuesta simple: SÍ o NO

---

## 8️⃣ Bre-B (Sistema de Pagos Inmediatos)

**Nota**: Bre-B no es un banco sino un sistema de transferencias inmediatas utilizado por múltiples bancos en Colombia.

### Estructura de Transferencia Recibida

```
Recibiste $[MONTO] a través de Bre-B
De: [NOMBRE REMITENTE]
Fecha: [FECHA] Hora: [HORA]
Línea nacional: [NÚMERO]
```

**Ejemplo real**:
```
Recibiste $150.000 a través de Bre-B
De: LAURA MARTINEZ
Fecha: 07/11/2025 Hora: 15:30
Línea nacional: 018000111222
```

### ⚠️ ALERTA DE SEGURIDAD

**NO necesitas "aceptar" en un enlace**. El dinero llega directamente.

Si recibes un SMS pidiendo "aceptar" la transferencia con un enlace, **ES FRAUDE**.

---

## 🔐 Características Comunes de SMS Legítimos

### ✅ Señales de Legitimidad

1. **Códigos Cortos**: Vienen de números de 5-6 dígitos, NO de celulares normales
2. **Sin Enlaces Sospechosos**: Nunca piden hacer clic para "aceptar" o "validar"
3. **Información Completa**: Incluyen nombre banco, monto exacto, comercio/destino, fecha, hora
4. **Buena Ortografía**: Sin errores gramaticales o de escritura
5. **No Piden Datos**: Nunca solicitan claves, contraseñas o datos sensibles

### ❌ Señales de FRAUDE

1. **Vienen de números celulares normales** (10 dígitos)
2. **Incluyen enlaces para "aceptar" o "validar"**
3. **Piden contraseñas, claves o datos personales**
4. **Urgencia extrema o amenazas**
5. **Errores de ortografía o gramática**
6. **URLs acortadas o sospechosas**

---

## 💰 Formato de Montos en Colombia

### Separadores
- **Separador de miles**: Punto (.)
- **Separador decimal**: Coma (,)

### Ejemplos
```
$1.000        = Mil pesos
$1.000.000    = Un millón de pesos
$1.500.000,50 = Un millón quinientos mil pesos con cincuenta centavos
$45.800       = Cuarenta y cinco mil ochocientos pesos
```

### Conversión en el Sistema

El sistema automáticamente convierte:
```
$1.500.000,50 → 1500000.50 (formato numérico)
```

---

## 🔧 Integración en Money Flow

### Patrones Implementados

Cada banco tiene patrones regex específicos en `notification_parser_service.dart`:

```dart
// Ejemplo Bancolombia
NotificationPattern(
  regex: r'Compra en\s+(.+?),\s+\$([0-9.,]+)',
  type: 'expense',
  amountGroup: 2,
  merchantGroup: 1,
)

// Ejemplo Nequi
NotificationPattern(
  regex: r'has recibido\s+\$([0-9.,]+)\s+de\s+(.+?)\.?',
  type: 'income',
  amountGroup: 1,
  merchantGroup: 2,
)
```

### Proceso Automático

1. **Captura**: NotificationListener detecta SMS/notificación
2. **Filtro**: Verifica que sea de un banco colombiano
3. **Parseo**: Extrae monto, comercio y tipo de transacción
4. **Conversión**: Convierte formato colombiano ($1.000.000) a numérico (1000000)
5. **Guardado**: Crea transacción automáticamente en Money Flow
6. **Confirmación**: Muestra notificación al usuario

---

## 📋 Testing y Validación

### Para Probar el Sistema

1. **Simular Notificaciones**: Usa apps como "Notification Maker" en Android
2. **Formato Correcto**: Usa los ejemplos reales de arriba
3. **Verificar Extracción**: Revisa logs para ver qué información se extrajo
4. **Probar Diferentes Bancos**: Simula notificaciones de cada banco

### Ejemplos de Prueba

```
// Prueba Bancolombia
"Compra en EXITO, $125.800, tarjeta final 1234, 07/11 a las 10:30."

// Prueba Nequi
"Juan: has recibido $50.000 de Maria Pérez. Movimientos: $250.000"

// Prueba DaviPlata
"Una transferencia de $100.000 ha sido recibida en tu DaviPlata. Saldo: $450.000"
```

---

## 🆕 Agregar Nuevos Bancos

Para agregar soporte para un nuevo banco colombiano:

1. **Recopilar ejemplos reales** de SMS del banco
2. **Identificar el package** de la app móvil
3. **Crear patrones regex** en `notification_parser_service.dart`
4. **Agregar package** en `NotificationListener.kt`
5. **Probar con ejemplos reales**
6. **Documentar** en este archivo

---

## ⚠️ Importante

- **Privacidad**: Todas las notificaciones se procesan localmente
- **Seguridad**: Nunca compartas códigos OTP o claves
- **Reportar Fraude**: Si recibes SMS sospechoso, reporta al banco
- **Códigos Legítimos**: Guarda los códigos cortos oficiales de tu banco

---

**Última actualización**: Noviembre 2025  
**Bancos soportados**: 9 principales bancos colombianos

