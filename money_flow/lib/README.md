# MoneyFlow - Estructura del Proyecto

## Organización por Features

Este proyecto está organizado siguiendo el patrón **Feature-First**, lo que significa que la funcionalidad está agrupada por características de la aplicación en lugar de por tipo de archivo.

```
lib/
├── core/                    # Configuración central de la app
│   └── theme/              # Temas y estilos globales
│       ├── app_colors.dart # Paleta de colores
│       └── app_theme.dart  # Configuración del tema
├── features/               # Características de la aplicación
│   └── auth/              # Módulo de autenticación
│       └── presentation/  # Capa de presentación
│           └── screens/   # Pantallas
│               └── register_screen.dart
├── shared/                # Componentes compartidos
│   └── widgets/          # Widgets reutilizables
│       ├── custom_button.dart
│       └── custom_text_field.dart
└── main.dart             # Punto de entrada de la aplicación
```

## Características Implementadas

### 🎨 Tema y Diseño
- Paleta de colores basada en el diseño proporcionado (#137fec como color primario)
- Tema personalizado que sigue Material Design 3
- Componentes reutilizables para mantener consistencia

### 🔐 Autenticación - Register Screen
- Pantalla de registro que replica exactamente el diseño HTML proporcionado
- Validación de formularios
- Componentes personalizados para campos de texto y botones
- Diseño responsive y centrado
- Estados de carga

## Componentes Reutilizables

### CustomTextField
Componente personalizado para campos de entrada que incluye:
- Validación integrada
- Iconos de prefijo personalizables
- Soporte para mostrar/ocultar contraseña
- Estilos consistentes con el diseño

### CustomButton
Botón personalizado que incluye:
- Estados de carga
- Colores personalizables
- Soporte para ancho completo o específico
- Efectos hover y pressed

## Colores del Tema

- **Primary**: #137FEC (Azul principal)
- **Background**: Slate-50 (Fondo general)
- **Surface**: Slate-100 (Campos de entrada)
- **Text**: Slate-900, 800, 700 (Jerarquía de texto)
- **Placeholders**: Slate-400
- **Borders**: Slate-300

### 📧 Gmail (correo bancario)
- Pantalla **Correo Gmail** (`/email-connection`) desde el perfil: OAuth vía backend (`GET /email-connections/gmail/authorize`), `url_launcher` abre el navegador.
- Tras autorizar, el backend redirige a `moneyflow://email-connected` (deep link registrado en Android/iOS); al volver a la app se refresca el estado automáticamente.

## Próximos Pasos

1. Implementar Login Screen
2. Agregar navegación entre pantallas
3. Implementar autenticación con backend
4. Agregar manejo de estado (Bloc/Riverpod)
5. Implementar pantallas principales de la aplicación
