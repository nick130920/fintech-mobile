# 🚀 Configuración CodeMagic - Guía Paso a Paso

## 📋 Antes de empezar

✅ Cuenta Google Play Console creada  
✅ App creada en Google Play Console  
⏳ Service Account configurado  
⏳ Keystore generado  
⏳ CodeMagic configurado  

---

## **Paso 1: Generar Keystore** 🔐

1. **Ejecuta el script:**
   ```bash
   # Desde la carpeta del proyecto
   .\generate_keystore.bat
   ```

2. **Completa la información solicitada:**
   - **Contraseña del keystore:** (guárdala bien!)
   - **Contraseña de la clave:** (puede ser la misma)
   - **Nombre y apellido:** Tu nombre
   - **Unidad organizacional:** Tu empresa/proyecto
   - **Organización:** Tu empresa
   - **Ciudad:** Tu ciudad
   - **Estado:** Tu estado/provincia
   - **Código de país:** MX (o tu país)

3. **Crear key.properties:**
   ```properties
   storePassword=TU_CONTRASEÑA_STORE
   keyPassword=TU_CONTRASEÑA_KEY
   keyAlias=key
   storeFile=key.jks
   ```

---

## **Paso 2: Configurar CodeMagic** ⚙️

### 2.1 Crear cuenta
1. Ve a [codemagic.io](https://codemagic.io)
2. Regístrate con GitHub/GitLab/Bitbucket
3. Conecta tu repositorio de Money Flow

### 2.2 Configurar aplicación
1. **Selecciona tu repositorio**
2. **Clic en "Set up build"**
3. **Selecciona "Flutter App"**
4. **Workflow:** Selecciona "codemagic.yaml"

### 2.3 Subir keystore
1. **Ve a:** Team settings → Code signing identities
2. **Clic:** "Android keystores"
3. **Upload:** Sube tu archivo `android/key.jks`
4. **Keystore reference:** `keystore_reference`
5. **Keystore password:** Tu contraseña del keystore
6. **Key alias:** `key`
7. **Key password:** Tu contraseña de la key

---

## **Paso 3: Variables de Entorno** 🔧

En CodeMagic, ve a **App settings → Environment variables**:

### Grupo: `google_play`
```
GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
Valor: [Pega todo el contenido del archivo JSON del Service Account]
```

### Variables adicionales:
```
KEY_ALIAS = key
KEY_PASSWORD = [tu contraseña de key]
STORE_PASSWORD = [tu contraseña de store]
STORE_FILE = /tmp/keystore.jks
```

---

## **Paso 4: Configurar Triggers** 🎯

1. **Ve a:** App settings → Build triggers
2. **Activa:** "Trigger on push"
3. **Branch:** `main` o `master`
4. **Webhook:** Se configura automáticamente

---

## **Paso 5: Primera Build** 🚀

### Opción A: Push automático
```bash
git add .
git commit -m "feat: configure CodeMagic deployment"
git push origin main
```

### Opción B: Build manual
1. Ve a tu app en CodeMagic
2. Clic "Start new build"
3. Selecciona branch `main`
4. Clic "Start build"

---

## **Paso 6: Monitorear Build** 📊

1. **Ve a:** Builds en tu dashboard
2. **Observa:** Los logs en tiempo real
3. **Espera:** ~10-15 minutos para la primera build

### Estados posibles:
- 🟡 **Building:** En progreso
- 🟢 **Success:** ¡Exitoso! APK subido a Google Play
- 🔴 **Failed:** Revisa los logs

---

## **Solución de Problemas** 🔧

### ❌ Error: "Keystore not found"
- Verifica que subiste el keystore correctamente
- Revisa que el nombre de referencia sea `keystore_reference`

### ❌ Error: "Google Play API"
- Verifica el Service Account JSON
- Confirma permisos en Google Play Console
- Revisa que el package name coincida

### ❌ Error: "Build failed"
- Revisa que el proyecto compile localmente
- Verifica que todas las dependencias estén en pubspec.yaml
- Revisa los logs detallados en CodeMagic

---

## **Verificar Despliegue** ✅

1. **Ve a Google Play Console**
2. **Selecciona tu app**
3. **Ve a:** Release → Testing → Internal testing
4. **Deberías ver:** Nueva versión disponible

---

## **Comandos Útiles** 💻

```bash
# Verificar keystore
keytool -list -v -keystore android/key.jks

# Build local para testing
flutter build appbundle --release

# Limpiar proyecto
flutter clean && flutter pub get

# Ver información del keystore
keytool -list -keystore android/key.jks
```

---

## **Checklist Final** ✅

- [ ] Service Account creado y vinculado
- [ ] Keystore generado y subido a CodeMagic
- [ ] Variables de entorno configuradas
- [ ] codemagic.yaml en el repositorio
- [ ] Build trigger configurado
- [ ] Primera build ejecutada exitosamente
- [ ] App visible en Google Play Console

¡Tu app debería estar desplegándose automáticamente! 🎉
