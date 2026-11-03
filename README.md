# Magic Sand

[![License: GPL v2](https://img.shields.io/badge/License-GPL_v2-blue.svg)](COPYING)
[![openFrameworks 0.9.3](https://img.shields.io/badge/openFrameworks-0.9.3-brightgreen.svg)](https://openframeworks.cc/)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-orange.svg)](#operating-system-instructions)

> **Language / Idioma:** **English** | [Versión en Español (README.es.md)](README.es.md)

---

Magic Sand is an open-source software for operating an augmented reality (AR) sandbox like this one:

![First View of a Magic Sandbox](./art/general-view-2.jpg)

An augmented reality sandbox is made of a sand box, a depth detector (like a Kinect sensor) and a video projector (beamer) coupled together. The software provided on this repository controls the beamer and the Kinect in order to project colors and topographic elevation contours onto the sand in real time, related to the measured height of the sand.

This project was inspired and adapted from the [Augmented Reality Sandbox](https://arsandbox.ucdavis.edu) developed by [UC Davis](http://idav.ucdavis.edu/~okreylos/ResDev/SARndbox/). It is a partial port of the [SARndbox](https://github.com/KeckCAVES/SARndbox) project of Oliver Kreylos under [openframeworks](http://openframeworks.cc/) and is also adapted from the [ofxKinectProjectorToolkit](https://github.com/genekogan/ofxKinectProjectorToolkit) by Gene Kogan.

It was ported to openFrameworks with multi-platform support (Linux / macOS / Windows), a simple user interface and a robust yet simple calibration procedure by [Thomas Wolf](https://thomwolf.io) and later modified and extended with interactive sandbox games by [Rasmus R. Paulsen](http://people.compute.dtu.dk/rapa).

![Animation of a Magic Sandbox](./art/animated-box.gif)

Magic Sand was developed with the specific aim of simplifying the use of an augmented reality sandbox in a home, educational, and family environment:
- Run on a mid-range laptop / home computer (Windows / macOS / Linux, minimal GPU requirements).
- Easy calibration to quickly assemble, disassemble, and reassemble the sandbox.
- Simple, easy-to-use user interface.
- Extensible framework for future sandbox-based games and applications.

![View of a Magic Sandbox](./art/general-view.jpg)

---

## Main Features

Operates on a computer connected to a home cinema projector and a Kinect sensor. The software controls the projector to project colors as a function of the sand level measured by the Kinect sensor and transforms any sandbox into a colorful, responsive playground.

![View of the interface to use the Magic Sandbox](./art/explication.png)

---

## Getting Started & Hardware Setup

1. **Physical Setup:**
   The easiest way to get started is to build the physical setup provided in the guide found at the [tutorial page](https://imgur.com/gallery/Q86wR) and/or check the [Reddit DIY thread](https://www.reddit.com/r/DIY/comments/4v1gfi/a_magic_sandbox_i_made_for_my_3_yo_sons_birthday/).

2. **Hardware Requirements:**
   - **Kinect Sensor:** Xbox 360 Kinect (Model 1414) or Kinect for Windows v1 (Model 1473).
   - **Dedicated 12V Power Supply:** The Kinect requires external AC wall power; USB port power alone is not sufficient to power the depth laser and motors.
   - **Video Projector (Beamer):** Oriented downwards, projecting directly onto the sand box.
   - **Sand Box:** Filled with white or light-colored play sand.
   - **USB 2.0 Port:** Connect the Kinect to a native **USB 2.0 port (black)** or through an external USB 2.0 hub (avoid connecting directly to USB 3.0/3.1 ports on some host controllers to prevent depth stream drops).

---

## Operating System Instructions

### Windows (Windows 10, Windows 8, Windows 7)

#### Prerequisites & Driver Setup:
1. **Update Video Drivers:** Ensure your GPU graphics drivers are fully updated.
2. **Install Visual C++ Runtime Components:**
   - Download and install the [Visual C++ Redistributable 2015](https://www.microsoft.com/en-us/download/details.aspx?id=48145).
   - **Important:** Install the **x86** component, even if you are running a 64-bit version of Windows.
3. **Install Kinect USB Drivers with Zadig:**
   - Download the free USB driver tool [Zadig](http://zadig.akeo.ie/).
   - Plug in your Kinect and launch Zadig.
   - From the device dropdown menu, select **Xbox Camera**, **Xbox Motor**, and **Xbox Audio**.
   - For each of these sub-devices, select the **libusb-win32 (v1.2.6.0)** driver using the driver selection arrows and click **Install Driver** (or **Replace Driver**).
   - You need to perform this installation for each sub-device: once for camera, once for motor, and once for audio.
   - Additional details are available on the [libfreenect Windows guide](https://github.com/OpenKinect/libfreenect#windows) and the [ofxKinect Windows documentation](https://github.com/openframeworks/openFrameworks/tree/master/addons/ofxKinect#windows).
4. **Troubleshooting Detection Issues:**
   - If the Kinect is still not detected after running Zadig, install the [Microsoft Kinect for Windows SDK 1.0](https://www.microsoft.com/en-us/download/details.aspx?id=28782) (or SDK 1.8), reboot, and re-run Zadig to ensure `libusb-win32` is bound to all Kinect endpoints.
   - On Windows 10 and 11 machines with USB 3.0 ports, it can sometimes be necessary to unplug and re-plug the Kinect USB cable several times after starting the application until the depth feed initializes.

#### Compiling from Source:
- Open [Magic-Sand.sln](Magic-Sand.sln) using Visual Studio 2015 (toolset v140) linked with openFrameworks 0.9.3 for Windows.

---

### Mac OS X (Mac OS X 10.8+)

#### Quick Start:
1. Download the Magic Sand pre-built release for Mac and extract it anywhere on your system.
2. Connect your Kinect (with AC power) and projector.
3. Launch `Magic Sand.app`.

#### Compiling from Source:
- Open [Magic-Sand.xcodeproj](Magic-Sand.xcodeproj) with Xcode configured with openFrameworks 0.9.3.
- On modern macOS versions (Mojave and newer), grant camera permissions when prompted under **System Settings > Privacy & Security > Camera**.

---

### Linux

Historically, Magic Sand had no official pre-built Linux binaries and only provided experimental makefiles. In early builds, multiple display management under Linux presented issues, often requiring users to run solely on the projector without a secondary operator screen (displaying the GUI directly onto the sand).

The current repository provides modern packaging via a standalone **AppImage** that addresses dual-window rendering, user permissions, and persistent data storage.

#### 1. Running via Standalone AppImage:
```bash
chmod +x Magic-Sand-x86_64.AppImage
./Magic-Sand-x86_64.AppImage
```

#### 2. Kinect Driver & Kernel USB Buffer Configuration:
Kinect v1 requires system udev rules and an expanded USB memory buffer (64 MB) in the kernel to prevent frame drops in dual depth/RGB streaming:
```bash
# Automated setup through AppImage argument:
./Magic-Sand-x86_64.AppImage --setup-kinect

# Or execute the included script directly with sudo:
sudo ./setup_kinect_linux.sh
```
*To remove these system rules at any time, run: `sudo ./setup_kinect_linux.sh --uninstall`.*

#### 3. Mutable User Data Persistence:
Because AppImage mounts a read-only filesystem (SquashFS), configuration files are automatically managed in a writable location:
- **Default:** `~/Magic-Sand/data/`
- **Portable Mode:** If a folder named `data` or `Magic-Sand-Data` is located next to the AppImage file, that directory is used instead.

All calibration files (`calibration.xml`), projector settings, custom colormaps, and high scores are preserved across sessions.

#### 4. Linux Graphics Compatibility Notice (NVIDIA / Intel / AMD):
- **Supported & Recommended:** **Intel Integrated Graphics** and **AMD Radeon** cards using open-source **Mesa / Gallium** drivers.
- **NVIDIA Status (Experimental / Not Guaranteed):**
  > [!WARNING]
  > At this time, **stable operation on Linux systems using NVIDIA graphics cards is NOT guaranteed** (neither with proprietary drivers nor on dual-GPU laptops using NVIDIA Optimus / PRIME offload).
  >
  > **Known technical constraints:**
  > 1. openFrameworks 0.9.3 and GLFW 3.1 may fail to initialize or retain OpenGL/GLX contexts with proprietary NVIDIA driver versions.
  > 2. On modern Linux desktop sessions running **Wayland**, NVIDIA drivers frequently trigger protocol errors under XWayland (though an integrated `libxwayland_fix.so` shim is included to mitigate common crashes).
  > 3. Although experimental PRIME render offload parameters (`__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia`) are included in the launcher, if you experience black windows, segmentation faults, or severe frame drops, we recommend switching your desktop session to **X11 (Xorg)** or forcing execution on an Intel/AMD GPU.

---

## Calibration & System Setup

Connect and turn on the projector and the Kinect, then start the software.

By default, the software starts in a **setup** mode:
- The depth or color stream from the Kinect is shown on the operator's user interface window.
- The projector projects a completely white image. This makes it easy to position the projector over the sandbox, verify that the beam covers the sand, and check Kinect connectivity.
- The status of the Kinect and projector can be checked in the status window at the lower-left of the user interface.
- In setup mode, the physical positions and tilt of the Kinect and projector can be optimized.

### Calibration Steps
To calibrate the geometric correspondence between the Kinect 3D depth sensor and the 2D projector window:

1. **Flatten the sand** in the sandbox as evenly as possible.
2. Verify that you see either the depth image or the color image from the Kinect in the main UI (click **advanced | Display Kinect Depth View**).
3. Press **Calibration | Manually Draw Sand Region**.
4. Define the sand region by clicking and dragging a rectangle with the mouse over the Kinect Depth or Color view in the operator window.
5. Press **Automatically Calibrate Kinect & Projector**: a series of Chessboard patterns will now be projected sequentially onto the sand.
6. When prompted on screen, **cover the sandbox with a light piece of cardboard or similar flat board** at an elevated level.
7. Click **OK**: another series of Chessboard patterns will be projected onto the board surface to establish the 3D elevation plane.

If the calibration is successful, the status window will update indicating that all is ready.

![Animation of the calibration steps to use the Magic Sandbox](./art/calibration.gif)

### Tips for a Nice Calibration:
- **Turn off or dim the room lighting:** Depending on ambient lighting and reflections, strong room light can wash out projected chessboard corners. Dimming room lights can ensure quick and accurate point detection.
- **Use a perfectly flat, matte cover:** For the second calibration stage, ensure the board or cardboard is completely flat. If it bends or flexes, height calibration will be skewed. Furthermore, use a **matte** surface (non-glossy), as glossy materials cause specular reflection that blinds the Kinect infrared depth sensor.

#### Debug Mode for Calibration:
If calibration does not succeed, enable **advanced | Dump Debug** and run the calibration procedure again. Debug image files and logs will be written to the `data/DebugFiles/` folder to help diagnose point detection issues.

---

## Physical Setup: Inverted Mounting (Inverted Mode)

In many permanent installations, museums, or exhibitions, physical constraints require mounting the Kinect and projector on the side opposite to where the audience or players stand.

When mounted in this orientation, without adjustment, projected text, HUD countdowns, and animal models would appear upside-down, and simulated creatures would appear to move backwards.

### Enabling Inverted Mode:
- **Via User Interface:** In the operator window on the left, expand the **`advanced`** folder and check the **`Inverted`** toggle.
- **Via Configuration File:** In `settings/kinectProjectorSettings.xml`, set:
  ```xml
  <Inverted>1</Inverted>
  ```

### What Inverted Mode Does Internally:
1. Applies an automated 180° projection transformation (`ofRotate(180.0f)` with corresponding translation) to the projector output.
2. Automatically recalculates movement angles and heading coordinates for all autonomous animal agents (`getOrientedAngle` and `getOrientedX`), ensuring fish, sharks, and rabbits swim and face forward naturally.
3. Keeps the HUD and game scores upright for the players around the sandbox, while the operator's control panel remains comfortably legible on the computer monitor.

---

## Keyboard Shortcuts & Controls

All interactive game modes, debugging routines, and snapshot tools can be triggered via keyboard shortcuts:

| Key | Mode / Context | Function / Description |
| :---: | :--- | :--- |
| <kbd>Space</kbd> | `SETUP` Mode | **Start Application:** Exits setup mode and starts active topographic contour projection on the sand. |
| <kbd>Space</kbd> | `RUNNING` Mode | **Shape an Island:** Starts the island game (if idle), or advances stages / submits current shape during play. |
| <kbd>f</kbd> or <kbd>r</kbd> | `RUNNING` Mode | **The Sandimals / Stop Game:** Starts the 2-player Sandimals game (Standard mode), or terminates the active island game. |
| <kbd>1</kbd> | `RUNNING` Mode | Starts *The Sandimals* in **Absolute Beginner** mode (Level 0). |
| <kbd>2</kbd> | `RUNNING` Mode | Starts *The Sandimals* in **Novice** mode (Level 1). |
| <kbd>3</kbd> | `RUNNING` Mode | Starts *The Sandimals* in **Standard** mode (Level 2). |
| <kbd>4</kbd> | `RUNNING` Mode | Starts *The Sandimals* in **Expert** mode (Level 3). |
| <kbd>m</kbd> | `RUNNING` Mode | Starts the **Animals and their Mothers** cooperative pathfinding game. |
| <kbd>c</kbd> | Any State | **Color Snapshot:** Captures and saves the current Kinect RGB camera frame to disk. |
| <kbd>d</kbd> | Any State | **Depth Snapshot:** Captures and saves the current filtered Kinect depth frame to disk. |
| <kbd>t</kbd> | `RUNNING` Mode | **Real-Time Test:** Launches real-time contour and landmark matching evaluation (`RealTimeTestMe`). |
| <kbd>w</kbd> | `RUNNING` Mode | **Debug Test:** Runs offline contour and landmark matching test routines (`DebugTestMe`). |

---

## Sandbox Games

Magic Sand includes several integrated interactive educational games.

### 1. Shape an Island

The background for this game is that Denmark has more than [400 islands](https://en.wikipedia.org/wiki/List_of_islands_of_Denmark), and this game was created to teach players about geography and island shapes. Non-Danish islands (such as Australia, Iceland, and Greenland) are also included.

The goal is to shape a sand island that matches a randomly assigned target island. Only the outer perimeter contour of the island is evaluated (not the elevation profile):

- Press <kbd>Space</kbd> to start the game: a welcome screen appears.
- Shape a large island in the middle of the sandbox (you have 30 seconds). It must **not** touch the edges of the box.
- The software checks if an island was detected. If not, you are prompted to try again.
- An island name is announced (e.g., *Australia*), displaying a reference preview.
- After 30 seconds, the software matches your sand island contour against the target ground truth and displays an intermediate similarity score.
- You have 1 minute to reshape and refine your island's coastline.
- Another intermediate score is shown.
- You have a final 30 seconds to finalize your island.
- A final score is computed and compared against the high score table.

*This game was featured at an educational event on the Danish Island of Bornholm, as seen in this [demonstration video](https://www.youtube.com/watch?v=dDMrxtH1hyU).*  
*(Developed primarily by Rasmus R. Paulsen).*

#### How to Add Custom Islands to the Game:
You can easily add new islands or custom geographic shapes:

1. **Locate the Data Directory:** Navigate to `data/mapGame/ReferenceData/` (or `~/Magic-Sand/data/mapGame/ReferenceData/` on Linux).
2. **Prepare 3 PNG Images** using a common base identifier (e.g., `MyIsland`):
   - **`MyIsland_Splash.png`:** The title splash screen projected when the island is introduced to the player.
   - **`MyIsland.png`:** A visual / satellite texture map displayed during guidance.
   - **`MyIsland_GT.png`:** The **Ground Truth** binary mask image (pure white `255` for the land mass, pure black `0` for the sea). This image is used by the contour matching algorithm (`cv::findContours`).
3. **Register the Island in XML:** Open `MapReferenceSettings.xml` and append a new `<map>` block inside `<maps>`:
   ```xml
   <map id="9">
       <MapName>My Island Name</MapName>
       <GroundTruth>MyIsland</GroundTruth>
   </map>
   ```
The game will automatically load and include the new island in its random rotation.

---

### 2. The Sandimals (2-Player Competitive Game)

In this game, the sandbox is divided into two halves. Each player is only allowed to move sand on their own half:
- **Objective:** Collect as much **food** and as many **skins** as possible within **5 minutes**.
- **Skins:** Earned by having rabbits living on your side of the land. More rabbits yield more skins per second.
- **Food:** Earned by having fish swimming in water on your side. Larger fish yield more food per second.

Before starting, flatten the sand and dig a large lake in the middle of the box spanning both halves.

Start the game with <kbd>f</kbd> or <kbd>r</kbd> (Standard difficulty), or press <kbd>1</kbd>, <kbd>2</kbd>, <kbd>3</kbd>, or <kbd>4</kbd> for specific levels.

#### Fish Behavior:
- Light gray body.
- Fixed count (10, 20, or 30 depending on difficulty).
- Swim speed depends on their size; they travel in flocks.
- Flee from predators (their center turns **red** when fleeing).
- Finite lifespan (their center turns **gray** when near death).
- Respawn near the current mother fish (the mother fish has a **pink** center and is the oldest fish in the lake).
- If eaten by a shark, a baby fish respawns at the mother fish.
- If stranded on dry land, they wiggle downhill searching for water.

#### Shark Behavior:
- White body; exactly 2 sharks exist in the sandbox.
- Move slowly with a **white** belly when well-fed.
- Belly turns **black** when hungry.
- Belly turns **red** when actively hunting (swimming rapidly).
- Hunt the largest fish in their vicinity; eating fish satisfies their hunger.
- If trapped away from water or starving for too long, they die and respawn where fish density is highest.
- If stranded on land, they seek downwards towards water.

#### Rabbit Behavior:
- Fixed count (4, 6, or 10 depending on level).
- Hop and stop across dry land.

*Interactive Tip:* Players can gently cup their hands like a bowl to pick up and move fish and sharks across the sandbox.  
*(Developed primarily by Rasmus R. Paulsen).*

---

### 3. The Animal and their Mothers Game

In this cooperative game, a mother fish and a mother rabbit appear on the terrain. Players must help young animals reach their respective mothers by digging rivers through ridges or piling up sand bridges and mountains.

- Start by pressing <kbd>m</kbd> on the keyboard.  
*(Developed primarily by Thomas Wolf).*

---

## Coding and Extending Magic Sand

### Source Code & Repositories
The full source code is hosted on [GitHub](https://github.com/thomwolf/Magic-Sand).

### Dependencies
Magic Sand is built on [openFrameworks](http://openframeworks.cc/) version 0.9.3 and utilizes the following addons:
- **Official openFrameworks Addons:**
  - `ofxOpenCv`
  - `ofxKinect`
  - `ofxXmlSettings`
- **Community Addons:**
  - [ofxCv](https://github.com/kylemcdonald/ofxCv)
  - [ofxParagraph](https://github.com/braitsch/ofxParagraph)
  - [ofxDatGui (forked version)](https://github.com/thomwolf/ofxDatGui)
  - [ofxModal](https://github.com/braitsch/ofxModal)

### Architecture & Usage
The core architecture is structured around two main modules:
- `KinectProjector`: Manages hardware communication with the sensor, calibration matrices, and 2D/3D coordinate transformations.
- `SandSurfaceRenderer`: Renders real-time elevation color gradients and contour lines onto the sandbox surface using GLSL shaders.

In an openFrameworks application, setup and render loops are connected as follows:

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

### `KinectProjector` Functions Reference

#### 1. Shader Functions
```cpp
void bind();
void unbind();
ofMatrix4x4 getTransposedKinectWorldMatrix();
ofMatrix4x4 getTransposedKinectProjMatrix();
```
*Note:* The `sampler2DRect` depth map passed to shaders is normalized between 0 and 1; a scaling factor is supplied as a uniform.

#### 2. Coordinate Conversion & Elevation Functions
Three coordinate systems are maintained:
- **Kinect Coordinates (2D):** `(x, y)` in pixels, origin at top-left of the depth stream.
- **World Coordinates (3D):** `(x, y, z)` in millimeters originating from the Kinect sensor (Z represents distance away from the sensor).
- **Projector Coordinates (2D):** `(x, y)` in pixels, origin at top-left of the projected display.

```cpp
ofVec2f worldCoordToProjCoord(ofVec3f vin);
ofVec3f projCoordAndWorldZToWorldCoord(float projX, float projY, float worldZ);
ofVec2f kinectCoordToProjCoord(float x, float y);
ofVec3f kinectCoordToWorldCoord(float x, float y);
ofVec2f worldCoordTokinectCoord(ofVec3f wc);
```

Elevation relative to the calibrated base sand plane:
```cpp
float elevationAtKinectCoord(float x, float y);
float elevationToKinectDepth(float elevation, float x, float y);
ofVec2f gradientAtKinectCoord(float x, float y); // Slope of the sand surface
```

#### 3. State & Getter Functions
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

## Main Differences with SARndbox

1. **Cross-Platform Portability:** Magic Sand is designed to run on Linux, Windows, and macOS, whereas [SARndbox](https://github.com/KeckCAVES/SARndbox) was primarily built for Linux workstation environments.
2. **Lightweight Hardware Requirements:** SARndbox relies on powerful dedicated GPUs for complex hydrological fluid simulation (dynamic water flow/rain). Magic Sand is optimized to run on standard home and laptop computers.
3. **Registration & Calibration:** Magic Sand utilizes Kinect hardware-assisted registration and chessboard homography, providing a simple calibration procedure accessible to families and educators without requiring complex specialized calibration grids.

---

## License & Attributions

This project is licensed under the **GNU General Public License v2.0 (GPL-2.0)** - see the [COPYING](COPYING) file for full details.

### Academic & Project Lineage:
- **Original Concept (SARndbox):** Developed by **Oliver Kreylos** and the KeckCAVES team at the **University of California, Davis** ([UC Davis AR Sandbox](https://arsandbox.ucdavis.edu)).
- **Projector-Camera Calibration:** Based on [ofxKinectProjectorToolkit](https://github.com/genekogan/ofxKinectProjectorToolkit) by **Gene Kogan**.
- **openFrameworks Port & Multi-Platform UI:** Designed, ported, and maintained by **Thomas Wolf** ([thomwolf.io](https://thomwolf.io)).
- **Educational Games & Match Algorithms:** *Shape an Island*, *The Sandimals*, and difficulty level engines developed by **Rasmus R. Paulsen** ([DTU Compute](http://people.compute.dtu.dk/rapa)).
- **Modern Linux & AppImage Compatibility:** Modern kernel udev rules, expanded USB buffer scripts, Kinect v1 K4W (Model 1473) camera-only patch, mutable data persistence, and Wayland compatibility shims.

---

## Changelog

### Modern Linux & Portability Enhancements
- Added standalone x86_64 AppImage build pipeline with glibc 2.23+ backwards compatibility.
- Added automated `setup_kinect_linux.sh` configuring non-invasive udev rules and persistent 64 MB USB kernel buffer memory.
- Added `libxwayland_fix.so` shim to prevent GLFW 3.1 crashes on Wayland desktop environments.
- Added support for mutable user configuration directories (`~/Magic-Sand/data/` and local `./data/`).
- Added hardware detection for Kinect for Windows v1 (Model 1473) opening `FREENECT_DEVICE_CAMERA` subdevice.
- Added inverted projection orientation support (`Inverted` mode) for rear-mounted physical sandbox installations.

### [1.5.4.1](https://github.com/thomwolf/Magic-Sand/releases/tag/v1.5.4.1) - 10-10-2017
Bug fix release.
- **Added:** Mac OS X pre-built binaries.
- **Added:** Linux makefiles (experimental).
- **Bug Fix:** Fixed calibration routine where the checkerboard pattern did not display.

### [1.5.4](https://github.com/thomwolf/Magic-Sand/releases/tag/v1.5.4) - 23-09-2017
Minor release of Magic-Sand-with-Games.
- **Added:** Kinect FPS frame counter for received frames.
- **Added:** Xcode build files.
- **Added:** Full-frame filter option.
- **Added:** Simple InPainting option for removing outliers in the depth map.
- **Added:** Better scaling of GUI.
- **Added:** Debug feature: Kinect ROI can be seen on projector.
- **Added:** Debug feature: Left mouse click in Kinect depth view prints depth coordinates on console.
- **Added:** ChangeLog to the README.
- **Changed:** Animals in animal game are flipped depending on Kinect-projector matrix to prevent backwards swimming.
- **Changed:** GUI update for animal game; now updates animal numbers.
- **Changed:** Adjusted game constants for animal game.
- **Changed:** Added beginner, novice, normal, and expert game difficulty levels (Keys 1, 2, 3, 4).
- **Bug Fix:** Spatial filter now correctly filters the ROI.

### [1.5.0](https://github.com/thomwolf/Magic-Sand/tree/v1.5) - 08-08-2017
Initial release of Magic Sand with integrated educational games.
