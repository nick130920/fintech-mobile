# 🚀 Guía de Despliegue - Money Flow

## Configuración CodeMagic para Google Play Store

### 📋 Requisitos Previos

1. **Cuenta Google Play Console** ($25 USD registro único)
2. **Cuenta CodeMagic** (gratis para repos públicos)
3. **Keystore generado** para firma de aplicación
4. **Service Account** configurado en Google Cloud

### 🔐 1. Generar Keystore

```bash
# Ejecutar desde la raíz del proyecto
chmod +x scripts/generate_keystore.sh
./scripts/generate_keystore.sh
```

O manualmente:
```bash
keytool -genkey -v -keystore android/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

### 🏪 2. Configurar Google Play Console

1. **Crear aplicación:**
   - Ve a [Google Play Console](https://play.google.com/console)
   - Crea nueva aplicación
   - Completa información básica

2. **Configurar Service Account:**
   - Ve a Google Cloud Console
   - Crea Service Account
   - Descarga JSON de credenciales
   - En Play Console: Configuración → API Access → Vincular proyecto

### ⚙️ 3. Configurar CodeMagic

1. **Conectar repositorio:**
   - Ve a [CodeMagic](https://codemagic.io)
   - Conecta tu repositorio GitHub/GitLab/Bitbucket

2. **Configurar variables de entorno:**
   ```
   GCLOUD_SERVICE_ACCOUNT_CREDENTIALS: [contenido del JSON]
   KEY_ALIAS: key
   KEY_PASSWORD: [tu contraseña de key]
   STORE_PASSWORD: [tu contraseña de store]
   STORE_FILE: /tmp/keystore.jks
   ```

3. **Subir keystore:**
   - En CodeMagic: Team settings → Code signing identities
   - Sube tu archivo `key.jks`
   - Asigna referencia: `keystore_reference`

### 📱 4. Configurar Application ID

**IMPORTANTE:** Cambia el Application ID antes del primer despliegue:

```kotlin
// android/app/build.gradle.kts
defaultConfig {
    applicationId = "com.tuempresa.money_flow" // ⚠️ CAMBIAR ESTO
}
```

### 🔄 5. Workflow de Despliegue

El archivo `codemagic.yaml` está configurado para:

- **Trigger:** Push a `main` branch
- **Build:** AAB (Android App Bundle)
- **Track:** Internal testing (configurable)
- **Versioning:** Automático basado en build number

### 📊 6. Monitoreo y Logs

- **Build logs:** Disponibles en CodeMagic dashboard
- **Crash reports:** Google Play Console → Calidad → Informes de errores
- **Analytics:** Google Play Console → Estadísticas

### 🚨 7. Solución de Problemas

#### Error de firma:
```bash
# Verificar keystore
keytool -list -v -keystore android/key.jks
```

#### Error de permisos Google Play:
- Verificar Service Account tiene permisos de "Release Manager"
- Verificar JSON credentials está bien configurado

#### Build fallido:
- Revisar logs en CodeMagic
- Verificar todas las variables de entorno
- Comprobar que el keystore está subido correctamente

### 📝 8. Checklist Pre-Despliegue

- [ ] Application ID único configurado
- [ ] Keystore generado y subido a CodeMagic
- [ ] Service Account configurado en Google Play
- [ ] Variables de entorno configuradas
- [ ] Aplicación creada en Google Play Console
- [ ] Permisos de Service Account verificados
- [ ] Primera versión subida manualmente (opcional)

### 🎯 9. Comandos Útiles

```bash
# Generar keystore
./scripts/generate_keystore.sh

# Build local para testing
flutter build appbundle --release

# Verificar keystore
keytool -list -v -keystore android/key.jks

# Limpiar build
flutter clean && flutter pub get
```

### 📧 10. Notificaciones

El workflow está configurado para enviar emails en:
- ✅ Build exitoso
- ❌ Build fallido

Actualiza los emails en `codemagic.yaml`:
```yaml
email:
  recipients:
    - tu-email@ejemplo.com
```

---

## 🔄 Flujo de Desarrollo

1. **Desarrollo local** → Push a `main`
2. **CodeMagic** detecta cambios → Inicia build
3. **Build AAB** → Tests automáticos
4. **Deploy** → Google Play (Internal Track)
5. **Notificación** → Email de resultado

¡Tu app estará disponible en Google Play Console para distribución! 🎉
