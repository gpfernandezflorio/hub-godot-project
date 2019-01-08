# hub-godot-project

Este repositorio contiene los archivos del proyecto de [Godot Engine](URL "https://godotengine.org/") 2.1.4 correspondiente al Core del HUB.

## ¿Qué es el HUB? ¿Qué es el Core?

El HUB es un entorno que permite ejecutar scripts del lenguaje de scripting de Godot, GDScript. Fue desarrollado con la idea de que sea 100% manipulable sin la necesidad de recompilar y por eso el programa resultante de exportar este proyecto no hace nada más que levantar un script para que sea este el que realmente inicialice el entorno. Dicho programa es el Core del HUB.

Al descargar y exportar este proyecto se obtendrá el Core compilado. Al ejecutarlo aparecerá un mensaje de error indicando que no se puede localizar el archivo __HUB.gd__. Esto es porque el Core en sí no hace nada. Para funcionar necesita los archivos fuente del HUB. Esos archivos, como todos los archivos que maneja el HUB, son scripts de GDScript y, por lo tanto, pueden ser modificados a gusto.

### Fuentes del HUB

El script principal del HUB es __HUB.gd__. Sin este archivo, el Core sólo mostrará un error. Este script tampoco hace mucho. Se encarga de crear e inicializar cada uno de los módulos necesarios para poder comenzar a utilizar el HUB. Cuando el HUB está inicializado, funciona como una línea de comandos. En la pantalla se muestra un campo para ingresar texto y un panel de mensajes. Al escribir un comando en el campo de texto y presionar la tecla Enter, se ejecutará el script correspondiente al comando ingresado. Al igual que en una terminal, esto funciona localizando un archivo con el mismo nombre que el comando ingresado (tras agregarle la extensión _.gd_), sólo que en lugar de buscar y ejecutar archivos binarios, se trabaja con scripts de GDScript. Esto hace que sea fácil agregar nuevos scripts o modificar los existentes.

### Agregar archivos al Core del HUB

Como ya se mencionó, el Core por sí solo no hace nada; necesita los archivos externos de GDScript para funcionar. Por una restricción del motor de Godot, estos archivos deben estar ubicados en un directorio específico del sistema operativo. A dicho directorio se lo llamará la _ruta_raiz_ del HUB. Dentro de la _ruta_raiz_ debe haber distintas carpetas que organicen todos los tipos de archivos con los que el HUB puede interactuar. Los archivos fuente ya mencionados (los que definen el comportamiento del HUB) deben estar en la carpeta __src__, dentro de la _ruta_raiz_. Estos no deberían ser modificados, a menos que sepan lo que están haciendo.


#### Tipos de archivos

Todos los archivos del HUB (salvo archivos multimedia) deben tener la extensión _.gd_. Sin embargo, existen distintos tipos de archivos con distintas funcionalidades. La mayoría son scripts (es decir, código ejecutable) pero no todos se ejecutan de la misma manera. El tipo de un archivo se identifica por la carpeta que lo contiene dentro de la _ruta_raiz_ y por el contenido del mismo. La convención es iniciar las dos primeras líneas de cada archivo con el nombre y el tipo del archivo en cuestión, tras doble _#_ y un espacio. Por ejemplo, las dos primeras líneas del archivo __HUB.gd__ son:

```
## HUB
## SRC
```

El código __SRC__ indica que el archivo es un script fuente del HUB. Cada tipo tiene un código asociado. En general esto es información para los usuarios y programadores pero ciertas partes del HUB asumen que esas dos líneas existen e incluso utiliazan la información allí suministrada, así que se recomienda seguir la convención. Otro tipo común de archivo es el tipo __Comando__. Los archivos de comandos definen rutinas que serán ejecutadas cuando se ingrese su nombre en la terminal del HUB. Para que un script sea reconocido como un comando por el HUB, este debe estar ubicado en la carpeta __comandos__ dentro de la _ruta\_raiz_, usar el código __Comando__ en la segunda línea e implementar la función __comando(argumentos)__.

También se pueden crear archivos con lotes de comandos para ejecutar. A diferencia de los dos anteriores, este tipo de archivo no es un script válido de GDScript. Para que un archivo sea reconocido como un lote de comandos por el HUB, este debe estar ubicado en la carpeta __shell__ dentro de la _ruta_raiz_ y usar el código __SH__ en la segunda línea. Para poder ejecutar un lote de comandos desde la terminal se necesita el comando __sh__. Más adelante se verán otros tipos de archivos.

## Entorno de manipulación de objetos

Otra premisa del HUB es proveer al usuario una capa de abstracción orientada a objetos por encima del sistema de nodos de Godot. En esta capa, se manipulan objetos cuyo comportamiento viene dado por los componentes que lo componen y por los scripts que se le adjuntan. En Godot, cada nodo tiene un tipo (una clase) y un script asociado. El conjunto de funciones que puede ejecutar ese nodo es la unión entre las funciones de la clase a la que pertenece y las funciones definidas en el script.

En el HUB, un objeto puede tener varios componentes y varios scripts asociados. En lugar de ejecutar funciones, los objetos responden a mensajes. A cualquier objeto se le puede enviar cualquier mensaje. Para enviarle un mensaje a un objeto se debe usar la función __mensaje(metodo, parametros)__ que todo objeto implementa. A través de la abstracción de mensajes y métodos, un objeto puede responder a un mensaje ejecutando una función definida en alguno de sus scripts adjuntos. Luego, el conjunto de funciones que puede ejecutar un objeto del HUB es la unión entre las funciones definidas en cada uno de los scripts que el objeto posee.

> Nota: A diferencia del paradigma orientado a objetos, en el HUB no todo es un objeto. Muchos nodos (por ejemplo, los módulos del HUB) no respetan la interfaz de objeto y los objetos están compuestos por cosas que no necesariamente son objetos. Se consideran objetos del HUB únicamente los nodos que tienen adjunto el script __objeto__ y fueron creados utilizando el módulo de objetos del HUB.

El principal objetivo de esta abstracción es desarrollar scripts de comportamiento lo más minimales posible para que sea fácil modificar los existentes y crear nuevos. Esto no puede lograrse en el entorno de Godot ya que para definir el comportamiento de un nodo, toda la funcionalidad deseada debe estar implementada en un mismo script. Al igual que en el caso de los nodos de Godot, los objetos se organizan en una jerarquía tipo árbol. Al iniciar el HUB existe un único objeto (raíz de la jerarquía de objetos) llamado _Mundo_.

Para crear un nuevo objeto se cuenta con la función del módulo de objetos del HUB __crear()__. Por defecto, el nuevo objeto se crea vacío y como hijo directo del _Mundo_ en la jerarquía. Un objeto vacío puede responder a cualquier mensaje, aunque como en el paradigma orientado a objetos, a la mayoría de los mensajes responderá que no entiende el mensaje recibido (_MessageNotUnderstood_).

Para que el objeto empiece a responder mensajes adecuadamente se le deben adjuntar scripts de comportamiento con la función __agregar_comportamiento(nombre_script)__. Los scripts de comportamiento son otro tipo de archivos del HUB sin ninguna otra particularidad que la de definir funciones. Un objeto sabrá responder un mensaje si alguno de sus scripts de comportamiento asociados implementa la función correspondiente. Para que un archivo sea reconocido como un script de comportamiento por el HUB, este debe estar ubicado en la carpeta __comportamiento__ dentro de la _ruta_raiz_ y usar el código __Comportamiento__ en la segunda línea.

## Programas

Hasta ahora los comandos fueron sólo funciones que se ejecutan ininterrumpidamente de principio a fín. Pero el HUB permite también definir programas que se ejecuten como procesos en segundo plano. Los programas del HUB también son scripts de tipo comando así que también se ejecutan escribiendo su nombre en la terminal del HUB. En cualquier momento, un comando puede lanzar un proceso llamando a la función __nuevo(data)__ del módulo de procesos del HUB.

Como son scripts de comandos, los scripts de programas deben implementar la función __comando(argumentos)__ que será ejecutada al ingresar el texto correspondiente en la terminal. Además, deben definir la función __proceso(data)__ que será ejecutada cuando se lance el nuevo proceso. Notar que los procesos siguen vivos por defecto y no finalizan hasta que llamen explícitamente a la función __finalizar()__ del módulo de procesos del HUB (o hasta que el proceso sea terminado desde afuera).

## Módulos del HUB

Cada módulo se implementa en un script, asociado a un nodo de Godot. El nodo raíz es el HUB, que tiene asociado el script __HUB.gd__. Este script crea un nodo por cada módulo del HUB, inserta ese nodo como hijo del nodo HUB y le asocia su script correspondiente (del mismo nombre). Todos los scripts que definen los módulos del HUB pueden verse en la carpeta __src__. Después de la etapa de inicialización, el nodo HUB sirve como punto de entrada para acceder a los distintos módulos. Es por esto que se toma como convención que todos los archivos que sean scripts mantengan una variable con una referencia al nodo HUB.
