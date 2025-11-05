# Guía de Autenticación Biométrica - Money Flow

## 🎯 Descripción

Esta implementación permite a los usuarios de Money Flow iniciar sesión usando autenticación biométrica (huella dactilar, Face ID, etc.) en lugar de escribir su contraseña cada vez.

## ✨ Características Implementadas

### 1. **BiometricService** (`lib/core/services/biometric_service.dart`)
Servicio centralizado para manejar todas las operaciones biométricas:
- ✅ Verificar disponibilidad de biometría en el dispositivo
- ✅ Detectar tipo de biometría (huella, Face ID, iris)
- ✅ Autenticar usuario con biometría
- ✅ Obtener descripciones e íconos apropiados

### 2. **Almacenamiento Seguro** (`lib/core/services/storage_service.dart`)
Extensiones al servicio de almacenamiento:
- ✅ Guardar credenciales de forma cifrada en Flutter Secure Storage
- ✅ Habilitar/deshabilitar login biométrico
- ✅ Gestionar estado de preferencias biométricas

### 3. **AuthProvider con Biometría** (`lib/features/auth/presentation/providers/auth_provider.dart`)
Métodos adicionales en el provider de autenticación:
- ✅ `loginWithBiometric()` - Login usando biometría
- ✅ `isBiometricLoginAvailable()` - Verificar si está disponible
- ✅ `toggleBiometricLogin()` - Habilitar/deshabilitar
- ✅ Login tradicional con opción de guardar credenciales

### 4. **UI Mejorada** (`lib/features/auth/presentation/screens/login_screen.dart`)
Interfaz de usuario actualizada:
- ✅ Checkbox para habilitar login biométrico
- ✅ Botón dedicado para login con huella/Face ID
- ✅ Detección automática del tipo de biometría
- ✅ Feedback visual apropiado

### 5. **Configuración de Plataforma**
Permisos configurados para:
- ✅ **Android**: `USE_BIOMETRIC`, `USE_FINGERPRINT`
- ✅ **iOS**: `NSFaceIDUsageDescription`

## 🔐 Flujo de Uso

### Primera vez (Habilitar Biometría)

1. **Usuario abre Login Screen**
   - Si el dispositivo tiene biometría, verá un checkbox
   - Ejemplo: "Habilitar inicio con Huella dactilar" o "...con Face ID"

2. **Usuario inicia sesión normalmente**
   - Ingresa email y contraseña
   - Marca el checkbox para habilitar biometría
   - Presiona "Iniciar Sesión"

3. **Credenciales se guardan de forma segura**
   - Se almacenan cifradas en Flutter Secure Storage
   - Solo accesibles después de autenticación biométrica

### Inicios de sesión posteriores

1. **Usuario abre Login Screen**
   - Ve el botón "Iniciar con Huella dactilar" (o Face ID)
   - El email se pre-carga automáticamente

2. **Usuario presiona botón biométrico**
   - Aparece el diálogo nativo del sistema
   - Usuario autentica con su huella/Face ID

3. **Login automático**
   - Si la biometría es exitosa, login instantáneo
   - Redirige a la pantalla principal

## 🛠️ Componentes Técnicos

### Dependencias Añadidas

```yaml
dependencies:
  local_auth: ^2.3.0  # Autenticación biométrica nativa
```

### Archivos Creados/Modificados

#### Nuevos Archivos
- `lib/core/services/biometric_service.dart`

#### Archivos Modificados
- `pubspec.yaml` - Añadida dependencia local_auth
- `lib/core/services/storage_service.dart` - Métodos para credenciales biométricas
- `lib/features/auth/presentation/providers/auth_provider.dart` - Login biométrico
- `lib/features/auth/presentation/screens/login_screen.dart` - UI actualizada
- `android/app/src/main/AndroidManifest.xml` - Permisos Android
- `ios/Runner/Info.plist` - Descripción Face ID

## 📱 Compatibilidad

### Android
- **Mínimo**: Android 6.0 (API 23)
- **Biometrías soportadas**: Huella dactilar, Face Unlock, Iris
- **Fallback**: PIN/patrón del dispositivo

### iOS
- **Mínimo**: iOS 11.0
- **Biometrías soportadas**: Touch ID, Face ID
- **Fallback**: Código de acceso del dispositivo

## 🔒 Seguridad

### Almacenamiento de Credenciales
- ✅ Usa `flutter_secure_storage` con cifrado nativo
- ✅ **Android**: Almacenamiento cifrado con Android Keystore
- ✅ **iOS**: Almacenamiento en iOS Keychain
- ✅ Credenciales solo accesibles tras autenticación biométrica exitosa

### Privacidad
- ✅ Los datos biométricos NUNCA salen del dispositivo
- ✅ La app solo recibe un resultado de éxito/fallo
- ✅ Las credenciales se eliminan al cerrar sesión (opcional)

## 🧪 Testing

### Verificar en Dispositivo Real
```bash
# Ejecutar en dispositivo físico (recomendado para biometría)
flutter run --release

# O en modo debug
flutter run
```

### Simular en Emulador

#### Android Emulator
1. Configurar: Settings → Security → Fingerprint
2. Usar adb para simular huella:
```bash
adb -e emu finger touch 1
```

#### iOS Simulator
1. Features → Face ID → Enrolled
2. Features → Face ID → Matching Face (para éxito)
3. Features → Face ID → Non-matching Face (para fallo)

## 🐛 Solución de Problemas

### "Biometría no disponible"
- **Causa**: Dispositivo no tiene biometría configurada
- **Solución**: Configurar huella/Face ID en ajustes del dispositivo

### "No hay credenciales guardadas"
- **Causa**: Usuario no ha habilitado biometría previamente
- **Solución**: Hacer login con checkbox marcado primero

### Permisos denegados (Android)
- **Causa**: Permisos no están en AndroidManifest.xml
- **Solución**: Verificar que existan los permisos USE_BIOMETRIC

### Face ID no funciona (iOS)
- **Causa**: Falta descripción en Info.plist
- **Solución**: Verificar NSFaceIDUsageDescription en Info.plist

## 📝 Notas de Desarrollo

### Mejores Prácticas Implementadas
- ✅ Verificación de disponibilidad antes de mostrar opciones
- ✅ Manejo de errores con feedback al usuario
- ✅ Fallback a login tradicional si biometría falla
- ✅ Respeto a las preferencias del usuario
- ✅ Limpieza de credenciales al logout (configurable)

### Futuras Mejoras Posibles
- [ ] Opción en configuración para deshabilitar biometría
- [ ] Re-autenticación biométrica para acciones sensibles
- [ ] Métricas de uso de autenticación biométrica
- [ ] Soporte para múltiples cuentas con biometría

## 👥 Experiencia de Usuario

### Flujo Optimizado
1. **Primera impresión**: Usuario ve opción moderna de biometría
2. **Configuración simple**: Un checkbox durante el login
3. **Uso recurrente**: Un toque para autenticar
4. **Seguridad**: Mantiene credenciales seguras localmente

### Beneficios
- ⚡ Login instantáneo (< 1 segundo)
- 🔐 Mayor seguridad (sin contraseñas visibles)
- 😊 Mejor UX (menos fricción)
- 📱 Experiencia nativa del OS

## 🚀 Despliegue

### Pasos para Producción

1. **Instalar dependencias**
```bash
cd fintech-mobile/money_flow
flutter pub get
```

2. **Construir para Android**
```bash
flutter build apk --release
# o
flutter build appbundle --release
```

3. **Construir para iOS**
```bash
flutter build ios --release
```

4. **Verificar permisos en stores**
- Google Play: Declarar uso de biometría
- App Store: NSFaceIDUsageDescription será revisado

---

## 📞 Contacto y Soporte

Para cualquier problema o pregunta sobre la autenticación biométrica, contactar al equipo de desarrollo.

---

**Implementado por**: AI Assistant  
**Fecha**: Noviembre 2025  
**Versión**: 1.0.0

