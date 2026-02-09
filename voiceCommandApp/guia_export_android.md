# Guía de Exportación a Android (APK)

Esta guía te explico paso a paso cómo convertir tu proyecto de Godot en un archivo `.apk` instalable en cualquier móvil Android.

## Requisitos Previos

Antes de exportar, asegúrate de haber seguido la guía de **Depuración Remota** para tener configuados:
1.  **Android SDK Path** en `Editor > Configuración del Editor > Exportar > Android`.
2.  **Java SDK Path** en la misma sección.
3.  **Plantilla de Compilación (Android Build Template)** instalada (`Proyecto > Instalar Plantilla...`).

## Paso 1: Configurar el Preset de Exportación

1.  Ve a **Proyecto > Exportar...**.
2.  Si no tienes un preset de **Android**, haz clic en **Añadir...** y selecciona **Android**.
3.  Configura las pestañas importantes:

### Pestaña "Options"
*   **Package > Unique Name:** Esto es VITAL para la Play Store. Debe ser algo único y seguir el formato de dominio inverso.
    *   Ejemplo: `com.tuempresa.voicecommandapp`
    *   *Nota: Una vez subido a la tienda, ¡no podrás cambiar esto!*
*   **Package > Name:** El nombre que se ve en el menú del móvil (ej. "Voice Sport Counter").
*   **Version > Code:** Entero incremental (1, 2, 3...). Cada actualización en Play Store requiere un número mayor.
*   **Version > Name:** Texto visible para el usuario (1.0, 1.1, 2.0-beta).

### Pestaña "Permissions"
Asegúrate de marcar los permisos que necesita tu app:
*   [x] **Record Audio** (Fundamental para el reconocimiento de voz).
*   [x] **Internet** (Si usas Google STT online o ads).

### Pestaña "Gradle Build"
*   [x] **Use Gradle Build:** DEBE estar activado porque usas plugins nativos (VoxPopuli/STT).

## Paso 2: Exportar el APK

1.  En la ventana de Exportación, haz clic en **Exportar Proyecto...**.
2.  **Modo Debug vs Release:**
    *   Si desmarcas **"Export With Debug"**, se genera un APK de producción (firmado para lanzamiento). Esto requiere configurar una *Keystore*.
    *   Para pruebas rápidas o compartir con amigos, puedes dejar marcado **"Export With Debug"**. Godot usará una clave de prueba automática.
3.  Elige la carpeta y nombre del archivo (ej. `VoiceSportCounter.apk`) y guarda.
4.  Godot compilará todo. Si usas Gradle Build, la primera vez puede tardar unos minutos descargando dependencias.

## Solución de Errores Comunes

*   **Error "Keystore not found":** Si exportas en modo Release (sin debug), necesitas crear tu propia llave de firmado.
    *   Comando para generar llave: `keytool -genkey -v -keystore my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000`
    *   Luego carga esa llave en las opciones de exportación (sección **Keystore**).
*   **Error de Plugin/Gradle:** Si la exportación falla al compilar, intenta borrar la carpeta `android/build` y vuelve a instalar la plantilla (`Proyecto > Instalar Plantilla...`).

---
¡Listo! Copia el archivo APK a tu móvil y ejecútalo para instalar la aplicación.
