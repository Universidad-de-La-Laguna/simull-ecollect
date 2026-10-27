# Componentes y recursos de terceros

La licencia MIT del archivo [`LICENSE`](LICENSE) solo cubre el código y la documentación escritos para este proyecto.
Los elementos listados a continuación pertenecen a terceros y se rigen por sus propias licencias o condiciones.

## Código incluido en el repositorio

| Componente | Ubicación | Autor | Licencia |
|---|---|---|---|
| JSONListModel | [`src/qml/imports/JSONListModel/`](src/qml/imports/JSONListModel/) | Romain Pokrzywka (KDAB), 2012; JSONPath de Stefan Goessner, 2007 | MIT ([`LICENSE`](src/qml/imports/JSONListModel/LICENSE)) |
| base64.h | [`src/thirdparty/base64.h`](src/thirdparty/base64.h) | tomykaira, 2016 | MIT (en la cabecera del archivo) |
| SimpleCrypt | [`src/thirdparty/simplecrypt/`](src/thirdparty/simplecrypt/) | Andre Somers, 2011 | BSD 3-Clause (en la cabecera de los archivos) |

## Dependencias externas (no incluidas, se obtienen al compilar)

| Componente | Cómo se obtiene | Licencia |
|---|---|---|
| Qt 6 (Core, Multimedia, Quick, Linguist) | Instalación de Qt o vcpkg | LGPL-3.0 / GPL / comercial |
| AWS SDK for C++ | vcpkg | Apache-2.0 |
| vcpkg | Submódulo en `tools/vcpkg` | MIT |

> El ejecutable con enlazado estático incluye Qt. Quien lo redistribuya debe cumplir las condiciones de la LGPL-3.0 de Qt, lo que en la práctica supone permitir volver a enlazarlo con otra versión de Qt (por ejemplo, proporcionando los ficheros objeto).

## Recursos gráficos y multimedia

| Recurso | Ubicación | Origen | Licencia |
|---|---|---|---|
| Material Design Icons (webfont) | [`res/fonts/materialdesignicons-webfont.ttf`](res/fonts/materialdesignicons-webfont.ttf) | [Pictogrammers](https://pictogrammers.com/library/mdi/) | Apache-2.0 (iconos) / SIL OFL 1.1 (fuente) |
| Emojis de reacción | [`res/images/`](res/images/) | [Noto Emoji](https://github.com/googlefonts/noto-emoji), Google. Las versiones `-greyed` son derivadas en escala de grises | Apache-2.0 |
| Lista de países | [`res/countries.json`](res/countries.json) | Elaborada a partir de la norma ISO 3166-1, con los códigos numéricos, alfa-2 y alfa-3 y los nombres de los países en inglés y español | Son datos factuales: los códigos y los nombres de países no están sujetos a derechos de autor |
| Cuenta atrás de transición | [`res/videos/film_leader.mp4`](res/videos/film_leader.mp4) | "intro 5 4 3 2 1 (Old Film)", canal de YouTube หวังชง คลาสสิก, 2016 ([67lnjV6SrFw](https://www.youtube.com/watch?v=67lnjV6SrFw)) | El autor permite usarlo y compartirlo, según la descripción del vídeo: "Permission to use อนุญาตให้นำไปใช้และแชร์ต่อได้". No indica una licencia formal |

## Vídeos e imágenes de campañas turísticas

En el experimento se usó como estímulo material promocional de dos campañas:

- `islas_canarias/`: campaña "Hola Islas Canarias" (Turismo de Islas Canarias / Promotur). Los vídeos proceden de YouTube y las imágenes de [@hellocanaryislands](https://www.instagram.com/hellocanaryislands) en Instagram.
- `visit_tenerife/`: campaña "Visit Tenerife" (Turismo de Tenerife). Los vídeos proceden de YouTube y las imágenes de [@visit_tenerife](https://www.instagram.com/visit_tenerife/) en Instagram.

Estos materiales están protegidos por los derechos de autor de sus titulares y **no se distribuyen con este repositorio**.
La lista de archivos está en [`res/campains/README.md`](res/campains/README.md).
