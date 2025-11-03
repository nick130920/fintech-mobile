# 💱 Configuración de API de Divisas

Esta aplicación utiliza [freecurrencyapi.com](https://freecurrencyapi.com) para obtener tasas de cambio en tiempo real.

## 🚀 Configuración Rápida

### Paso 1: Obtener tu API Key GRATUITA

1. Ve a [https://app.freecurrencyapi.com/register](https://app.freecurrencyapi.com/register)
2. Registra una cuenta gratuita
3. Copia tu API key del dashboard

### Paso 2: Configurar la API Key en la App

La aplicación utiliza **dart-define** para inyectar la API key de forma segura. Esto mantiene las credenciales fuera del código fuente.

#### 🏠 Para Desarrollo Local:

Ejecuta la app con el parámetro `--dart-define`:

```bash
flutter run --dart-define=FREECURRENCY_API_KEY=tu-api-key-aqui
```

O para builds de release:

```bash
# Android APK
flutter build apk --release --dart-define=FREECURRENCY_API_KEY=tu-api-key-aqui

# Android App Bundle
flutter build appbundle --release --dart-define=FREECURRENCY_API_KEY=tu-api-key-aqui

# iOS
flutter build ipa --release --dart-define=FREECURRENCY_API_KEY=tu-api-key-aqui
```

#### 🚀 Para Producción (CodeMagic):

La API key ya está configurada en `codemagic.yaml`. Para cambiarla:

**Opción A: Variables de entorno en CodeMagic (Más Seguro)**

1. Ve a [CodeMagic Dashboard](https://codemagic.io/apps)
2. Selecciona tu proyecto
3. **Settings** → **Environment variables**
4. Agrega:
   - **Key**: `FREECURRENCY_API_KEY`
   - **Value**: Tu API key
   - **Secure**: ✅ (oculta la key en logs)
5. Elimina la línea `FREECURRENCY_API_KEY` de `codemagic.yaml`

**Opción B: Editar codemagic.yaml**

Actualiza estas líneas en ambos workflows (Android e iOS):

```yaml
vars:
  FREECURRENCY_API_KEY: "tu-nueva-api-key-aqui"
```

> ⚠️ **Importante**: Si tu repositorio es público, usa la Opción A para mantener la API key privada.

## 📊 Plan Gratuito

El plan gratuito de freecurrencyapi.com incluye:

- ✅ **5,000 requests por mes**
- ✅ **Actualización horaria** de tasas
- ✅ **Soporte para 150+ divisas**
- ✅ **Cache automático** (1 hora en nuestra implementación)
- ✅ **Sin tarjeta de crédito** requerida

## 🌐 Características Implementadas

### 1. **Tasas de Cambio en Tiempo Real**
```dart
final rates = await ExchangeRateService.getExchangeRates(
  baseCurrency: 'USD',
  targetCurrencies: ['EUR', 'MXN', 'COP'],
);
```

### 2. **Conversión de Divisas**
```dart
final converted = await ExchangeRateService.convertCurrency(
  amount: 100.0,
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);
```

### 3. **Cache Inteligente**
- Las tasas se cachean por 1 hora
- Reduce llamadas a la API
- Funciona offline con últimas tasas conocidas

### 4. **Manejo de Rate Limits**
- Detección automática de límite excedido (HTTP 429)
- Fallback a cache cuando se excede el límite
- Reintentos inteligentes

## 🛠️ Funcionalidades de la App

### Selector de Divisa
Los usuarios pueden:
- ✅ Cambiar su divisa preferida desde Perfil → Configuración de Divisa
- ✅ Ver tasas de cambio en tiempo real
- ✅ Seleccionar entre 8+ divisas populares
- ✅ Búsqueda de divisas adicionales
- ✅ Ver última actualización de tasas

### Formateo Automático
- Todos los montos se formatean automáticamente con la divisa seleccionada
- Soporte para divisas sin decimales (JPY, KRW, COP)
- Formato según estándares internacionales

## 📱 Uso en la Aplicación

### Acceder a la Configuración
1. Abre la app
2. Ve a la pestaña **Perfil** (última pestaña)
3. Toca **Divisa de la Aplicación**
4. Selecciona tu divisa preferida

### Cambiar Divisa
1. En la pantalla de configuración de divisa
2. Toca cualquier divisa de la lista
3. Confirma el cambio
4. ¡Todos los montos se actualizarán automáticamente!

## 🔧 Desarrollo

### Verificar Configuración
```dart
if (ExchangeRateService.isApiKeyConfigured()) {
  print('✅ API key configurada correctamente');
} else {
  print('❌ API key no configurada');
}
```

### Ver Estado del Cache
```dart
final cacheInfo = await ExchangeRateService.getCacheInfo('USD');
if (cacheInfo != null) {
  print('Última actualización: ${cacheInfo.formattedAge}');
  print('¿Expirado?: ${cacheInfo.isExpired}');
}
```

### Limpiar Cache
```dart
await ExchangeRateService.clearCache();
```

## 🌍 Divisas Soportadas

### Divisas Populares en la App:
- 🇺🇸 USD - Dólar Estadounidense
- 🇪🇸 EUR - Euro
- 🇲🇽 MXN - Peso Mexicano
- 🇨🇴 COP - Peso Colombiano
- 🇦🇷 ARS - Peso Argentino
- 🇧🇷 BRL - Real Brasileño
- 🇬🇧 GBP - Libra Esterlina
- 🇯🇵 JPY - Yen Japonés

### Otras Disponibles:
- 🇨🇦 CAD - Dólar Canadiense
- 🇵🇪 PEN - Sol Peruano
- 🇨🇱 CLP - Peso Chileno
- 🇨🇳 CNY - Yuan Chino
- 🇮🇳 INR - Rupia India
- 🇰🇷 KRW - Won Surcoreano
- Y más...

## ⚠️ Importante

### Límites de Rate
- **Free Plan**: 5,000 requests/mes
- **Requests por minuto**: 10 (plan gratuito)
- Nuestro cache de 1 hora ayuda a mantenerse dentro de estos límites

### Seguridad
- ✅ La app usa **dart-define** para mantener las API keys seguras
- ✅ Las keys se inyectan en tiempo de compilación, no en el código fuente
- ✅ En CodeMagic, puedes usar variables de entorno seguras
- ⚠️ Si editas `codemagic.yaml` directamente, **NO** subas API keys a repositorios públicos
- 💡 Para repos públicos, usa variables de entorno en el dashboard de CodeMagic

## 📚 Documentación Adicional

- [Documentación oficial de freecurrencyapi](https://freecurrencyapi.com/docs/)
- [Endpoints disponibles](https://freecurrencyapi.com/docs/endpoints)
- [Rate limits y quotas](https://freecurrencyapi.com/docs/#rate-limit-and-quotas)

## 🐛 Solución de Problemas

### "API key no configurada"
- Verifica que estés ejecutando la app con `--dart-define=FREECURRENCY_API_KEY=tu-api-key`
- Para builds de producción, confirma que la variable esté en `codemagic.yaml` o en el dashboard de CodeMagic
- La app funcionará sin API key, pero usando solo la divisa por defecto

### "Error al cargar tasas"
- Verifica tu conexión a internet
- Confirma que tu API key es válida
- Revisa que no hayas excedido el límite mensual

### Tasas desactualizadas
- Toca el ícono de refresh en la esquina superior derecha
- Espera a que expire el cache (1 hora)
- O limpia el cache manualmente

## 💡 Tips

1. **Desarrollo Local**: La app funciona sin API key, usando la divisa por defecto
2. **dart-define**: Para no escribir la key cada vez, crea un launch configuration en VS Code:
   ```json
   {
     "name": "Flutter with API Key",
     "request": "launch",
     "type": "dart",
     "args": [
       "--dart-define=FREECURRENCY_API_KEY=tu-api-key-aqui"
     ]
   }
   ```
3. **Cache**: El cache de 1 hora reduce significativamente las llamadas API
4. **Offline**: Las últimas tasas conocidas se usan cuando no hay conexión
5. **Performance**: Las tasas se cargan en segundo plano, no bloqueando la UI
6. **Seguridad**: dart-define compila la key en el binario, pero no la expone en el código fuente

---

¿Necesitas ayuda? Revisa la [documentación oficial](https://freecurrencyapi.com/docs/) o contacta al equipo de soporte de freecurrencyapi.com

