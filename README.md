# Silicon Motion (SM768) USB Display Fix for Pop!_OS (COSMIC/Wayland)

Este repositorio documenta la solución definitiva para hacer funcionar los adaptadores de video USB basados en **Silicon Motion (ej. Wavlink Dock)** en **Pop!_OS** bajo el entorno gráfico **COSMIC (Wayland)**.

## El Problema Original
Al conectar el dock, la pantalla se queda en el logo azul de "Universal Graphic Docking" y el proceso `SMIUSBDisplayManager` entra en un bucle de reinicios (`segfault at 10 ip ... in pnpThreadfunc`).

### Causas:
1. **Incompatibilidad de Librerías (EVDI):** La librería `libevdi` del sistema no tiene la función `evdi_open_attached_to_fixed` exigida por el binario.
2. **Formato de Video Intel (CCS):** La gráfica integrada Intel usa un formato comprimido (`I915_y_tiled_ccs`) que EVDI no puede renderizar.
3. **Permisos USB:** El ejecutable, al correr como usuario normal, no tiene permisos para leer el bus USB.
4. **Sockets de Wayland:** Los servicios de arranque por defecto fallan porque el socket `wayland-X` no existe hasta iniciar sesión.

## La Solución Aplicada

El script `install.sh` incluido en este repositorio automatiza la solución, la cual consta de:
- `INTEL_DEBUG=noccs` en `/etc/environment`.
- Reglas UDEV (`99-smi-usb.rules`) para permisos USB.
- Compilación de `libevdi 1.14.11` emparejada con `evdi-dkms`.
- Script de arranque inteligente (`start-smi.sh`) que limpia tarjetas fantasmas y detecta Wayland automáticamente.
- Regla Sudoers para ejecución sin contraseña en el Autostart del usuario.

## Instalación en un equipo nuevo
Clona este repositorio y ejecuta:
```bash
chmod +x install.sh
sudo ./install.sh
```
