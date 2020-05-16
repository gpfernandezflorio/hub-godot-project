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

El código __SRC__ indica que el archivo es un script fuente del HUB. Cada tipo tiene un código asociado. En general esto es información para los usuarios y programadores pero ciertas partes del HUB asumen que esas dos líneas existen e incluso utilizan la información allí suministrada, así que se recomienda seguir la convención. Otro tipo común de archivo es el tipo __Comando__. Los archivos de comandos definen funciones que serán ejecutadas cuando se ingrese su nombre en la terminal del HUB. Para que un archivo sea reconocido como un comando por el HUB, este debe estar ubicado en la carpeta __comandos__ dentro de la _ruta\_raiz_, usar el código __Comando__ en la segunda línea e implementar la función __comando(argumentos)__, la cual será llamada cuando el usuario ingrese el comando correspondiente en la terminal del HUB.

También se pueden crear archivos con lotes de comandos para ejecutar. A diferencia de los dos anteriores, este tipo de archivo no es un script válido de GDScript, ya que cada línea contiene un comando del HUB y por lo tanto, no respeta la sintaxis de GDScript. Para que un archivo sea reconocido como un lote de comandos por el HUB, este debe estar ubicado en la carpeta __shell__ dentro de la _ruta_raiz_ y usar el código __SH__ en la segunda línea. Para poder ejecutar un lote de comandos desde la terminal se necesita el comando __sh__. Más adelante se verán otros tipos de archivos.

### Entorno de manipulación de objetos

Otra premisa del HUB es proveer al usuario una capa de abstracción orientada a objetos por encima del sistema de nodos de Godot. En esta capa, se manipulan objetos cuyo comportamiento viene dado por los componentes que lo componen y por los scripts que se le adjuntan. En Godot, cada nodo tiene un tipo (una clase) y un script asociado. El conjunto de funciones que puede ejecutar ese nodo es la unión entre las funciones de la clase a la que pertenece y las funciones definidas en el script.

En el HUB, un objeto puede tener varios componentes y varios scripts asociados. En lugar de ejecutar funciones, los objetos responden a mensajes. A cualquier objeto se le puede enviar cualquier mensaje. Para enviarle un mensaje a un objeto se debe usar la función __mensaje(metodo, parametros)__ que todo objeto implementa. A través de la abstracción de mensajes y métodos, un objeto puede responder a un mensaje ejecutando una función definida en alguno de sus scripts adjuntos. Luego, el conjunto de funciones que puede ejecutar un objeto del HUB es la unión entre las funciones definidas en cada uno de los scripts que el objeto posee.

> Nota: A diferencia del paradigma orientado a objetos, en el HUB no todo es un objeto. Muchos nodos (por ejemplo, los módulos del HUB) no respetan la interfaz de objeto y los objetos están compuestos por cosas que no necesariamente son objetos. Se consideran objetos del HUB únicamente los nodos que tienen adjunto el script __objeto__ y fueron creados utilizando el módulo de objetos del HUB.

El principal objetivo de esta abstracción es desarrollar scripts de comportamiento lo más minimales posible para que sea fácil modificar los existentes y crear nuevos. Esto no puede lograrse en el entorno de Godot ya que para definir el comportamiento de un nodo, toda la funcionalidad deseada debe estar implementada en un mismo script. Al igual que en el caso de los nodos de Godot, los objetos se organizan en una jerarquía tipo árbol. Al iniciar el HUB existe un único objeto (raíz de la jerarquía de objetos) llamado _Mundo_.

Para crear un nuevo objeto se cuenta con la función del módulo de objetos del HUB __crear(hijo_de=HUB.nodo_usuario.mundo)__. Por defecto, el nuevo objeto se crea vacío y como hijo directo del _Mundo_ en la jerarquía. Un objeto vacío puede responder a cualquier mensaje, aunque como en el paradigma orientado a objetos, a la mayoría de los mensajes responderá que no entiende el mensaje recibido (_MessageNotUnderstood_).

Para que el objeto empiece a responder mensajes adecuadamente se le deben adjuntar scripts de comportamiento con la función __agregar_comportamiento(nombre_script)__. Los scripts de comportamiento son otro tipo de archivos del HUB sin ninguna otra particularidad que la de definir funciones. Un objeto sabrá responder un mensaje si alguno de sus scripts de comportamiento asociados implementa la función correspondiente. Para que un archivo sea reconocido como un script de comportamiento por el HUB, este debe estar ubicado en la carpeta __comportamiento__ dentro de la _ruta_raiz_ y usar el código __Comportamiento__ en la segunda línea.

### Objetos del HUB

### Programas

Hasta ahora los comandos fueron sólo funciones que se ejecutan ininterrumpidamente de principio a fín. Pero el HUB permite también definir programas que se ejecuten como procesos en segundo plano. Esto no quiere decir que los procesos se ejecuten en paralelo. De hecho, tanto los comandos como los procesos se implementan como scripts adjuntos a nodos. La diferencia es que en el caso de los comandos, existe un único nodo para cada comando y cada vez que se quiere ejecutar dicho comando se llama a la función __comando(argumentos)__ de ese nodo. En el caso de los programas, cada vez que se crea un proceso, se crea un nuevo nodo al que se le adjunta el script correspondiente, por lo que podrían tenerse varias instancias de un mismo programa ejecutándose a la vez (nuevamente, esto no quiere decir que ejecuten en paralelo sino que ambos nodos están vivos a la vez e incluso pueden interactuar entre sí).

Para crear un proceso se debe llamar a la función __nuevo(programa, argumentos)__ del módulo de procesos del HUB. El parámetro _programa_ debe ser un script de programa válido. Para que un archivo sea reconocido como un script de programa por el HUB, este debe estar ubicado en la carpeta __programas__ dentro de la _ruta_raiz_, implementar la función __finalizar()__ y usar el código __Programa__ en la segunda línea. Además, los scripts de programas difieren al resto de los scripts en cuanto a que la función __inicializar__ además de tomar como parámetro el HUB, debe tomar como parámetro el identificador de proceso y los argumentos. Notar que los procesos siguen vivos por defecto (incluso tras terminar de ejecutar la función de inicialización) y no finalizan hasta que llamen explícitamente a la función __finalizar(pid)__ del módulo de procesos del HUB (o hasta que el proceso sea terminado desde afuera). La función __finalizar(pid)__ del módulo de procesos a su vez llama a la función __finalizar__ del programa, así que no es necesario que un programa llame a su función de finalización si está a punto de finalizar. Sólo debe llamar a la función __finalizar(pid)__ del módulo de procesos.

Otra diferencia importante entre comandos y programas es que los programas pueden, a su vez, definir comandos. Esto significa que, tras lanzar un proceso, los comandos lanzados en la terminal pueden interpretarse tanto como comandos globales (los descriptos hasta ahora) o como comandos dentro del programa. Para definir un comando "X" en un programa sólo hay que declarar una función "__X(argumentos)" en el script del programa. Cuando el proceso esté en ejecución, al lanzar el comando "X" en la terminal, en lugar de ejecutar el script _X.gd_ se ejecutará la función "\_\_X" correspondiente en el script de dicho proceso (si es que esta está definida). Si el proceso en ejecución no tiene definido el comando ingresado, entonces se ejecuta el comando global. Para forzar al HUB a ejecutar el comando global aunque el proceso actual tenga definido un comando con el mismo nombre, se le debe anteponer el caracter "!".

### Entornos

Cada script que se ejecuta en el HUB se ejecuta dentro de un entorno. Un entorno se define con un identificador de proceso (_pid_), de tipo string y una secuencia de comandos. El proceso por defecto es el HUB, un proceso se crea desde el inicio y que no se puede finalizar y cuyo identificador es "HUB". Cuando no hay ningún proceso en ejecución, este es el proceso actual. Los comandos ejecutados por el usuario desde la terminal del HUB se ejecutan en el entorno correspondiente al proceso por defecto, a menos que el comando ingresado no sea un comando global sino un comando correspondiente al proceso actual. Luego de ejecutar un comando, al entorno se le agrega el comando ejecutado. Si este comando lanza otros comandos, cada uno de estos se va agregando al entorno de ejecución actual. Si se activa la opción correspondiente de la terminal, cada mensaje enviado muestra primero el entorno en el que se envió dicho mensaje. Como el "HUB" es el proceso por defecto, cuando el entorno incluye a este proceso sólo se muestra la secuencia de comandos.

### Bibliotecas

Como en cualquier lenguaje de programación, hay estructuras o funciones que son requeridas por muchos scripts y no tendría sentido definirlas en cada uno. Para eso existen las bibliotecas, manipuladas por el módulo de bibliotecas del HUB. Para que un archivo sea reconocido como un script de biblioteca por el HUB, este debe estar ubicado en la carpeta __bibliotecas__ dentro de la _ruta_raiz_ y usar el código __Biblioteca__ en la segunda línea. Utilizando la función __importar(biblioteca)__ del módulo de bibliotecas del HUB se puede obtener un nodo que tenga adjunto el script correspondiente a la biblioteca pasada por parámetro. De esta forma, se pueden utilizar todas las esctructuras y funciones que la biblioteca provee accediendo a los miembros de dicho nodo.

### Manejo de errores

Godot no provee funcionalidad para manejar excepciones así que siempre que se esté modificando la funcionalidad del HUB debería ejecutarse desde el entorno de Godot y no utilizando el Core compilado. La forma de simular algo parecido al manejor de excepciones es a través de la clase __Error__ declarada en el módulo de errores del HUB. Las funciones pueden devolver una instancia de un error en caso de que fallen por alguna razón. La función que recibe un error puede decidir qué hacer con él. La clase error sólo contiene una variable con el mensaje de error y, eventualmente, una referencia a un error previo en caso de que el error haya sido generado por un error anterior.

El módulo de errores define la función __error(mensaje, stack_error=null)__ que devuelve un error genérico con el mensaje pasado por parámetro. Otros módulos definen otros tipos de errores como funciones. Por ejemplo, el módulo de archivos define la función __archivo_inexistente(ruta, archivo, stack_error=null)__ que devuelve un error con el mensaje correspondiente, llamando a la función __error(mensaje, stack_error=null)__ del módulo de errores. De esta forma, se pueden crear nuevos tipos de errores. El módulo de errores también implementa la función __fallo(resultado)__ que determina si el resultado de un llamado a una función generó un error. Esta función puede utilizarse para verificar el resultado tras un llamado a una función que puede fallar.

### Testing

El HUB también provee un módulo de testing para evaluar el correcto funcionamiento de otros scripts. La función principal de dicho módulo es __test(tester, verificador, mensajes_esperados=null)__ que toma como parámetros dos estructuras. La primera estructura representa el test a ejecutar. Debe definir la función __test()__, la cual será ejecutada por el módulo de testing y sobre cuyo resultado se espera realizar una verificación. Dicha verificación debe definirse a través de la estructura pasada como segundo parámetro. Esta estructura debe definir la función __verificar(resultado)__ la cual debe devolver un string vacío si el resultado pasado por parámetro hace que el test sea exitoso y un mensaje de error (indicando por qué no se cumplió la condición de verificación) en caso contrario. Opcionalmente se le puede pasar como tercer parámetro una lista de mensajes para verificar que la ejecución del tester produzca dichos mensajes. Opcionalmente, el verificador puede implementar la función __verificar_error__ en caso de que se quiera verificar algo cuando se produce un error (por defecto, si se produce un error, el verificador no se ejecuta).

## Módulos del HUB

Cada módulo se implementa en un script, asociado a un nodo de Godot. El nodo raíz es el HUB, que tiene asociado el script __HUB.gd__. Este script crea un nodo por cada módulo del HUB, inserta ese nodo como hijo del nodo HUB y le asocia su script correspondiente (del mismo nombre). Todos los scripts que definen los módulos del HUB pueden verse en la carpeta __src__. Después de la etapa de inicialización, el nodo HUB sirve como punto de entrada para acceder a los distintos módulos. Es por esto que se toma como convención que todos los archivos que sean scripts mantengan una variable con una referencia al nodo HUB. Esta variable puede inicializarse cuando se ejecuta la función __inicializar(hub)__ del script en cuestión. El HUB provee las siguientes funciones:
* mensaje(texto) : Envía un mensaje al HUB y lo muestra en la terminal.
* error(error, emisor="") : Notifica que se generó un error. Toma como parámetro el error generado y también lo devuelve. El error puede crearse con la función __error(mensaje, stack_error=null)__ del módulo de errores, aunque es recomendable encapsular ese llamado dentro de una función cuyo nombre indique el tipo de error generado (ver ejemplos en los módulos que declaran errores).
* salir() : Finaliza la ejecución del HUB.

### Archivos

Este módulo se utiliza para acceder a los archivos dentro de la _ruta_raiz_. Provee las siguientes funciones:
* abrir(ruta, nombre, tipo=null) : Carga el contenido del archivo _nombre_. Si se le pasa como tercer parámetro un código de tipo hace todas las verificaciones necesarias para que el archivo sea un archivo válido de ese tipo y devuelve un error si no cumple alguna de esas condiciones. También puede devolver un error si el archivo no existe.
* leer(ruta, nombre) : Carga el contenido del archivo _nombre_ y lo devuelve como texto. Devuelve un error si el archivo no existe.
* escribir(ruta, nombre, contenido, en_nueva_linea=true) : Escribe el texto _contenido_ al final del archivo _nombre_. Devuelve un error si el archivo no existe. Si se le pasa _false_ como cuarto parámetro, el nuevo texto se escribe inmediatamente a continuación del contenido existente en el archivo, es decir, sin un salto de línea antes.
* sobrescribir(ruta, nombre, contenido) : Sobrescribe el contenido del archivo _archivo_ con el texto _contenido_. Devuelve un error si el archivo no existe.
* existe(ruta, nombre) : Devuelve si existe el archivo _nombre_.
* es_archivo(ruta, nombre) : Devuelve si el archivo _nombre_ es efectivamente un archivo (es decir, no un directorio). Devuelve un error si el archivo no existe.
* es_directorio(ruta, nombre) : Devuelve si el archivo _nombre_ es en realidad un directorio. Devuelve un error si el archivo no existe.
* crear(ruta, nombre) : Crea un nuevo archivo vacío con el nombre _nombre_ en la carpeta _ruta_. Devuelve error si el archivo ya existe.
* crear_directorio(ruta, nombre) : Crea un nuevo directorio con el nombre _nombre_ en la carpeta _ruta_. Devuelve error si el directorio ya existe.
* borrar(ruta, nombre) : Elimina el archivo _nombre_. Devuelve error si el archivo no existe. Si es una carpeta, elimina también todo su contenido recursivamente.
* listar(ruta, carpeta) : Devuelve una lista con los nombres de todos los archivos contenidos en la carpeta _ruta_. Devuelve un error si la carpeta no existe o si no es un directorio.

También declara los siguientes errores:
* archivo_inexistente(ruta, archivo, stack_error=null) : El archivo _archivo_ no se encuentra en la ruta _ruta_.
* archivo_ya_existe(ruta, archivo, stack_error=null) : El archivo _archivo_ no se puede crear porque ya existe.
* archivo_invalido(archivo, tipo, stack_error=null) : El archivo _archivo_ no es un archivo válido de tipo _tipo_.
* encabezado_faltante(archivo, stack_error=null) : El archivo _archivo_ no contiene encabezado.
* encabezado_invalido_nombre(archivo, nombre, stack_error=null) : El encabezado del archivo _archivo_ no contiene el nombre del archivo.
* encabezado_invalido_tipo(archivo, tipo, stack_error=null) : El encabezado del archivo _archivo_ no contiene el tipo de archivo.
* encabezado_invalido_objeto(archivo, stack_error=null) : El encabezado del archivo _archivo_ no contiene el tipo de objeto.
* funciones_no_implementadas(archivo, tipo, stack_error=null) : El archivo _archivo_ no implementa las funciones necesarias para ser de tipo _tipo_.
* no_es_un_directorio(ruta, archivo, stack_error=null) : El archivo _archivo_ en la ruta _ruta_ no es una carpeta.

### Eventos

Este módulo controla el manejo de eventos. Todos los eventos del HUB pasan por este módulo. Si un nodo quiere manejar un evento debe registrarse usando las funciones que provee este módulo y proveerle al módulo una función del nodo que será la que maneje el evento. Luego, cuando el módulo recibe un evento, notifica a través de la función provista a todos aquellos que se hayan registrado para manejar tal evento. Las funciones provistas por este módulo son las siguientes:
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
* localizar(nombre_completo, desde=HUB.nodo_usuario.mundo) : Ubica a un objeto por su nombre completo. Es decir, si se tiene un objeto _Mano_ hijo de otro objeto que se llama _Brazo_, para ubicar al objeto _Mano_ como parámtro nombre_completo se le debe pasar el texto "Brazo/Mano". Una alternativa es, si ya se tiene al objeto Brazo, pasarlo como parámetro _desde_ para empezar a buscar a partir de él en la jerarquía de objetos. Luego, como parámetro nombre_completo se le debe pasar sólo "Mano". Notar que en el primer caso, no es necesario anteponer el nombre del Mundo ya que por defecto, es a partir de ese objeto que se empieza a buscar. Devuelve un error si no encuentra al objeto solicitado.
* borrar(nombre_completo, desde=HUB.nodo_usuario.mundo) : Borra el objeto ubicado por su nombre completo. Devuelve un error si no encuentra al objeto solicitado.

También declara los siguientes errores:
* objeto_inexistente(nombre_completo, desde, stack_error=null) : No se encontró ningún objeto con nombre _nombre\_completo_ en la jerarquía desde el objeto _desde_.

### Bibliotecas

Este módulo administra las bibliotecas del HUB. Provee las siguientes funciones:
* importar(biblioteca) : Devuelve el nodo correspondiente a la biblioteca solicitada. Devuelve un error si no se encuentra.

También declara los siguientes errores:
* biblioteca_inexistente(biblioteca, stack_error=null) : La biblioteca _biblioteca_ no se encuentra.
* biblioteca_no_cargada(biblioteca, stack_error=null) : La biblioteca _biblioteca_ no se pudo cargar.

### Terminal

Este módulo implementa todo lo relacionado a la terminal del HUB. Tiene 3 submódulos. El campo de entrada para ingresar texto, El campo de mensajes que muestra la salida de la ejecución de los scripts y el nodo de comandos. Este último es el que administra los comandos cargados. Cuando se presiona la tecla Enter en el campo de entrada, el nodo de comandos busca el archivo correspondiente al comando ingresado. La terminal se puede cerrar presionando la tecla Escape o enviando un mensaje vacío (presionando la tecla Enter con el campo de entrada vacío). Cuando está cerrada, puede abrirse presionando la tecla Tab. Además de los mensajes que se muestran en el campo de mensajes, el módulo de la terminal almacena un historial completo de los mensajes enviados desde que comenzó la ejecución, incluso si estos son eliminados del campo de mensajes visibles. El campo de entrada permite autocompletar con Tab y acceder al historial con las flechas hacia arriba y abajo. Las funciones provistas por este módulo son las siguientes:
* abrir() : Abre la terminal
* cerrar() : Cierra la terminal
* ejecutar(comando_con_argumentos, mostrar_mensaje=false) : Intenta ejecutar la línea _comando\_con\_argumentos_. Devuelve un error si el comando no existe. Si se le pasa _true_ como segundo parámetro, también envía el comando como un mensaje al HUB y lo muestra en el campo de mensajes.
* borrar_mensajes() : Limpia el campo de mensajes. Los mensajes dejan de ser visibles pero se almacenan en el historial oculto.
* log_completo(restaurar=false) : Devuelve el historial completo de mensajes. Si se le pasa _true_ como parámetro también restaura todos los mensajes del historial y los vuelve a mostrar en el campo de mensajes.
* imprimir_entorno(activado=true) : Activa o desactiva la función de imprimir el entorno. Cuando se habilita esta opción, cada vez que se envía un mensaje al HUB, se antepone el entorno desde el cual se envió dicho mensaje.

También declara los siguientes errores:
* comando_inexistente(comando, stack_error=null) : El comando _comando_ no existe en el HUB.
* comando_no_cargado(comando, stack_error=null) : El comando _comando_ no se pudo cargar.
* func comando_fallido(comando, stack_error=null) : Falló la ejecución del comando _comando_.

### Nodo Usuario

Este módulo no provee ninguna funcionalidad. Sólo es el nodo raíz para todo lo creado por el usuario. Tiene dos nodos hijos. Uno es la GUI de tipo Control para crear interfaces gráficas de usuario. El otro es el objeto Mundo, raíz de la jerarquía de objetos del HUB.

### Errores

Este módulo provee funciones para verificar condiciones y manejar excepciones antes de que el HUB falle. También se define la clase __Error__ para devolver ante fallas. Las funciones provistas por este módulo son las siguientes:
* error(texto, stack_error=null) : Crea y devuelve un error genérico. Si se le pasa un segundo parámetro lo guarda como referencia al error previo.
* fallo(resultado) : Retorna si el resultado de una función generó un error
* try(nodo, funcion, parametros=[]) : Intenta ejecutar una función en un nodo. Si lo logra, devuelve el resultado de la ejecución. Si no, devuelve un error.
* verificar_implementa_funcion(nodo, funcion, cantidad_de_parametros) : Verifica que el nodo _nodo_ implemente la función _funcion_ con _cantidad\_de\_parametros_ parámtros. Si no es así, devuelve un error.

También declara los siguientes errores:
* funcion_no_implementada(nodo, funcion, parametros, stack_error=null) : El nodo _nodo_ no implementa la función _funcion_ con _parametros_ parametro(s).
* try_fallo(nodo, funcion, stack_error=null) : Falló al intentar ejecutar la función _funcion_ en el nodo _nodo_.
* inicializacion_fallo(nodo, stack_error=null) : Falló al intentar inicializar el nodo _nodo_.
* argumento_invalido(argumento, stack_error=null) : El argumento ingresado al comando es inválido.

### Procesos

Este módulo administra los procesos activos. Provee las siguientes funciones:
* actual() : Devuelve el identificador (_pid_) del proceso actual.
* nuevo(programa, argumentos=[]) : Crea un nuevo proceso con el código del archivo _programa_ pasándole como argumentos la lista _argumentos_. Devuelve un error si no se encuentra.
* todos() : Devuelve la lista de procesos activos.
* entorno(pid=null) : Devuelve el entorno de ejecución (el identificador de proceso y la secuencia de comandos actual) del proceso _pid_ en forma de string. Si se le pasa como parámetro _null_, devuelve el entorno del proceso actual.
* finalizar(pid=null) : Finaliza el proceso _pid_. Si se le pasa como parámetro _null_, finaliza al proceso actual.

También declara los siguientes errores:
* programa_inexistente(programa, stack_error=null) : El programa _programa_ no se encuentra.
* programa_no_cargado(programa, stack_error=null) : El programa _programa_ no se pudo cargar.
* pid_inexistente(pid, stack_error=null) : No hay ningún proceso con identificador _pid_.

### Testing

Este módulo define todo lo referente a testing. Provee las siguientes funciones:
* asegurar(condicion) : Verifica que se cumpla una condición. Genera un error si no es así.
* test(tester, verificador, mensajes_esperados=null) : Ejecuta el test definido en _tester_ y verifica el resultado a través del verificador _verificador_. Si se le pasa como tercer parámetro una lista de mensajes, verifica también que los mensajes enviados por el tester coincidan con dicha lista. Retorna _null_ si el test fue exitoso. En caso contrario devuelve el error correspondiente.
* test_genera_error(tester, error_esperado, mensaje_esperado=null) : Ejecuta el test definido en _tester_ y verifica que genere el error _error_esperado_. Si se le pasa como tercer parámetro una lista de mensajes, verifica también que los mensajes enviados por el tester coincidan con dicha lista. Retorna _null_ si el test fue exitoso (es decir, si el tester generó el error esperado). En caso contrario devuelve el error correspondiente.
* resultado_comando(comando_ingresado, verificador, mensajes_esperados=null) : Ejecuta el comando _comando_ingresado_ y verifica el resultado a través del verificador _verificador_. Si se le pasa como tercer parámetro una lista de mensajes, verifica también que los mensajes enviados por el comando coincidan con dicha lista. Retorna _null_ si el test fue exitoso. En caso contrario devuelve el error correspondiente.
* comando_fallido(comando_ingresado, error_esperado, mensaje_esperado=null) : Ejecuta el comando _comando_ingresado_ y verifica que genere el error _error_esperado_. Si se le pasa como tercer parámetro una lista de mensajes, verifica también que los mensajes enviados por el comando coincidan con dicha lista. Retorna _null_ si el test fue exitoso (es decir, si el comando generó el error esperado). En caso contrario devuelve el error correspondiente.

También declara los siguientes testers:
* tester_comando(comando_a_ejecutar) : Devuelve un tester que ejecuta el comando _comando_a_ejecutar_.

También declara los siguientes verificadores:
* verificador_trivial() : Devuelve un verificador que siempre devuelve _true_.
* verificador_nulo() : Devuelve un verificador que se asegura que el resultado sea _null_.
* verificador_por_igualdad(resultado_esperado) : Devuelve un verificador que se asegura que el resultado sea igual a _resultado_esperado_.
* verificador_error(error_esperado) : Devuelve un verificador que se asegura que el resultado sea un error de tipo _error_esperado_.

También declara los siguientes errores:
* condicion_fallida(stack_error=null) : La condición que se quería asegurar resultó ser falsa.
* test_fallido_resultado(stack_error=null) : El test falló porque el resultado no cumplió la condición del verificador.
* test_fallido_salida(stack_error=null) : El test falló porque los mensajes enviados no fueron los esperados.
* test_fallido_error(stack_error=null) : El test generó un error inesperado.

## Creando nuevos archivos para el HUB

En la carpeta __plantillas__ dentro de la _ruta_raiz_ hay plantillas base de cada tipo de archivo. También se pueden ver los archivos ya existentes en cada carpeta para usar como guía. Excepto archivos con propósitos específicos o archivos multimedia, todos los archivos del HUB deben contener en la primera línea doble _#_, un espacio y el nombre del archivo y en la segunda línea doble "#", un espacio y el código que indica el tipo de archivo. Opcionalmente, la cuarta línea puede contener un _#_, un espacio y una descripción del archivo.

### Scripts

Como los scripts deben ser scripts válidos de GDScript, deben tener la línea "extends Node" para que Godot pueda adjuntárselos a un nodo. Para ser scripts válidos del HUB, deben implementar la función __inicializar(hub)__, la cual será llamada con el HUB como parámetro cuando el script sea agragado a un nodo de Godot. No es obligatorio pero se recomienda mantener la variable _HUB_ (e inicializarla con el parámetro _hub_) para acceder al HUB y a todos sus módulos. Esta función debería devolver _null_ a menos que se genere un error. En dicho caso, debería devolver el error generado y se asume que el script que lo creó puede eliminar al nodo correspondiente ya que este quedó en un estado inconsistente. En el caso de los scripts fuente, dado que el módulo de errores podría no haberse inicializado todavía, esta función devuelve un booleano que indica si el script se inicializó correctamente.

#### Comandos

Para ser un comando válido, el script debe implementar la función __comando(argumentos)__. El parámetro _argumentos_ se debe interpretar como una lista correspondiente a los argumentos ingresados al lanzar el comando. Esta función puede devolver un resultado para ser entregado al script que solicitó la ejecución del comando. Opcionalmente, puede implementar las funciones __descripcion()__ que devuelva una descripción corta del comando y __man()__ que devuelva el manual completo del comando. El código para archivos de comandos es __Comando__.

#### Programas

Para ser un programa válido, debe implementar la función __inicializar(hub, pid, argumentos)__ en lugar de __inicializar(hub)__. También debe implementar la función __finalizar()__ que será llamada por el módulo de procesos cuando el proceso sea terminado. El programa no debería llamar a su propia función de finalización, ya que esta será llamada por el módulo de procesos cuando se invoque a la función __finalizar(pid)__ de dicho módulo. La función __finalizar()__ de un programa debería encargarse de eliminar todos los nodos, datos y objetos creados por dicho programa, así como cancelar las suscripciones a eventos correspondientes. Por defecto, el HUB no hace nada de eso automáticamente. El código para archivos de programas es __Programa__.

#### Bibliotecas

Las bibliotecas no tienen restricciones adicionales. El código para archivos de bibliotecas es __Biblioteca__.

### Lotes de comandos

Los lotes de comandos no tienen restricciones adicionales. Cada línea debería ser un comando válido aunque eso no se verifica hasta que cada línea se intenta ejecutar. El código para archivos de lotes de comandos es __SH__. Si el HUB tiene el comando __sh__ y el lote de comandos __INI.gd__ en la carpeta __shell__, tras haberse inicializado ejecutará "sh INI.gd" en la terminal.

### Consideraciones a la hora de escribir un script para el HUB

Los scripts se ejecutarán como scripts de GDScript dentro del entorno de Godot. Esto significa que se pueden utilizar todas las herramientas provistas por el motor de Godot. Sin embargo, los módulos del HUB también hacen uso de estas herramientas y podrían entrar en conflicto con ellos. Por eso se recomienda en cambio utlizar las abstracciones del HUB para acceder a las herramientas de Godot. Algunos ejemplos:
* No utilizar la funciones __\_ready()__ o __\_init()__. Para todo lo que sea inicialización de una sóla vez, usar la función __inicializar(hub)__. Esta es llamada luego de que el nodo es agregado al árbol de nodos de Godot.
* No utilizar las funciones __\_process(delta)__ o __\_fixed_process(delta)__. En su lugar, suscribirse a los eventos temporales con __HUB.input.registrar_tiempo(nodo, funcion)__.
* No utilizar las funciones __\_input(event)__ o __\_input_event(event)__. En su lugar, suscribirse a los eventos de input con __HUB.input.registrar_press(boton, nodo, funcion)__, __HUB.input.registrar_release(boton, nodo, funcion)__, etc.
* Al trabajar con objetos, recordar que un objeto no es equivalente a un nodo de Godot. Por lo tanto,
  * No crear ni destruir objetos con las funciones de nodos (__New()__, __free()__, etc). En su lugar, usar __HUB.objetos.crear()__, __HUB.objetos.borrar(objeto)__, etc.
  * no acceder ni modificar la jerarquía de objetos con las funciones de nodos de Godot (__get_node(path)__, __get_children()__, __add_child(node)__, etc). En su lugar, usar __HUB.objetos.localizar(nombre_completo)__, __hijos()__, __agregar_hijo(objeto)__, etc.
* No utilizar las clases __File__ o __Directory__ para acceder a archivos. En su lugar, usar __HUB.archivos.abrir(ruta, nombre)__, __HUB.archivos.leer(ruta, nombre)__, etc.

## Instalación

## Apéndice
