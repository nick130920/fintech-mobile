# Guías de Diseño - Money Flow App

## 🎨 Filosofía de Diseño

### Principios Fundamentales
1. **Consistencia Visual**: Todos los elementos deben seguir un patrón visual uniforme
2. **Claridad y Simplicidad**: Interfaz limpia que facilite la comprensión
3. **Accesibilidad**: Diseño inclusivo para todos los usuarios
4. **Responsividad**: Adaptable a diferentes tamaños de pantalla
5. **Feedback Visual**: Retroalimentación clara para las acciones del usuario

---

## 🚫 REGLAS ESTRICTAS

### ❌ PROHIBIDO: Colores Hardcodeados
```dart
// ❌ NUNCA HACER ESTO
color: Colors.red
color: Color(0xFF123456)
backgroundColor: Colors.grey[50]

// ✅ SIEMPRE HACER ESTO
color: Theme.of(context).colorScheme.error
color: Theme.of(context).colorScheme.primary
backgroundColor: Theme.of(context).colorScheme.surface
```

### ✅ OBLIGATORIO: Usar AppTheme
```dart
// ✅ Usar colores del tema
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.onSurface
Theme.of(context).colorScheme.surfaceContainerHighest

// ✅ Usar estilos de texto del tema
Theme.of(context).textTheme.titleLarge
Theme.of(context).textTheme.bodyMedium
```

---

## 🎨 Paleta de Colores

### Colores Principales
- **Primary**: `AppColors.primary` (#137FEC)
- **Primary Hover**: `AppColors.primaryHover` (#0E6BC7)

### Colores Neutros (Slate)
- **slate50**: `AppColors.slate50` (#F8FAFC) - Fondos muy claros
- **slate100**: `AppColors.slate100` (#F1F5F9) - Fondos de cards
- **slate300**: `AppColors.slate300` (#CBD5E1) - Bordes
- **slate400**: `AppColors.slate400` (#94A3B8) - Texto secundario
- **slate500**: `AppColors.slate500` (#64748B) - Texto terciario
- **slate600**: `AppColors.slate600` (#475569) - Iconos
- **slate700**: `AppColors.slate700` (#334155) - Texto secundario
- **slate800**: `AppColors.slate800` (#1E293B) - Texto oscuro
- **slate900**: `AppColors.slate900` (#0F172A) - Texto principal

### Colores Semánticos
- **Error**: `AppColors.error` (#EF4444)
- **Success**: `AppColors.success` (#10B981)
- **Warning**: `AppColors.warning` (#F59E0B)

### Modo Oscuro
- **Background**: `AppColors.darkBackground` (#111827)
- **Surface**: `AppColors.darkSurface` (#1F2937)
- **OnSurface**: `AppColors.darkOnSurface` (#F9FAFB)

---

## 📏 Espaciado y Dimensiones

### Espaciado Estándar
```dart
// Espaciado entre elementos
const SizedBox(height: 8)    // Pequeño
const SizedBox(height: 16)   // Mediano
const SizedBox(height: 24)   // Grande
const SizedBox(height: 32)   // Extra grande

// Padding de contenedores
const EdgeInsets.all(16)     // Estándar
const EdgeInsets.all(24)     // Screen padding
```

### Border Radius
```dart
BorderRadius.circular(8)     // Pequeño
BorderRadius.circular(12)    // Estándar
BorderRadius.circular(16)    // Grande
BorderRadius.circular(20)    // Extra grande
```

---

## 🧩 Componentes Estándar

### 1. Headers con Ícono
```dart
Widget _buildHeader() {
  return Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.your_icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: 24,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Título Principal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'Subtítulo descriptivo',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
```

### 2. Campos de Formulario
```dart
Widget _buildFormField(String label, String hint, TextEditingController controller) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          filled: true,
        ),
      ),
    ],
  );
}
```

### 3. Botones Principales
```dart
Widget _buildPrimaryButton(String text, VoidCallback? onPressed, {bool isLoading = false}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    ),
  );
}
```

### 4. Selectores con Modal
```dart
Widget _buildSelector(String label, String? selectedValue, String hint, VoidCallback onTap) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              if (selectedValue != null) ...[
                // Contenido seleccionado
                Expanded(
                  child: Text(
                    selectedValue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ] else ...[
                Icon(Icons.category, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
              Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    ],
  );
}
```

### 5. Modals Bottom Sheet
```dart
void _showBottomSheetModal(BuildContext context, String title, Widget content) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    ),
  );
}
```

---

## 📱 Estructura de Pantallas

### AppBar Estándar
```dart
AppBar(
  title: const Text('Título de Pantalla'),
  backgroundColor: Colors.transparent,
  elevation: 0,
  actions: [
    TextButton(
      onPressed: onSave,
      child: const Text(
        'Guardar',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
)
```

### Estructura de Formulario
```dart
Scaffold(
  backgroundColor: Theme.of(context).colorScheme.surface,
  appBar: _buildAppBar(),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFormFields(),
          const SizedBox(height: 32),
          _buildPrimaryButton(),
        ],
      ),
    ),
  ),
)
```

---

## 🎯 Estados de Interacción

### Estados de Loading
```dart
// En botones
child: isLoading
    ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : Text('Texto del botón')

// En pantallas
if (provider.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### Estados de Error
```dart
if (provider.error != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error!),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  });
}
```

---

## 🔧 Herramientas de Validación

### Pre-commit Checklist
- [ ] No hay colores hardcodeados
- [ ] Se usa `Theme.of(context)` para todos los colores
- [ ] Los espaciados siguen el estándar definido
- [ ] Los border radius son consistentes
- [ ] Los componentes siguen los patrones establecidos
- [ ] Hay validación de estados de loading/error
- [ ] Los textos siguen la jerarquía tipográfica

### Comandos de Verificación
```bash
# Buscar colores hardcodeados
grep -r "Color(0x" lib/
grep -r "Colors\." lib/

# Verificar imports del tema
grep -r "app_theme.dart" lib/
```

---

## 🚀 Ejemplos de Implementación

### ✅ Implementación Correcta
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Theme.of(context).colorScheme.outline),
  ),
  child: Text(
    'Contenido',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)
```

### ❌ Implementación Incorrecta
```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.grey),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 5,
      ),
    ],
  ),
  child: Text(
    'Contenido',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
)
```

---

## 📋 Conclusión

Estas reglas aseguran que la aplicación Money Flow mantenga una identidad visual consistente, sea accesible y fácil de mantener. **La adherencia a estas guías es obligatoria** para todos los componentes nuevos y actualizaciones.

**Recuerda**: Un diseño consistente = Mejor experiencia de usuario = Mayor confianza en la aplicación financiera.
