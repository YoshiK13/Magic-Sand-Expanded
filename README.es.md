# Magic Sand

[![Licencia: GPL v2](https://img.shields.io/badge/Licencia-GPL_v2-blue.svg)](COPYING)
[![openFrameworks 0.9.3](https://img.shields.io/badge/openFrameworks-0.9.3-brightgreen.svg)](https://openframeworks.cc/)
[![Plataforma](https://img.shields.io/badge/Plataforma-Linux%20%7C%20Windows%20%7C%20macOS-orange.svg)](#instrucciones-por-sistema-operativo)

> **Language / Idioma:** [English Version (README.md)](README.md) | **Español**

---

**Magic Sand** es un software de código abierto para operar areneros de realidad aumentada (AR Sandbox) interactivos:

![Primera vista del arenero Magic Sandbox](./art/general-view-2.jpg)

Un arenero de realidad aumentada está compuesto por una caja de arena física, un sensor de profundidad (como el sensor Kinect) y un proyector de video emparejados. El software provisto en este repositorio controla el proyector y el sensor Kinect para proyectar sobre la arena curvas de nivel topográficas y colores dinámicos en tiempo real, calculados según la altura medida de la arena.

Este proyecto fue inspirado y adaptado del proyecto pionero [Augmented Reality Sandbox](https://arsandbox.ucdavis.edu) desarrollado por [UC Davis](http://idav.ucdavis.edu/~okreylos/ResDev/SARndbox/). Es una adaptación parcial del software [SARndbox](https://github.com/KeckCAVES/SARndbox) de Oliver Kreylos bajo [openframeworks](http://openframeworks.cc/) y utiliza algoritmos de calibración derivados de [ofxKinectProjectorToolkit](https://github.com/genekogan/ofxKinectProjectorToolkit) por Gene Kogan.

Fue portado a openFrameworks con compatibilidad multiplataforma (Linux / macOS / Windows), una interfaz gráfica sencilla y un procedimiento de calibración robusto por [Thomas Wolf](https://thomwolf.io), y posteriormente ampliado con juegos educativos interactivos por [Rasmus R. Paulsen](http://people.compute.dtu.dk/rapa).

![Animación de Magic Sandbox](./art/animated-box.gif)

Magic Sand fue desarrollado con el objetivo primordial de facilitar el uso de un arenero de realidad aumentada en entornos domésticos, educativos y familiares:
- Funcionar en portátiles y computadoras de gama media (Windows / macOS / Linux, requisitos mínimos de GPU).
- Calibración rápida y sencilla para montar, desmontar y transportar el arenero con facilidad.
- Interfaz gráfica accesible e intuitiva.
- Arquitectura extensible para el desarrollo de nuevos juegos y aplicaciones sobre la arena.

![Vista de Magic Sandbox](./art/general-view.jpg)

---

## Características Principales

Funciona en una computadora conectada a un proyector convencional y un sensor Kinect. El software proyecta gradientes de color continuos e isolíneas en función de la altura del relieve medido por la Kinect, transformando cualquier caja de arena en un entorno interactivo y visualmente atractivo.

![Vista de la interfaz de control](./art/explication.png)

---

## Montaje Físico y Requisitos de Hardware

1. **Guía de Montaje:**
   La manera más directa de armar la estructura física se encuentra descrita paso a paso en el [tutorial de montaje](https://imgur.com/gallery/Q86wR) y en el [hilo de Reddit DIY](https://www.reddit.com/r/DIY/comments/4v1gfi/a_magic_sandbox_i_made_for_my_3_yo_sons_birthday/).

2. **Componentes Necesarios:**
   - **Sensor Kinect:** Xbox 360 Kinect (Modelo 1414) o Kinect for Windows v1 (Modelo 1473).
   - **Fuente de Alimentación de 12V dedicada:** El sensor Kinect requiere estar enchufado a la toma de corriente eléctrica de la pared (la energía del cable USB es insuficiente para alimentar el láser infrarrojo y los motores).
   - **Proyector de Video:** Orientado cenitalmente hacia abajo, apuntando directamente sobre la superficie del arenero.
   - **Caja de Arena:** Con arena fina blanca o clara para una reflexión cromática óptima.
   - **Puerto USB 2.0:** Conectar el sensor a un puerto nativo **USB 2.0 (color negro)** o mediante un HUB USB 2.0 (evita controladores USB 3.0/3.1 conflictivos que puedan causar microcortes en el flujo de profundidad).

---

## Instrucciones por Sistema Operativo

### Windows (Windows 10, Windows 8, Windows 7)

#### Requisitos Previos e Instalación de Controladores:
1. **Actualizar Controladores de Video:** Asegúrate de tener actualizados los controladores de tu tarjeta gráfica.
2. **Instalar Componentes Visual C++ Runtime:**
   - Descarga e instala los componentes [Visual C++ Redistributable 2015](https://www.microsoft.com/en-us/download/details.aspx?id=48145).
   - **Importante:** Instala el componente **x86**, incluso si utilizas una versión de Windows de 64 bits.
3. **Instalar Controladores USB con Zadig:**
   - Descarga la herramienta gratuita de controladores USB [Zadig](http://zadig.akeo.ie/).
   - Conecta el sensor Kinect y ejecuta Zadig.
   - En el menú desplegable de dispositivos, localiza **Xbox Camera**, **Xbox Motor** y **Xbox Audio**.
   - Para cada uno de estos subdispositivos, selecciona el controlador **libusb-win32 (v1.2.6.0)** mediante las flechas de selección y presiona **Install Driver** (o **Replace Driver**).
   - Es necesario repetir esta operación para cada uno de los subdispositivos: una vez para la cámara, una vez para el motor y una vez para el audio.
   - Para más detalles, consulta la [guía de libfreenect para Windows](https://github.com/OpenKinect/libfreenect#windows) y la [documentación de ofxKinect para Windows](https://github.com/openframeworks/openFrameworks/tree/master/addons/ofxKinect#windows).
4. **Solución a Problemas de Detección:**
   - Si la Kinect no es detectada tras ejecutar Zadig, instala el paquete [Microsoft Kinect for Windows SDK 1.0](https://www.microsoft.com/en-us/download/details.aspx?id=28782) (o SDK 1.8), reinicia el equipo y ejecuta nuevamente Zadig asegurando que `libusb-win32` quede asignado a los dispositivos de la Kinect.
   - En equipos con Windows 10 y Windows 11 sobre puertos USB 3.0, en ocasiones puede ser necesario desconectar y volver a conectar el cable USB del sensor una o dos veces tras iniciar la aplicación hasta que la imagen de profundidad se sincronice.

#### Compilación desde Código Fuente:
- Abre la solución [Magic-Sand.sln](Magic-Sand.sln) utilizando Visual Studio 2015 (toolset v140) vinculada con openFrameworks 0.9.3 para Windows.

---

### Mac OS X (Mac OS X 10.8+)

#### Inicio Rápido:
1. Descarga el paquete precompilado de Magic Sand para Mac y extráelo en cualquier carpeta de tu equipo.
2. Conecta el sensor Kinect (con su adaptador de 12V a la pared) y el proyector.
3. Ejecuta la aplicación `Magic Sand.app`.

#### Compilación desde Código Fuente:
- Abre el proyecto [Magic-Sand.xcodeproj](Magic-Sand.xcodeproj) con Xcode configurado con openFrameworks 0.9.3.
- En versiones modernas de macOS (Mojave o superior), asegúrate de autorizar los permisos de cámara cuando se soliciten en **Ajustes del Sistema > Privacidad y Seguridad > Cámara**.

---

### Linux

Históricamente, Magic Sand no contaba con binarios precompilados oficiales para Linux y únicamente ofrecía makefiles experimentales. En aquellas versiones iniciales, la gestión multimonitor en Linux presentaba problemas conocidos, obligando a muchos usuarios a ejecutar la aplicación utilizando únicamente el proyector sin pantalla secundaria de operador (proyectando la interfaz gráfica directamente sobre la arena).

El repositorio actual incorpora un empaquetado moderno mediante formato **AppImage** autónomo que soluciona el renderizado en dos pantallas, la gestión de permisos del sensor y la persistencia de datos mutables.

#### 1. Ejecución con AppImage Portátil:
```bash
chmod +x Magic-Sand-x86_64.AppImage
./Magic-Sand-x86_64.AppImage
```

#### 2. Configuración Inicial del Sensor Kinect (Permisos y Búfer USB):
El sensor Kinect v1 requiere reglas `udev` y una ampliación de memoria de búfer USB en el kernel (64 MB) para no saturar las transferencias isócronas de datos de profundidad y video:
```bash
# Configuración automática a través del parámetro de la AppImage:
./Magic-Sand-x86_64.AppImage --setup-kinect

# O ejecutando directamente el script incluido con permisos de administrador:
sudo ./setup_kinect_linux.sh
```
*Si deseas desinstalar estas configuraciones en cualquier momento, ejecuta: `sudo ./setup_kinect_linux.sh --uninstall`.*

#### 3. Directorio de Datos Persistentes del Usuario:
Debido a que el contenedor AppImage se monta en modo de solo lectura (SquashFS), Magic Sand sincroniza automáticamente las carpetas de configuración en una ruta mutable:
- **Predeterminado:** `~/Magic-Sand/data/`
- **Modo Portable:** Si existe una carpeta llamada `data` o `Magic-Sand-Data` junto al archivo `.AppImage`, se utilizará dicha carpeta local.

Esto garantiza que las calibraciones (`calibration.xml`), archivos XML de configuración, mapas de color y récords de los juegos se guarden y mantengan intactos entre sesiones.

#### 4. Aviso de Compatibilidad Gráfica en Linux (NVIDIA / Intel / AMD):
- **Soportado y Recomendado:** Gráficos integrados **Intel** y tarjetas **AMD Radeon** con controladores libres de código abierto (**Mesa / Gallium**).
- **Estado con NVIDIA (Experimental / No Garantizado):**
  > [!WARNING]
  > Actualmente **NO se asegura ni se garantiza el correcto funcionamiento en sistemas Linux con tarjetas gráficas NVIDIA** (ni con controladores privativos oficiales ni en equipos portátiles con gráficos híbridos NVIDIA Optimus / PRIME).
  >
  > **Motivos técnicos conocidos:**
  > 1. openFrameworks 0.9.3 y la librería GLFW 3.1 presentan incompatibilidades al inicializar o mantener el contexto OpenGL/GLX frente a ciertas versiones del controlador privativo de NVIDIA.
  > 2. En escritorios modernos que utilizan **Wayland** (por defecto en Ubuntu, Fedora, etc.), los controladores de NVIDIA suelen generar fallos de protocolo bajo XWayland (aunque el AppImage incorpora un parche de intercepción en `libxwayland_fix.so` para prevenir bloqueos).
  > 3. Aunque el lanzador integra variables experimentales de render offload (`__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia`), si experimentas pantallas en blanco, cierres inesperados (`Segmentation fault`) o caídas bruscas de fotogramas, se recomienda iniciar sesión en **X11 (Xorg)** o forzar la ejecución en una gráfica Intel o AMD.

---

## Calibración y Puesta en Marcha

Conecta y enciende el proyector y el sensor Kinect, y luego inicia el software.

Por defecto, la aplicación inicia en modo **configuración** (`setup`):
- En la ventana del operador se visualiza la imagen de profundidad o color de la Kinect.
- El proyector emite una imagen completamente blanca. Esto facilita alinear físicamente el proyector sobre la arena, verificar que el haz de luz cubra los bordes de la caja y comprobar la conectividad de la Kinect.
- El estado de la Kinect y el proyector se puede verificar en la ventana inferior izquierda de la interfaz.
- En modo configuración se puede ajustar y optimizar la inclinación y posición física de la Kinect y el proyector.

### Pasos para Calibrar
Para establecer la correspondencia geométrica entre el sensor de profundidad 3D y la ventana 2D del proyector:

1. **Alisa la arena** de la caja de la forma más uniforme y plana posible.
2. Comprueba que ves la imagen de profundidad o color de la Kinect en la ventana principal (haz clic en **advanced | Display Kinect Depth View**).
3. Presiona **Calibration | Manually Draw Sand Region**.
4. Delimita la región de la arena dibujando un rectángulo con el ratón sobre la vista de la Kinect en la ventana del operador.
5. Presiona **Automatically Calibrate Kinect & Projector**: se proyectará secuencialmente una serie de tableros de ajedrez sobre la arena.
6. Cuando aparezca el aviso en pantalla, **cubre la caja de arena con un cartón o tabla plana de color claro** a una altura uniforme sobre la arena.
7. Haz clic en **OK**: se proyectará otra serie de tableros de ajedrez sobre la tabla para calibrar el plano de elevación.

Si la calibración concluye con éxito, el panel de estado se actualizará indicando que el sistema está listo.

![Animación del procedimiento de calibración](./art/calibration.gif)

### Consejos para una Buena Calibración:
- **Apagar o atenuar la iluminación de la habitación:** Dependiendo de las lámparas o luz ambiental, una iluminación fuerte puede lavar las esquinas de los tableros de ajedrez proyectados. Atenuar la luz facilita una detección rápida y precisa de los puntos de calibración.
- **Usar una cubierta perfectamente plana y mate:** Para la segunda fase de calibración, asegúrate de que el cartón o tabla sea totalmente plano y rígido (si se curva, el plano de altura quedará falseado). Además, utiliza una superficie con acabado **mate** (no brillante), ya que los materiales reflectantes causan rebotes que ciegan el sensor de profundidad infrarrojo de la Kinect.

#### Modo de Depuración de Calibración:
Si la calibración falla, activa la casilla **advanced | Dump Debug** y repite el proceso. Se guardarán imágenes de diagnóstico en la carpeta `data/DebugFiles/` para identificar puntos no detectados.

---

## Configuración Física: Montaje Invertido (Modo Inverted)

En instalaciones físicas permanentes, ferias de ciencias o museos, por cuestiones de espacio o estructura, suele ser necesario montar el proyector y la Kinect en el lado opuesto al que se sitúa el público o los jugadores.

Si se utiliza ese montaje sin invertir, los textos proyectados, los marcadores numéricos y los animales aparecerán al revés, y los peces y conejos parecerán desplazarse hacia atrás.

### Cómo Activar el Modo Invertido:
- **Desde la interfaz gráfica:** En el panel lateral izquierdo, despliega la carpeta **`advanced`** y activa la casilla **`Inverted`**.
- **Desde el archivo de configuración:** En `settings/kinectProjectorSettings.xml`, establece:
  ```xml
  <Inverted>1</Inverted>
  ```

### Efecto Interno del Modo Invertido:
1. Aplica automáticamente una transformación geométrica de 180° (`ofRotate(180.0f)` con traslación) a la ventana del proyector.
2. Recalcula los ángulos locales y vectores de desplazamiento de las criaturas vivas (`getOrientedAngle` y `getOrientedX`), de modo que peces, tiburones y conejos naden y caminen mirando siempre hacia adelante con respecto a la vista del público.
3. Orienta el HUD y las puntuaciones de cara a los usuarios alrededor de la arena, manteniendo la interfaz de control del operador perfectamente orientada en la pantalla de la laptop.

---

## Tabla de Atajos de Teclado y Controles

Todas las funciones de juego, herramientas de diagnóstico y capturas pueden accionarse mediante el teclado:

| Tecla | Modo / Contexto | Función y Descripción |
| :---: | :--- | :--- |
| <kbd>Espacio</kbd> | Modo `SETUP` | **Iniciar Aplicación:** Sale del modo de configuración y proyecta la topografía activa con curvas de nivel sobre la arena. |
| <kbd>Espacio</kbd> | Modo `RUNNING` | **Modela una Isla:** Inicia el juego (si está inactivo), o avanza de fase / valida el contorno actual durante la partida. |
| <kbd>f</kbd> o <kbd>r</kbd> | Modo `RUNNING` | **The Sandimals / Terminar:** Inicia el juego para 2 jugadores en nivel estándar, o finaliza la partida activa de modelado de islas. |
| <kbd>1</kbd> | Modo `RUNNING` | Inicia *The Sandimals* en dificultad **Principiante Absoluto** (Nivel 0). |
| <kbd>2</kbd> | Modo `RUNNING` | Inicia *The Sandimals* en dificultad **Novato** (Nivel 1). |
| <kbd>3</kbd> | Modo `RUNNING` | Inicia *The Sandimals* en dificultad **Estándar** (Nivel 2). |
| <kbd>4</kbd> | Modo `RUNNING` | Inicia *The Sandimals* en dificultad **Experto** (Nivel 3). |
| <kbd>m</kbd> | Modo `RUNNING` | Inicia el juego cooperativo **Los animales y sus madres**. |
| <kbd>c</kbd> | Cualquier Modo | **Captura RGB:** Captura y guarda en disco una fotografía de la cámara a color de la Kinect. |
| <kbd>d</kbd> | Cualquier Modo | **Captura de Profundidad:** Captura y guarda en disco la imagen filtrada del mapa de profundidad. |
| <kbd>t</kbd> | Modo `RUNNING` | **Test en Tiempo Real:** Ejecuta pruebas de matching de contornos y puntos de referencia en vivo (`RealTimeTestMe`). |
| <kbd>w</kbd> | Modo `RUNNING` | **Test de Depuración:** Ejecuta rutinas de prueba y depuración para el juego de mapas (`DebugTestMe`). |

---

## Juegos Educativos Integrados

Magic Sand incluye diversos juegos interactivos diseñados para aprender jugando con la arena.

### 1. Modela una Isla (Shape an Island)

El juego nació sabiendo que Dinamarca cuenta con más de [400 islas](https://en.wikipedia.org/wiki/List_of_islands_of_Denmark), buscando una dinámica para enseñar geografía y formas insulares. También se agregaron islas internacionales (como Australia, Islandia o Groenlandia).

El objetivo es modelar con arena una isla que coincida con la forma de una isla objetivo asignada al azar. Solo se evalúa el contorno perimetral exterior (no la altura de las montañas):

- Presiona <kbd>Espacio</kbd> para iniciar el juego: aparecerá una pantalla de bienvenida.
- Modela una isla grande en el centro de la caja (tienes 30 segundos). **No** debe tocar los bordes del arenero.
- La aplicación verificará si detectó una isla válida. Si no es así, te pedirá intentarlo nuevamente.
- Se anunciará el nombre de una isla (ej. *Australia*) y se proyectará su silueta de referencia.
- Pasados 30 segundos, el software comparará el contorno de tu isla de arena con la máscara real y te mostrará una puntuación intermedia.
- Dispones de 1 minuto adicional para ajustar las costas y corregir la forma.
- Se mostrará un segundo resultado intermedio.
- Dispones de 30 segundos finales para dar el último toque.
- Se calcula la puntuación final y se compara contra la tabla de récords.

*Este juego fue presentado en eventos educativos en la isla danesa de Bornholm, tal como puede verse en este [video demostrativo](https://www.youtube.com/watch?v=dDMrxtH1hyU).*  
*(Desarrollado principalmente por Rasmus R. Paulsen).*

#### Cómo Agregar Nuevas Islas al Juego:
Es posible incorporar fácilmente nuevas islas y formas geográficas personalizadas:

1. **Ubicación de Datos:** Abre la carpeta `data/mapGame/ReferenceData/` (o `~/Magic-Sand/data/mapGame/ReferenceData/` en Linux).
2. **Prepara 3 Imágenes PNG** con el mismo identificador base (ej. `MiIsla`):
   - **`MiIsla_Splash.png`:** Pantalla de presentación y título que se proyecta al anunciar la isla al jugador.
   - **`MiIsla.png`:** Imagen de textura visual / satelital que se proyecta como guía sobre la arena.
   - **`MiIsla_GT.png`:** Máscara binaria **Ground Truth** (blanco puro `255` para la tierra emergida, negro puro `0` para el mar). El algoritmo de matching (`cv::findContours`) utiliza esta imagen para calcular la coincidencia geométrica.
3. **Registra la Isla en XML:** Abre el archivo `MapReferenceSettings.xml` y añade una nueva etiqueta `<map>` dentro de `<maps>`:
   ```xml
   <map id="9">
       <MapName>Nombre de Mi Isla</MapName>
       <GroundTruth>MiIsla</GroundTruth>
   </map>
   ```
El juego integrará automáticamente la nueva isla en la rotación aleatoria.

---

### 2. The Sandimals (Juego Competitivo para 2 Jugadores)

En este juego, la caja de arena se divide en dos mitades. Cada jugador solo tiene permitido mover la arena de su lado:
- **Objetivo:** Recolectar la mayor cantidad de **comida** y **pieles** posibles durante **5 minutos**.
- **Pieles:** Se consiguen teniendo conejos habitando en la tierra de tu lado. A más conejos, más pieles por segundo.
- **Comida:** Se consigue teniendo peces nadando en el agua de tu lado. A más peces y más grandes, más comida por segundo.

Antes de comenzar, alisa la arena y crea un gran lago en el centro de la caja que atraviese ambas mitades.

Inicia la partida con <kbd>f</kbd> o <kbd>r</kbd> (modo Estándar), o presiona <kbd>1</kbd>, <kbd>2</kbd>, <kbd>3</kbd> o <kbd>4</kbd> según la dificultad deseada.

#### Comportamiento de los Peces:
- Cuerpo gris claro.
- Cantidad fija (10, 20 o 30 según la dificultad).
- Su velocidad depende de su tamaño; se desplazan en cardúmenes.
- Huyen de los tiburones (su centro se vuelve **rojo** al escapar).
- Tienen tiempo de vida limitado (su centro se torna **gris** cuando van a morir).
- Reaparecen junto al pez madre actual (el pez madre tiene el centro **rosa** y es el más longevo del lago).
- Si un tiburón se come a un pez, reaparece como pez cría junto al pez madre.
- Si quedan varados en tierra seca, buscan pendientes hacia abajo para regresar al agua.

#### Comportamiento de los Tiburones:
- Cuerpo blanco; siempre hay exactamente 2 tiburones en la caja.
- Se mueven despacio y tienen el vientre **blanco** cuando están satisfechos.
- Su vientre se vuelve **negro** cuando tienen hambre.
- Su vientre se vuelve **rojo** cuando entran en cacería activa (se mueven muy rápido).
- Cazan a los peces más grandes cercanos; comer peces reduce su hambre.
- Si quedan atrapados sin agua o pasan demasiado tiempo sin comer, mueren y reaparecen donde haya mayor concentración de peces.
- Si quedan varados en tierra firme, descienden buscando agua.

#### Comportamiento de los Conejos:
- Cantidad fija (4, 6 o 10 según la dificultad).
- Se desplazan y se detienen sobre la tierra seca.

*Consejo Interactivo:* Los jugadores pueden juntar las manos en forma de cuenco para recoger y transportar peces y tiburones a través del arenero.  
*(Desarrollado principalmente por Rasmus R. Paulsen).*

---

### 3. Los Animales y sus Madres (The Animal and their Mothers)

En este juego cooperativo, aparecen en la arena un pez madre y un conejo madre. Los participantes deben ayudar a las crías a reunirse con sus madres cavando ríos a través de colinas o construyendo montañas y puentes de arena.

- Inicia presionando la tecla <kbd>m</kbd> en el teclado.  
*(Desarrollado principalmente por Thomas Wolf).*

---

## Desarrollo y Extensión de Magic Sand

### Código Fuente
El código fuente original está disponible en [GitHub](https://github.com/thomwolf/Magic-Sand).

### Dependencias
Magic Sand está basado en [openFrameworks](http://openframeworks.cc/) versión 0.9.3 y utiliza los siguientes addons:
- **Addons oficiales de openFrameworks:**
  - `ofxOpenCv`
  - `ofxKinect`
  - `ofxXmlSettings`
- **Addons comunitarios:**
  - [ofxCv](https://github.com/kylemcdonald/ofxCv)
  - [ofxParagraph](https://github.com/braitsch/ofxParagraph)
  - [ofxDatGui (versión forkeada)](https://github.com/thomwolf/ofxDatGui)
  - [ofxModal](https://github.com/braitsch/ofxModal)

### Arquitectura y Uso
La arquitectura se organiza principalmente alrededor de dos clases:
- `KinectProjector`: Gestiona la comunicación con el hardware, matrices de calibración y transformaciones entre sistemas de coordenadas 2D y 3D.
- `SandSurfaceRenderer`: Aplica shaders GLSL para transformar lecturas de elevación en gradientes de color con isolíneas proyectadas sobre la arena.

Un flujo típico de una aplicación en openFrameworks se estructura de la siguiente manera:

```cpp
std::shared_ptr<ofAppBaseWindow> projWindow;
std::shared_ptr<KinectProjector> kinectProjector;
SandSurfaceRenderer* sandSurfaceRenderer;

void ofApp::setup() {
    kinectProjector = std::make_shared<KinectProjector>(projWindow);
    kinectProjector->setup(true);

    sandSurfaceRenderer = new SandSurfaceRenderer(kinectProjector, projWindow);
    sandSurfaceRenderer->setup(true);
}

void ofApp::update() {
    kinectProjector->update();
    sandSurfaceRenderer->update();
}

void ofApp::drawProjWindow(ofEventArgs &args) {
    kinectProjector->drawProjectorWindow();
    
    if (!kinectProjector->isCalibrating()) {
        sandSurfaceRenderer->drawProjectorWindow();
        fboVehicles.draw(0, 0);
    }
}
```

### Referencia de Funciones de `KinectProjector`

#### 1. Funciones de Shaders
```cpp
void bind();
void unbind();
ofMatrix4x4 getTransposedKinectWorldMatrix();
ofMatrix4x4 getTransposedKinectProjMatrix();
```
*Nota:* El mapa `sampler2DRect` recibido en el shader está normalizado entre 0 y 1; la escala de conversión correspondiente se suministra como uniforme.

#### 2. Funciones de Conversión de Coordenadas y Elevación
Se manejan tres sistemas de coordenadas:
- **Coordenadas Kinect (2D):** `(x, y)` en píxeles, con origen en la esquina superior izquierda de la imagen del sensor.
- **Coordenadas del Mundo (3D):** `(x, y, z)` en milímetros con origen en el sensor Kinect (el eje Z representa la distancia frontal alejándose del sensor).
- **Coordenadas del Proyector (2D):** `(x, y)` en píxeles, con origen en la esquina superior izquierda de la ventana de proyección.

```cpp
ofVec2f worldCoordToProjCoord(ofVec3f vin);
ofVec3f projCoordAndWorldZToWorldCoord(float projX, float projY, float worldZ);
ofVec2f kinectCoordToProjCoord(float x, float y);
ofVec3f kinectCoordToWorldCoord(float x, float y);
ofVec2f worldCoordTokinectCoord(ofVec3f wc);
```

Cálculo de elevación respecto al plano base calibrado de la arena:
```cpp
float elevationAtKinectCoord(float x, float y);
float elevationToKinectDepth(float elevation, float x, float y);
ofVec2f gradientAtKinectCoord(float x, float y); // Pendiente/gradiente de la arena
```

#### 3. Funciones de Estado y Getters
```cpp
bool isCalibrating();
bool isCalibrated();
bool isImageStabilized();
bool isBasePlaneUpdated();
bool isROIUpdated();
bool isCalibrationUpdated();

ofRectangle getKinectROI();
ofVec2f getKinectRes();
ofVec3f getBasePlaneNormal();
float getBasePlaneOffset();
```

---

## Principales Diferencias con SARndbox

1. **Multiplataforma:** Magic Sand está concebido para funcionar tanto en Linux como en Windows y macOS, mientras que [SARndbox](https://github.com/KeckCAVES/SARndbox) está diseñado primordialmente para estaciones de trabajo bajo Linux.
2. **Requisitos Gráficos Ligeros:** SARndbox requiere tarjetas gráficas de alta gama para simulación hidrológica de fluidos (lluvia y escorrentía dinámica en tiempo real). Magic Sand está optimizado para funcionar en laptops y ordenadores domésticos estándar.
3. **Calibración Intuitiva:** Magic Sand emplea registro automático asistido por hardware y tableros de ajedrez proyectados, ofreciendo un proceso de calibración accesible sin necesidad de patrones físicos complejos de cuadrícula milimétrica.

---

## Licencia y Atribuciones

Este proyecto se distribuye bajo la licencia **GNU General Public License v2.0 (GPL-2.0)** - consulta el archivo [COPYING](COPYING) para conocer los términos legales completos.

### Linaje del Proyecto y Reconocimientos Académicos:
- **Concepto Original (SARndbox):** Creado por **Oliver Kreylos** y el equipo del centro KeckCAVES en la **Universidad de California, Davis** ([UC Davis AR Sandbox](https://arsandbox.ucdavis.edu)).
- **Calibración Cámara-Proyector:** Basada en [ofxKinectProjectorToolkit](https://github.com/genekogan/ofxKinectProjectorToolkit) por **Gene Kogan**.
- **Port a openFrameworks y Soporte Multiplataforma:** Desarrollado, diseñado y mantenido por **Thomas Wolf** ([thomwolf.io](https://thomwolf.io)).
- **Juegos Educativos y Algoritmos:** *Shape an Island*, *The Sandimals* y los motores de dificultad por niveles desarrollados por **Rasmus R. Paulsen** ([DTU Compute](http://people.compute.dtu.dk/rapa)).
- **Compatibilidad Linux Moderna y AppImage:** Reglas udev modernas, ampliación de búfer USB persistente, compatibilidad con Kinect for Windows v1 (Modelo 1473), persistencia de datos mutables y shims para entornos Wayland.

---

## Registro de Cambios (Changelog)

### Mejoras Modernas de Linux y Portabilidad
- Generación de AppImage x86_64 portable compatible con glibc 2.23 o superior.
- Script automatizado `setup_kinect_linux.sh` para configuración no invasiva de reglas udev y memoria de búfer USB (64 MB).
- Shim `libxwayland_fix.so` para evitar cierres inesperados de GLFW 3.1 en entornos Wayland.
- Soporte para carpetas de configuración mutables (`~/Magic-Sand/data/` y `./data/` local).
- Parche en `ofxKinect` para compatibilidad exclusiva con subdispositivo de cámara en Kinect for Windows v1 (Modelo 1473).
- Soporte para orientación física invertida (`Inverted` mode) en instalaciones con proyector posterior.

### [1.5.4.1](https://github.com/thomwolf/Magic-Sand/releases/tag/v1.5.4.1) - 10-10-2017
Lanzamiento de corrección de errores.
- **Agregado:** Binarios precompilados para Mac OS X.
- **Agregado:** Makefiles para Linux (experimentales).
- **Corrección de errores:** Corregido el procedimiento de calibración que no mostraba el tablero en la versión 1.5.4.

### [1.5.4](https://github.com/thomwolf/Magic-Sand/releases/tag/v1.5.4) - 23-09-2017
Lanzamiento menor de Magic-Sand-with-Games.
- **Agregado:** Contador de fotogramas por segundo (FPS) de la Kinect.
- **Agregado:** Archivos de proyecto para Xcode.
- **Agregado:** Filtro de fotograma completo.
- **Agregado:** Opción simple de InPainting para remover valores atípicos en el mapa de profundidad.
- **Agregado:** Mejoras en el escalado de la interfaz gráfica.
- **Agregado:** Función de depuración: Visualización de la ROI de la Kinect sobre el proyector.
- **Agregado:** Función de depuración: Impresión en consola de las coordenadas de profundidad al hacer clic izquierdo en el visor.
- **Agregado:** Registro de cambios (ChangeLog) al README.
- **Modificado:** Inversión de vectores de movimiento de los animales según la matriz de proyección para evitar que naden hacia atrás.
- **Modificado:** Actualización de la interfaz para el juego de animales; ahora actualiza el conteo de animales.
- **Modificado:** Ajuste de constantes en el juego de animales.
- **Modificado:** Modos de dificultad para principiante, novato, normal y experto (Teclas 1, 2, 3 y 4).
- **Corrección de errores:** El filtro espacial ahora filtra correctamente la ROI.

### [1.5.0](https://github.com/thomwolf/Magic-Sand/tree/v1.5) - 08-08-2017
Lanzamiento inicial de Magic Sand con juegos educativos integrados.
