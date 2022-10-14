# Emotions Samples Collect - SIMULL

## Requisitos

- Qt 6.2 o posterior.
- Visual Studio 2019 o 2022.

Algunas consideraciones a la hora de elegir las versiones de estas dependencias:

- Con versiones anteriores a Visual Studio 16.11.20 (2019) pueden surgir problemas con el soporte de características de C++20.
- Para trabajar con Qt Creator es necesario utilizar Visual Studio 2019 porque actualmente no se ofrece Qt compilado para Visual Studio 2022.
- Para compilar la versión con enlazado estático utilizando CMake, la versión de CMake que trae Visual Studio 2019 es demasiado antigua.
Las alternativas son: instalar CMake 3.21.1 o posterior, usar el CMake que instala Qt o el CMake que acompaña a Visual Studio 2022.

## VCPKG

El proyecto utiliza vcpkg como submódulo en `tools/vcpkg` para gestionar las dependencias.
La inicialización de vcpkg debe hacerse manualmente, antes de abrir el proyecto con Qt Creator, ejecutando desde la línea de comandos:

~~~.posh
> .\tools\vcpkg\bootstrap-vcpkg.bat
~~~

El proyecto abierto con Qt Creator se compila con enlazado dinámico, utilizando la versión de Qt instalada junto al IDE.
Las dependencias de esta versión se indican en el archivo de _manifest_ `vcpkg.json`.

Para compilar la versión con enlazado estático, es necesario recurrir directamente a CMake.
En ese caso, las dependencias del proyecto están indicadas en el archivo de  _manifest_ `tools/vcpkg-manifest/vcpkg.json`

## Compilación con enlazado estático

Para facilitar la distribución de la _release_ del programa, es conveniente enlazarlo estáticamente con todas las librerías que necesita.
Lamentablemente, Qt no ofrece librerías de enlazado estático, por lo que es necesario utilizar vcpkg para compilarlas localmente.

### Línea de comandos

Lo mejor es lanzar la compilación desde la interfaz de línea de comandos _x64 Native Tools Command Prompt for VS 2019_, ya que tiene la configuración de entorno adecuada para compilar para Windows 64 bits.

~~~.cmd
**********************************************************************
** Visual Studio 2019 Developer Command Prompt v16.11.20
** Copyright (c) 2021 Microsoft Corporation
**********************************************************************
[vcvarsall.bat] Environment initialized for: 'x86_x64'

C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools>
~~~

### Configuración de AWS S3

Por motivos de seguridad, la configuración de AWS no se almacena junto al proyecto.
Por eso, antes de compilar el proyecto es necesario configurar las variables: `AWS_S3_BUCKET_NAME`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` y `AWS_CRYPTO_KEY`.

Los valores adecuados para esas variables se pueden indicar mediante la opción `-D`, en la línea de comandos de CMake, durante la configuración del proyecto.
Otra opción, es copiar `CMakeUserPresets.json.template` como `CMakeUserPresets.json` y modificar los directamente valores de dichas variables en el nuevo archivo.

### Directorio de build

Debido a la limitación de 260 caracteres de Windows, la compilación de Qt puede fallar si las rutas de los archivos son demasiado largas.
Por eso, el proyecto se compila en `C:\b\` por defecto.

Si es necesario compilar en otra ruta, se puede crear el archivo `CMakeUserPresets.json` —como señalamos anteriormente— y sobrescribir las variables `configurePresets.binaryDir` y `VCPKG_INSTALL_OPTIONS` para que apunten a la nueva ubicación.
En todo caso, es importante evitar rutas más largas que la configurada por defecto porque eso puede causar los problemas señalados.

### Compilar

Para compilar el proyecto con enlazado estático, primero se configura:

~~~.cmd
> cmake --preset=release
~~~

Los _presets_ válidos son `debug` y `release`.
Si se ha usado el archivo `CMakeUserPresets.json` para cambiar la configuración del proyecto, los  _presets_ que se deben utilizar son `dev-debug` o `dev-release`, para que dichos cambios tengan efecto.

Durante esta fase, vcpkg bajará las librerías Qt y sus dependencias y las compilará para enlazado estático.

> Ojo, el proceso necesita alrededor de unos 20 GB de espacio en disco y puede tardar bastante en completarse.

Después se compila el proyecto con CMake:

~~~.cmd
> cmake --build --preset=release
~~~

Nuevamente, los _presets_ válidos son `debug` y `release`, pero se deben utilizar `dev-debug` o `dev-release` si se hace uso del archivo `CMakeUserPresets.json`.

Si termina con éxito, el ejecutable estará en la carpeta `C:\b\`.
