# Como utilizar la API del Geonetwork institucional en Python


El sistema [GeoNetwork-opensource](https://geonetwork-opensource.org/)
(que nos sirve para manejar el catálogo institucional
[Geonetwork](https://http://geonetwork.humboldt.org.co/) de datos
geográficos incluye varias applicaciones en la forma de “Application
Programming Interface” ([API](https://es.wikipedia.org/wiki/API)). Esa
posibilidad permite consultar el catálogo institucional desde varios
lenguajes de programación. En particular, esa posibilidad se utilizo
para poder integrar resultas de consultas en los 3 catálogos
institucionales en la pagina principal de la Infraestructura
Institucional de Datos e Información ([I2D](datos.humboldt.org.co)). En
este caso, el lenguaje de programación que se utilizó es
[javascript](https://es.wikipedia.org/wiki/javascript), y el codigo que
permite utilizar la API para buscar en los tres catálogos se puede
encontrar en el repositorio publico de GitHub:
[PEM-Humboldt/portal-i2d](https://github.com/PEM-Humboldt/portal-i2d).
Sin embargo, es posible también utilizar Python para utilizar la API de
Geonetwork, gracias al paquete `requests`. En este documento,
mostraremos como utilizar las API de geonetwork desde Python para buscar
recursos y juegos de datos geográficos.

## Configuración

La versión de python que utilizo para los comandos en este documento es:

``` python
import sys
print(sys.version)
```

    3.12.8 (main, Jan 19 2025, 17:59:18) [GCC 14.2.1 20241221]

En lo que concierne los paquetes, se pueden referir al archivo
[requirements.txt](../requirements.txt) de este repositorio, sin embargo
la mayoría de las dependencias que están allá es para utilizar Jupyter y
escribir documentos que contienen códigos de Python. El único paquete
indispensable para aplicar los codigos contenidos en este documento es
`requests`.

## Endpoint `search.xml`
