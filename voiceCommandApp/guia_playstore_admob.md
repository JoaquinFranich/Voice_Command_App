# Guía de Publicación en Play Store y AdMob

Esta guía cubre los pasos para subir tu APK/AAB a Google Play Console y cómo integrar publicidad (AdMob) en tu proyecto Godot.

---

## Parte 1: Subir a Google Play Store

### 1. Preparar el Archivo AAB (Android App Bundle)
Google Play ya no prefiere APKs, sino **AAB (App Bundles)**, que son más eficientes.

1.  En Godot, ve a **Proyecto > Exportar > Android**.
2.  En **Options**, asegúrate de que **Export Format** esté en **Export AAB**.
3.  **Firmado (Keystore):**
    *   Para la tienda, NO puedes usar la clave de debug.
    *   Genera una clave propia (ver guía de exportación).
    *   Configura la ruta de tu `.keystore`, usuario y contraseña en las secciones **Release** del preset de exportación.
4.  Desmarca **Export With Debug**.
5.  Dale a **Exportar Proyecto** y guarda el archivo `.aab`.

### 2. Google Play Console
1.  Crea una cuenta de desarrollador en [Google Play Console](https://play.google.com/console) (cuesta $25 USD pago único).
2.  **Crear Aplicación:**
    *   Clic en "Crear aplicación".
    *   Ingresa Nombre, Idioma predeterminado, y si es App o Juego.
3.  **Configuración de la Ficha:**
    *   Sube el Icono (512x512), Capturas de pantalla (Móvil y Tablet 7"/10"), Gráfico de funciones (1024x500).
    *   Redacta la Descripción breve y completa.
4.  **Clasificación de Contenido y Privacidad:**
    *   Rellena los cuestionarios sobre contenido (violencia, etc.).
    *   **Política de Privacidad:** Como usas micrófono, ES OBLIGATORIO tener una URL con política de privacidad (puedes generar una gratis en sitios web y alojarla en Google Sites).
5.  **Subir Versión (Release):**
    *   Ve a **Producción** (o Pruebas internas primero).
    *   Clic en "Crear nueva versión".
    *   Sube tu archivo `.aab`.
    *   Revisa y completa el lanzamiento.
6.  **Revisión:** Google tardará unos días (1-7) en revisar y aprobar tu app.

---

## Parte 2: Integrar Publicidad (AdMob)

Para poner anuncios en Godot, necesitas un Plugin de Android (como `Godot AdMob Plugin` de Poing Studios, que es el más popular).

### 1. Descargar e Instalar Plugin
1.  Busca "Godot AdMob Plugin" en GitHub (repo de `Poing-Studios/godot-admob-android`).
2.  Descarga la versión compatible con tu Godot (4.x).
3.  Copia la carpeta `addons/admob` a tu proyecto.
4.  Copia los archivos `.aar` y `.gdap` del plugin a tu carpeta `android/plugins`.

### 2. Configurar AdMob
1.  Ve a [AdMob](https://admob.google.com) y crea una cuenta.
2.  **Crear Aplicación:** Añade tu app (Android). Copia el **App ID**.
3.  **Crear Bloques de Anuncios:** Crea un bloque tipo "Banner" o "Intersticial". Copia el **Ad Unit ID**.

### 3. Configurar en Godot
1.  En Godot, ve a **Proyecto > Exportar > Android > Options**.
2.  En la sección **Plugins**, marca la casilla **AdMob**.
3.  En tu script principal (ej. `MainMenu_New.gd` o un Autoload `AdsManager.gd`):

```gdscript
extends Node

var admob = null
var is_real = false # Pon true para producción
var ad_unit_id = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY" # Tu ID del Banner

func _ready():
    if Engine.has_singleton("AdMob"):
        admob = Engine.get_singleton("AdMob")
        # Inicializar (usa true en is_real solo al subir a tienda)
        admob.initWithContentRating(is_real, "G", false, true)
        
        # Cargar Banner
        admob.loadBanner(ad_unit_id, true) # true = top, false = bottom

func _show_banner():
    if admob: admob.showBanner()

func _hide_banner():
    if admob: admob.hideBanner()
```

### 4. Manifest y IDs
*   En la configuración del plugin (o en `AndroidManifest.xml` si editas manualmente), debes pegar tu **AdMob App ID** (el que empieza por `ca-app-pub-...~...`).
*   **Importante:** Nunca uses IDs reales mientras pruebas en el editor o en tu móvil personal, Google podría banearte. Usa siempre los IDs de prueba de Google o el modo `is_real = false`.

### 5. Exportar
Al exportar con el plugin activado (+ Gradle Build), Godot incluirá las librerías de Google Ads automáticamente.
