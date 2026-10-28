# Emotions Samples Collect - SIMULL

_ecollect_ es una aplicación de escritorio para Windows desarrollada en la Universidad de La Laguna, por el grupo de investigación SIMULL, para recoger muestras de reacciones emocionales de personas que ven vídeos de promoción turística.

> **Estado:** proyecto archivado. El código se publica tal como se usó durante la recogida de datos y ya no se mantiene.

## Qué hace

Durante una sesión, la aplicación:

1. Muestra un tutorial que explica el uso de la cámara, el audio y los botones de reacción.
2. Pide al participante su sexo, su edad y su nacionalidad.
3. Reproduce una secuencia de vídeos e imágenes de campañas turísticas de Islas Canarias y de Tenerife, separados por una cuenta atrás de transición.
4. Graba al participante con la cámara y el micrófono mientras ve los vídeos.
5. Registra las reacciones que el participante marca en pantalla (alegría, sorpresa, miedo, asco, enfado, tristeza o neutral).
6. Sube los datos de la sesión a un bucket de AWS S3 y los borra del equipo local.

Cada sesión se identifica con un UUID aleatorio y genera:

| Archivo | Contenido |
|---|---|
| `recording.mp4` | Vídeo y audio del participante. |
| `dataset.csv` | Registro de eventos. Las líneas `P, <sexo>, <edad>, <nacionalidad>` guardan el perfil, y las líneas `R, <instante de la grabación>, <reacción>, <vídeo>, <repetición>, <posición en el vídeo>` guardan cada reacción. |

La interfaz está disponible en español e inglés.

## Datos de los participantes

Este repositorio **no contiene** ninguno de los datos recogidos con la aplicación.
Todos los participantes dieron su consentimiento informado antes de la sesión.
Las grabaciones son datos personales, por lo que su acceso queda sujeto a las condiciones de ese consentimiento y a la normativa de protección de datos.

## Estímulos audiovisuales

Los vídeos e imágenes de las campañas turísticas que se usaron como estímulo pertenecen a sus titulares (Turismo de Islas Canarias y Turismo de Tenerife), por lo que no se distribuyen con este repositorio.
En [`res/campains/README.md`](res/campains/README.md) está la lista de archivos que la aplicación necesita para compilar, y en [`THIRD_PARTY.md`](THIRD_PARTY.md) el resto de recursos de terceros.

## Trabajos relacionados

Esta aplicación es el software de recogida de datos del capítulo 2 de la siguiente tesis doctoral:

- Díaz González, S. (2023). _Modelo de inteligencia de datos para el estudio de destinos turísticos inteligentes_ [Tesis doctoral, Universidad de La Laguna]. Dirigida por R. M. Aguilar Chinea y J. M. Torres Jorge. TESEO: [O826478](https://aplicaciones.ciencia.gob.es/teseo/#/tesis/O826478/detalle). Dialnet: [337593](https://dialnet.unirioja.es/servlet/tesis?codigo=337593).

Los resultados del capítulo 2 no se han publicado fuera de la tesis.
El capítulo 1, que trata otra parte del trabajo, se publicó en este artículo:

- Díaz-González, S., Torres Jorge, J. M., Parra López, E. y Aguilar Chinea, R. M. (2022). Strategic technological determinant in smart destinations: obtaining an automatic classification of the quality of the destination. _Industrial Management & Data Systems_, 122(10), 2299-2330. [https://doi.org/10.1108/IMDS-10-2021-0640](https://doi.org/10.1108/IMDS-10-2021-0640)

## Cómo citar

Si utilizas este software, cítalo usando los metadatos de [`CITATION.cff`](CITATION.cff) o el DOI de Zenodo.

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23716832.svg)](https://doi.org/10.5281/zenodo.23716832)

## Licencia

El código se distribuye bajo la licencia MIT, cuyo texto está en [`LICENSE`](LICENSE).
Los componentes y recursos de terceros tienen sus propias licencias, recogidas en [`THIRD_PARTY.md`](THIRD_PARTY.md).

---

# Compilación

## Requisitos

- Qt 6.4 o posterior.
- Visual Studio 2019 o 2022.
- Los vídeos e imágenes de las campañas turísticas, colocados en `res/campains/` como indica [`res/campains/README.md`](res/campains/README.md).

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

Si es necesario compilar en otra ruta, se puede crear el archivo `CMakeUserPresets.json` —como señalamos anteriormente— y sobrescribir las variables `configurePresets.binaryDir` y `configurePresets.cacheVariables.VCPKG_INSTALL_OPTIONS` para que apunten a la nueva ubicación.
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
