# Guía de Depuración y Ejecución en Android (One-Click Deploy)

Esta guía explica cómo configurar y ejecutar tu proyecto de Godot directamente en un dispositivo Android conectado por USB.

## 1. Preparar el Dispositivo Móvil (Android)

1.  **Activar Opciones de Desarrollador**:
    *   Ve a **Ajustes** > **Acerca del teléfono**.
    *   Busca **Número de compilación** y tócalo 7 veces seguidas hasta que aparezca un mensaje indicando que ya eres desarrollador.
2.  **Habilitar Depuración por USB**:
    *   Ve a **Ajustes** > **Sistema** (o Ajustes Adicionales) > **Opciones para desarrolladores**.
    *   Activa la opción **Depuración por USB**.
3.  **Conectar al PC**:
    *   Conecta el móvil al ordenador usando un cable USB de datos.
    *   En la pantalla del móvil aparecerá un mensaje: **"¿Permitir depuración por USB?"**. Marca "Permitir siempre desde este ordenador" y pulsa **Aceptar**.

## 2. Verificar Configuración en Godot

Godot necesita saber dónde están instalados el Android SDK y el JDK (Java).

1.  En Godot, ve a **Editor** > **Configuración del Editor**.
2.  En la barra lateral, busca la sección **Exportar** > **Android**.
3.  Verifica las siguientes rutas:
    *   **Android SDK Path**: Debe apuntar a la carpeta donde está instalado el SDK de Android (ej. `%LOCALAPPDATA%\Android\Sdk`).
    *   **Java SDK Path**: Debe apuntar a la instalación de JDK (ej. `C:\Program Files\Eclipse Adoptium\jdk-17...`).
    *   *Nota: Si tienes Android Studio instalado, estas rutas suelen configurarse automáticamente o son fáciles de encontrar.*

## 3. Instalar Plantilla de Compilación (Requerido para Plugins)

Dado que tu proyecto utiliza el plugin `SpeechToText`, es necesario que Godot use una plantilla de compilación personalizada de Android (Gradle Build) para incluir las librerías nativas.

1.  En Godot, ve al menú **Proyecto**.
2.  Selecciona **Instalar Plantilla de Compilación de Android...**.
3.  Haz clic en **Instalar** en la ventana emergente.
    *   Esto creará una carpeta `android/build` en la raíz de tu proyecto.
    *   **Importante**: Si haces cambios profundos en la configuración de exportación o plugins, a veces es necesario reinstalar esta plantilla.

## 4. Ejecutar el Juego (One-Click Deploy)

Una vez configurado todo, ejecutar el juego en el móvil es tan sencillo como darle a un botón.

1.  Asegúrate de que tu móvil esté conectado y desbloqueado.
2.  Mira en la **esquina superior derecha** del editor de Godot.
3.  Deberías ver un icono de **Android** (o un monitor pequeño) que se ha "iluminado" o activado.
    *   Si pasas el ratón por encima, debería decir el nombre de tu dispositivo (ej. "Sistema Android").
4.  Haz clic en ese icono **"Ejecución Remota"**.
5.  Godot comenzará a:
    *   Compilar el proyecto.
    *   Crear el APK de depuración.
    *   Instalarlo en tu móvil.
    *   Abrirlo automáticamente.

### Solución de Problemas Comunes

*   **"No device found"**: Revisa que el cable USB esté bien conectado y que hayas aceptado la depuración USB en el móvil. Verifica si necesitas drivers ADB para tu modelo específico de móvil.
*   **Error de compilación Gradle**: Suele ocurrir si faltan licencias o versiones específicas del SDK. Abre `android/build/config.gradle` (si existe) para revisar versiones, o intenta reinstalar la plantilla de compilación.
*   **La App se cierra al abrir**: Conecta el móvil y usa el **Monitor** de Godot (panel inferior > Depurador) para ver los logs en tiempo real y detectar el error (ej. permisos faltantes).
