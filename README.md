# Silicon Motion (SM768) USB Display Fix for Pop!_OS (COSMIC/Wayland)

🌍 **[English](#english)** | 🌎 **[Español](#español)**

---

## English

This repository documents the definitive solution to get **Silicon Motion** based USB video adapters (e.g., **Wavlink Docks**) working on **Pop!_OS** under the **COSMIC (Wayland)** graphical environment.

### The Original Problem
When connecting the dock, the screen gets stuck on the blue "Universal Graphic Docking" logo, and the `SMIUSBDisplayManager` process enters a restart loop (`segfault at 10 ip ... in pnpThreadfunc`).

#### Root Causes:
1. **Library Incompatibility (EVDI):** The system's `libevdi` lacks the `evdi_open_attached_to_fixed` function required by the binary.
2. **Intel Video Format (CCS):** The Intel integrated graphics uses a compressed format (`I915_y_tiled_ccs`) that EVDI cannot render in Wayland.
3. **USB Permissions:** The executable lacks permissions to read the USB bus when running as a normal user.
4. **Wayland Sockets:** Default boot services fail because the `wayland-X` socket does not exist until the user logs in.

### The Applied Solution
The included `install.sh` script automates the solution, which consists of:
- Setting `INTEL_DEBUG=noccs` in `/etc/environment` to disable unsupported Intel compression.
- UDEV Rules (`99-smi-usb.rules`) to grant USB read/write permissions.
- Compiling `libevdi 1.14.11` to match the `evdi-dkms` kernel module.
- A smart startup script (`start-smi.sh`) that clears ghost EVDI cards and dynamically detects the active Wayland socket.
- A Sudoers rule to allow passwordless execution in the user's Autostart.

### Fresh Installation
Clone this repository and run:
```bash
chmod +x install.sh
sudo ./install.sh
```

---

## Español

Este repositorio documenta la solución definitiva para hacer funcionar los adaptadores de video USB basados en **Silicon Motion (ej. Wavlink Dock)** en **Pop!_OS** bajo el entorno gráfico **COSMIC (Wayland)**.

### El Problema Original
Al conectar el dock, la pantalla se queda en el logo azul de "Universal Graphic Docking" y el proceso `SMIUSBDisplayManager` entra en un bucle de reinicios (`segfault at 10 ip ... in pnpThreadfunc`).

#### Causas:
1. **Incompatibilidad de Librerías (EVDI):** La librería `libevdi` del sistema no tiene la función `evdi_open_attached_to_fixed` exigida por el binario.
2. **Formato de Video Intel (CCS):** La gráfica integrada Intel usa un formato comprimido (`I915_y_tiled_ccs`) que EVDI no puede renderizar.
3. **Permisos USB:** El ejecutable, al correr como usuario normal, no tiene permisos para leer el bus USB.
4. **Sockets de Wayland:** Los servicios de arranque por defecto fallan porque el socket `wayland-X` no existe hasta iniciar sesión.

### La Solución Aplicada
El script `install.sh` incluido en este repositorio automatiza la solución, la cual consta de:
- `INTEL_DEBUG=noccs` en `/etc/environment`.
- Reglas UDEV (`99-smi-usb.rules`) para permisos USB.
- Compilación de `libevdi 1.14.11` emparejada con `evdi-dkms`.
- Script de arranque inteligente (`start-smi.sh`) que limpia tarjetas fantasmas y detecta Wayland automáticamente.
- Regla Sudoers para ejecución sin contraseña en el Autostart del usuario.

### Instalación en un equipo nuevo
Clona este repositorio y ejecuta:
```bash
chmod +x install.sh
sudo ./install.sh
```
