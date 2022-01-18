# Emotions Samples Collect - SIMULL

## VCPKG

El proyecto utiliza vcpkg como submódulo en `tools/vcpkg` para gestionar las dependencias.
La inicialización de vcpkg debe hacerse manualmente, antes de abrir el proyecto con Qt Creator, ejecutando desde la línea de comandos:

~~~.posh
> .\tools\vcpkg\bootstrap-vcpkg.bat
~~~

## Compilación con enlazado estático

Para facilitar la distribución de la _release_ del programa, es conveniente enlazarlo estáticamente con todas las librerías que necesita.
Lamentablemente, Qt no ofrece librerías de enlazado estático, por lo que es necesario utilizar vcpkg para compilarlas localmente.

### Línea de comandos

Lo más sencillo es lanzar la compilación desde la interfaz de línea de comandos _x64 Native Tools Command Prompt for VS 2019_, ya que tiene la configuración de entorno adecuada.
Al ejecutar el comando del compilador `cl` debe indicar que se trata de la versión para x64:

~~~.cmd
**********************************************************************
** Visual Studio 2019 Developer Command Prompt v16.11.9
** Copyright (c) 2021 Microsoft Corporation
**********************************************************************

C:\Windows\System32>cl
Microsoft (R) C/C++ Optimizing Compiler Version 19.29.30139 for x64
Copyright (C) Microsoft Corporation.  All rights reserved.

usage: cl [ option... ] filename... [ /link linkoption... ]
~~~

### Rutas largas

La compilación de Qt puede fallar si las rutas de los archivos son demasiado largas.
Por eso se recomienda hacer accesible la carpeta `tools/vcpkg` a través de una unidad propia, como por ejemplo la unidad `V:`.

~~~.cmd
> subst V: .\tools\vcpkg
~~~

El archivo `CMakePreset.json` está configurado con rutas en la unidad `V:`, asumiendo que se ha ejecutado el comando anterior.
Si se escoge otra letra de unidad, será necesario modificar `CMakePreset.json` convenientemente.

### Configuración de AWS S3

Por motivos de seguridad, la configuración de AWS no se almacena junto al proyecto.
Por eso, antes de copilar el proyecto es necesario configurar las variables `AWS_*` en `CMakePresets.json`.

Tal y como se ve en dicho archivo, los valores adecuados para esas variables se pueden indicar mediante variables de entorno con el mismo nombre.
Otra opción es copiar `CMakeUserPresets.json.template` como `CMakeUserPresets.json` y modificar los valores en el nuevo archivo.

### Compilar

Para compilar el proyecto con enlazado estático, primero se configura:

~~~.cmd
> cmake --preset=release
~~~

usando uno de los _presets_ en `CMakePreset.json`.
Durante esta fase, vcpkg bajará las librerías Qt y sus dependencias y las compilará para enlazado estático.

> Ojo, el proceso necesita alrededor de unos 30 GB de espacio en disco y puede tardar en completarse.

Después se compila el proyecto con CMake:

~~~.cmd
> cmake --build --preset=release
~~~

Si termina con éxito, el ejecutable estará en la carpeta `tools/vcpkg/release`.
