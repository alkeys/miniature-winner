[![imagen.png](https://i.postimg.cc/x868W9KV/imagen.png)](https://postimg.cc/xNb9mDx6)

[![imagen.png](https://i.postimg.cc/cLgCbyCP/imagen.png)](https://postimg.cc/pmvPmSDB)

[![imagen.png](https://i.postimg.cc/d1qqvzQs/imagen.png)](https://postimg.cc/xk4r3pbh)


[![imagen.png](https://i.postimg.cc/hjpKGph9/imagen.png)](https://postimg.cc/njjyRK4z)

[![imagen.png](https://i.postimg.cc/br58xrxr/imagen.png)](https://postimg.cc/gL3fdYBb)

# Gojo Project

Gojo es una aplicación desarrollada con Flutter. Este proyecto incluye soporte para Linux, lo que permite su ejecución en sistemas basados en Linux como Arch Linux y Debian.

## Requisitos Previos

### Instalación de Flutter

1. Descarga e instala Flutter siguiendo las [instrucciones oficiales](https://docs.flutter.dev/get-started/install).
2. Asegúrate de que Flutter esté configurado correctamente:
   ```bash
   flutter doctor
   ```

### Dependencias del Sistema

#### En Arch Linux:
Instala las herramientas necesarias con:
```bash
sudo pacman -S base-devel clang cmake ninja
```

#### En Debian y Derivados (como Ubuntu):
Instala las herramientas necesarias con:
```bash
sudo apt update
sudo apt install clang cmake ninja-build libgtk-3-dev
```

## Configuración del Proyecto

1. Clona este repositorio:
   ```bash
   git clone https://github.com/usuario/gojo.git
   cd gojo
   ```

2. Asegúrate de que el proyecto incluye soporte para Linux:
   ```bash
    flutter config --enable-linux-desktop
   flutter create .
   ```

3. Verifica que Linux esté habilitado como dispositivo disponible:
   ```bash
   flutter devices
   ```

   Deberías ver "Linux" listado como una de las opciones.

4. Instala las dependencias del proyecto:
   ```bash
   flutter pub get
   ```

## Ejecución en Linux

1. Ejecuta el siguiente comando para iniciar la aplicación en modo de depuración:
   ```bash
   flutter run -d linux
   ```

2. Si deseas compilar un ejecutable para producción:
   ```bash
   flutter build linux
   ```
   
3. si deseas ejecutar en web 
```bash
flutter run -d web
  ```

   Esto generará un ejecutable en `build/linux/release/bundle`.



## Resolución de Problemas

- **Error: No Linux desktop project configured**:
  Si ves este error, asegúrate de haber ejecutado `flutter create .` en la raíz del proyecto.
- **Problemas con dependencias**:
  Verifica que todas las dependencias necesarias estén instaladas ejecutando:
  ```bash
  flutter doctor
  ```

## Licencia por Defecto nada xd xd xd
