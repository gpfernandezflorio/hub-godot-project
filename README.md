# hub-godot-project

Este repositorio contiene los archivos del proyecto de [Godot Engine](https://godotengine.org/) 2.1.4 correspondiente al Core del HUB.

## ¿Qué es el HUB? ¿Qué es el Core?

El HUB es un entorno que permite ejecutar scripts del lenguaje de scripting de Godot, GDScript. Fue desarrollado con la idea de que sea 100% manipulable sin la necesidad de recompilar y por eso el programa resultante de exportar este proyecto no hace nada más que levantar un script para que sea este el que realmente inicialice el entorno. Dicho programa es el Core del HUB.

Al descargar y exportar este proyecto se obtendrá el Core compilado. Al ejecutarlo aparecerá un mensaje de error indicando que no se puede localizar el archivo __HUB.gd__. Esto es porque el Core en sí no hace nada. Para funcionar necesita los archivos fuente del HUB. Esos archivos, como todos los archivos que maneja el HUB, son scripts de GDScript y, por lo tanto, pueden ser modificados a gusto.

### Fuentes del HUB

El script principal del HUB es __HUB.gd__. Sin este archivo, el Core sólo mostrará un error. Este script tampoco hace mucho. Se encarga de crear e inicializar cada uno de los módulos necesarios para poder comenzar a utilizar el HUB. Cuando el HUB está inicializado, funciona como una línea de comandos. En la pantalla se muestra un campo para ingresar texto y un panel de mensajes. Al escribir un comando en el campo de texto y presionar la tecla Enter, se ejecutará el script correspondiente al comando ingresado. Al igual que en una terminal, esto funciona localizando un archivo con el mismo nombre que el comando ingresado (tras agregarle la extensión _.gd_), sólo que en lugar de buscar y ejecutar archivos binarios, se trabaja con scripts de GDScript. Esto hace que sea fácil agregar nuevos scripts o modificar los existentes.

### Agregar archivos al Core del HUB

Como ya se mencionó, el Core por sí solo no hace nada; necesita los archivos externos de GDScript para funcionar. Por una restricción del motor de Godot, estos archivos deben estar ubicados en un directorio específico del sistema operativo. A dicho directorio se lo llamará la _ruta_raiz_ del HUB. Dentro de la _ruta_raiz_ debe haber distintas carpetas que organicen todos los tipos de archivos con los que el HUB puede interactuar. Los archivos fuente ya mencionados (los que definen el comportamiento del HUB) deben estar en la carpeta __src__, dentro de la _ruta_raiz_. Estos no deberían ser modificados, a menos que sepan lo que están haciendo.


#### Tipos de archivos

Todos los archivos del HUB (a menos que se trate de archivos muy específicos, como los archivos multimedia) deben tener la extensión _.gd_. Sin embargo, existen distintos tipos de archivos con distintas funcionalidades. La mayoría son scripts (es decir, código ejecutable) pero no todos se ejecutan de la misma manera. Una primera restricción para que un archivo _.gd_ sea considerado un script del HUB es que este implemente la función __inicializar(hub)__, que es llamada con el HUB como parámetro cada vez que se adjunta un script a un nodo. El tipo de un archivo se identifica por la carpeta que lo contiene dentro de la _ruta_raiz_ y por el contenido del mismo. La convención es iniciar las dos primeras líneas de cada archivo con el nombre y el tipo del archivo en cuestión, tras doble _#_ y un espacio. Por ejemplo, las dos primeras líneas del archivo __HUB.gd__ son:

```
## HUB
## SRC
```

El código __SRC__ indica que el archivo es un script fuente del HUB. Cada tipo tiene un código asociado. En general esto es información para los usuarios y programadores pero ciertas partes del HUB asumen que esas dos líneas existen e incluso utiliazan la información allí suministrada, así que se recomienda seguir la convención. Otro tipo común de archivo es el tipo __Comando__. Los archivos de comandos definen funciones que serán ejecutadas cuando se ingrese su nombre en la terminal del HUB. Para que un script sea reconocido como un comando por el HUB, este debe estar ubicado en la carpeta __comandos__ dentro de la _ruta\_raiz_, usar el código __Comando__ en la segunda línea e implementar la función __comando(argumentos)__.

También se pueden crear archivos con lotes de comandos para ejecutar. A diferencia de los dos anteriores, este tipo de archivo no es un script válido de GDScript, ya que cada línea contiene un comando del HUB y por lo tanto, no respeta la sintaxis de GDScript. Para que un archivo sea reconocido como un lote de comandos por el HUB, este debe estar ubicado en la carpeta __shell__ dentro de la _ruta_raiz_ y usar el código __SH__ en la segunda línea. Para poder ejecutar un lote de comandos desde la terminal se necesita el comando __sh__. Más adelante se verán otros tipos de archivos.

## Entorno de manipulación de objetos

Otra premisa del HUB es proveer al usuario una capa de abstracción orientada a objetos por encima del sistema de nodos de Godot. En esta capa, se manipulan objetos cuyo comportamiento viene dado por los componentes que lo componen y por los scripts que se le adjuntan. En Godot, cada nodo tiene un tipo (una clase) y un script asociado. El conjunto de funciones que puede ejecutar ese nodo es la unión entre las funciones de la clase a la que pertenece y las funciones definidas en el script.

En el HUB, un objeto puede tener varios componentes y varios scripts asociados. En lugar de ejecutar funciones, los objetos responden a mensajes. A cualquier objeto se le puede enviar cualquier mensaje. Para enviarle un mensaje a un objeto se debe usar la función __mensaje(metodo, parametros)__ que todo objeto implementa. A través de la abstracción de mensajes y métodos, un objeto puede responder a un mensaje ejecutando una función definida en alguno de sus scripts adjuntos. Luego, el conjunto de funciones que puede ejecutar un objeto del HUB es la unión entre las funciones definidas en cada uno de los scripts que el objeto posee.

> Nota: A diferencia del paradigma orientado a objetos, en el HUB no todo es un objeto. Muchos nodos (por ejemplo, los módulos del HUB) no respetan la interfaz de objeto y los objetos están compuestos por cosas que no necesariamente son objetos. Se consideran objetos del HUB únicamente los nodos que tienen adjunto el script __objeto__ y fueron creados utilizando el módulo de objetos del HUB.

El principal objetivo de esta abstracción es desarrollar scripts de comportamiento lo más minimales posible para que sea fácil modificar los existentes y crear nuevos. Esto no puede lograrse en el entorno de Godot ya que para definir el comportamiento de un nodo, toda la funcionalidad deseada debe estar implementada en un mismo script. Al igual que en el caso de los nodos de Godot, los objetos se organizan en una jerarquía tipo árbol. Al iniciar el HUB existe un único objeto (raíz de la jerarquía de objetos) llamado _Mundo_.

Para crear un nuevo objeto se cuenta con la función del módulo de objetos del HUB __crear()__. Por defecto, el nuevo objeto se crea vacío y como hijo directo del _Mundo_ en la jerarquía. Un objeto vacío puede responder a cualquier mensaje, aunque como en el paradigma orientado a objetos, a la mayoría de los mensajes responderá que no entiende el mensaje recibido (_MessageNotUnderstood_).

Para que el objeto empiece a responder mensajes adecuadamente se le deben adjuntar scripts de comportamiento con la función __agregar_comportamiento(nombre_script)__. Los scripts de comportamiento son otro tipo de archivos del HUB sin ninguna otra particularidad que la de definir funciones. Un objeto sabrá responder un mensaje si alguno de sus scripts de comportamiento asociados implementa la función correspondiente. Para que un archivo sea reconocido como un script de comportamiento por el HUB, este debe estar ubicado en la carpeta __comportamiento__ dentro de la _ruta_raiz_ y usar el código __Comportamiento__ en la segunda línea.

## Otros tipos de archivos

### Programas

Hasta ahora los comandos fueron sólo funciones que se ejecutan ininterrumpidamente de principio a fín. Pero el HUB permite también definir programas que se ejecuten como procesos en segundo plano. Esto no quiere decir que los procesos se ejecuten en paralelo. De hecho, tanto los comandos como los procesos se implementan como scripts adjuntos a nodos. La diferencia es que en el caso de los comandos, existe un único nodo para cada comando y cada vez que se quiere ejecutar dicho comando se llama a la función __comando(argumentos)__ de ese nodo. En el caso de los programas, cada vez que se crea un proceso, se crea un nuevo nodo al que se le adjunta el script correspondiente, por lo que podrían tenerse varias instancias de un mismo programa ejecutándose a la vez (nuevamente, esto no quiere decir que ejecuten en paralelo sino que ambos nodos están vivos a la vez e incluso pueden interactuar entre sí).

Para crear un proceso se debe llamar a la función __nuevo(programa, argumentos)__ del módulo de procesos del HUB. El parámetro _programa_ debe ser un script de programa válido. Para que un archivo sea reconocido como un script de programa por el HUB, este debe estar ubicado en la carpeta __programas__ dentro de la _ruta_raiz_ y usar el código __Programa__ en la segunda línea. Además, los scripts de programas difieren al resto de los scripts en cuanto a que la función __inicializar__ además de tomar como parámetro el HUB, debe tomar como parámetro el número identificador de proceso y los argumentos. Notar que los procesos siguen vivos por defecto (incluso tras terminar de ejecutar la función de inicialización) y no finalizan hasta que llamen explícitamente a la función __finalizar(pid)__ del módulo de procesos del HUB (o hasta que el proceso sea terminado desde afuera).

Otra diferencia importante entre comandos y programas es que los programas pueden, a su vez, definir comandos. Esto significa que, tras lanzar un proceso, los comandos lanzados en la terminal pueden interpretarse tanto como comandos globales (los descriptos hasta ahora) o como comandos dentro del programa. Para definir un comando "X" en un programa sólo hay que declarar una función "__X(argumentos)" en el script del programa. Cuando el proceso esté en ejecución, al lanzar el comando "X" en la terminal, en lugar de ejecutar el script _X.gd_ se ejecutará la función "\_\_X" correspondiente en el script de dicho proceso (si es que esta está definida). Si el proceso en ejecución no tiene definido el comando ingresado, entonces se ejecuta el comando global. Para forzar al HUB a ejecutar el comando global aunque el proceso actual tenga definido el comando, se le debe anteponer el caracter "!".

### Bibliotecas

### Comportamiento

### Objeto

## Módulos del HUB

Cada módulo se implementa en un script, asociado a un nodo de Godot. El nodo raíz es el HUB, que tiene asociado el script __HUB.gd__. Este script crea un nodo por cada módulo del HUB, inserta ese nodo como hijo del nodo HUB y le asocia su script correspondiente (del mismo nombre). Todos los scripts que definen los módulos del HUB pueden verse en la carpeta __src__. Después de la etapa de inicialización, el nodo HUB sirve como punto de entrada para acceder a los distintos módulos. Es por esto que se toma como convención que todos los archivos que sean scripts mantengan una variable con una referencia al nodo HUB. Esta variable puede inicializarse cuando se ejecuta la función __inicializar(hub)__ del script en cuestión. El HUB provee las siguientes funciones:
* mensaje(texto) : Envía un mensaje al HUB y lo muestra en la terminal.
* salir() : Finaliza la ejecución.

### Archivos

Este módulo se utiliza para acceder a los archivos dentro de la _ruta_raiz_. Provee las siguientes funciones:
* abrir(ruta, nombre) : Carga el contenido de un archivo. Devuelve _null_ si el archivo no existe.
* leer(ruta, nombre) : Carga el contenido de un archivo y lo devuelve como texto. Devuelve _null_ si el archivo no existe.
* existe(ruta, nombre) : Devuelve si existe el archivo solicitado.

### Eventos

Este módulo controla el manejo de eventos. Todos los eventos del HUB pasan por este módulo. Si un nodo quiere manejar un evento debe registrarse usando las funciones que provee este módulo y proveerle al módulo una función del nodo que será la que maneje el evento. Luego, cuando el módulo recibe un evento, notifica a través de la función provista a todos aquellos que se hayan registrado para manejar tal evento. Las funciones que provee son las siguientes:
* registrar_press(boton, nodo, funcion) : Registra al nodo _nodo_ para que al presionarse el boton _boton_ se llame a la función _funcion_. La función utilizada no debe tomar parámetros.
* registrar_release(boton, nodo, funcion) : Registra al nodo _nodo_ para que al soltarse el boton _boton_ se llame a la función _funcion_. La función utilizada no debe tomar parámetros.
* registrar_ventana_escalada(nodo, funcion) : Registra al nodo _nodo_ para que al modificarse el tamaño de la pantalla se llame a la función _funcion_. La función utilizada debe tomar un parámetro que será la nueva resolución de la ventana.
* set_modo_mouse(modo) : Asigna el modo del cursor del mouse. El valor del parámetro _modo_ puede ser:
  - 0 : Normal
  - 1 : Cursor invisible
  - 2 : Sin cursor (scroll infinito)

> Nota: Cuando se habla de botones, puede ser una tecla del teclado o un botón del mouse, ver constantes _KEY\__ y _MOUSE\__ [aquí](https://docs.godotengine.org/en/2.1/classes/class_@global%20scope.html).

### Pantalla

Este módulo controla todo lo relacionado con la pantalla. Mantiene la variable _resolucion_ que almacena el vector con la resolución actual de la ventana y provee las siguiente funciones:
* completa(encendido=true) : Activa o desactiva el modo pantalla completa.
* tamanio(nueva_resolucion) : Escala la ventana del HUB a la resolución _nueva\_resolucion_.

### Objetos

Este módulo manipula los objetos del HUB. Provee las siguientes funciones:
* crear(hijo_de=HUB.nodo_usuario.mundo) : Crea un nuevo objeto vacío como hijo de _hijo\_de_ en la jerarquía de objetos. Si no se le pasa ningún parámetro, lo crea como hijo del objeto Mundo. Si se le pasa como parámetro _null_, no lo agrega a la jerarquía de objetos.
* localizar(nombre_completo, desde=HUB.nodo_usuario.mundo) : Ubica a un objeto por su nombre completo. Es decir, si se tiene un objeto _Mano_ hijo de otro objeto que se llama _Brazo_, para ubicar al objeto _Mano_ como parámtro nombre_completo se le debe pasar el texto "Brazo/Mano". Una alternativa es, si ya se tiene al objeto Brazo, pasarlo como parámetro _desde_ para empezar a buscar a partir de él en la jerarquía de objetos. Luego, como parámetro nombre_completo se le debe pasar sólo "Mano". Notar que en el primer caso, no es necesario anteponer el nombre del Mundo ya que por defecto, es a partir de ese objeto que se empieza a buscar.

### Bibliotecas

Este módulo administra las bibliotecas del HUB. Provee las siguientes funciones:
* importar(biblioteca) : Devuelve el nodo correspondiente a la biblioteca solicitada. Devuelve _null_ si no se encuentra.

### Terminal

### Nodo Usuario

### Errores

### Procesos

## Objetos del HUB

## Creando nuevos archivos para el HUB

En la carpeta __plantillas__ dentro de la _ruta_raiz_ hay plantillas base de cada tipo de archivo. También se pueden ver los archivos ya existentes en cada carpeta para usar como guía. Excepto archivos con propósitos específicos o archivos multimedia, todos los archivos del HUB deben contener en la primera línea doble _#_, un espacio y el nombre del archivo y en la segunda línea doble "#", un espacio y el código que indica el tipo de archivo. Opcionalmente, la cuarta línea puede contener un _#_, un espacio y una descripción del archivo.

### Scripts

Como los scripts deben ser scripts válidos de GDScript, deben tener la línea "extends Node" para que Godot pueda adjuntárselos a un nodo. Para ser scripts válidos del HUB, deben implementar la función __inicializar(hub)__, la cual será llamada con el HUB como parámetro cuando el script sea agragado a un nodo de Godot. No es obligatorio pero se recomienda mantener la variable _HUB_ (e inicializarla con el parámetro _hub_) para acceder al HUB y a todos sus módulos. Esta función debe devolver un booleano que indique si el script se inicializó correctamente. Si no fue así, se asume que el script que lo creó puede eliminar al nodo correspondiente ya que este quedó en un estado inconsistente.

#### Comandos

Para ser un comando válido, el script debe implementar la función __comando(argumentos)__. El parámetro _argumentos_ se debe interpretar como una lista correspondiente a los argumentos ingresados al lanzar el comando. Opcionalmente, puede implementar las funciones __descripcion()__ que devuelva una descripción corta del comando y __man()__ que devuelva el manual completo del comando. El código para archivos de comandos es __Comando__.

#### Programas

Para ser un programa válido, debe implementar la función __inicializar(hub, pid, argumentos)__ en lugar de __inicializar(hub)__. El código para archivos de programas es __Programa__.

#### Bibliotecas

Las bibliotecas no tienen restricciones adicionales. El código para archivos de bibliotecas es __Biblioteca__.

### Lotes de comandos

Los lotes de comandos no tienen restricciones adicionales. El código para archivos de lotes de comandos es __SH__. Si el HUB tiene el comando __sh__ y el lote de comandos __INI.gd__, tras haberse inicializado ejecutará "sh INI.gd" en la terminal.

### Consideraciones a la hora de escribir un script para el HUB

Los scripts se ejecutarán como scripts de GDScript dentro del entorno de Godot. Esto significa que se pueden utilizar todas las herramientas provistas por el motor de Godot. Sin embargo, los módulos del HUB también hacen uso de estas herramientas y podrían entrar en conflicto con ellos. Por eso se recomienda en cambio utlizar las abstracciones del HUB para acceder a las herramientas de Godot. Algunos ejemplos:
* No utilizar la funciones __\_ready()__ o __\_init()__. Para todo lo que sea inicialización de una sóla vez, usar la función __inicializar(hub)__. Esta es llamada luego de que el nodo es agregado al árbol de nodos de Godot.
* No utilizar las funciones __\_process(delta)__ o __\_fixed_process(delta)__. En su lugar, suscribirse los eventos temporales con __HUB.input.registrar_tiempo(nodo, funcion)__.
* No utilizar las funciones __\_input(event)__ o __\_input_event(event)__. En su lugar, suscribirse los eventos de input con __HUB.input.registrar_press(boton, nodo, funcion)__, __HUB.input.registrar_release(boton, nodo, funcion)__, etc.
* Al trabajar con objetos, recordar que un objeto no es equivalente a un nodo de Godot. Por lo tanto,
  * No crear ni destruir objetos con las funciones de nodos (__New()__, __free()__, etc). En su lugar, usar __HUB.objetos.crear()__, __HUB.objetos.borrar(objeto)__, etc.
  * no acceder ni modificar la jerarquía de objetos con las funciones de nodos de Godot (__get_node(path)__, __get_children()__, __add_child(node)__, etc). En su lugar, usar __HUB.objetos.localizar(nombre_completo)__, __hijos()__, __agregar_hijo(objeto)__, etc.
* No utilizar la clase __File__ para acceder a archivos. En su lugar, usar __HUB.archivos.abrir(ruta, nombre)__, __HUB.archivos.leer(ruta, nombre)__, etc.

## Instalación

## Apéndice
