extends Node

# Ruta donde se encuentran los archivos fuente
# En principio, están incluidos en el proyecto (res)
var ruta_raiz = "res://REPO-hub-local-files/"

var instrucciones = \
	'\n\nLea detenidamente las instrucciones de instalación en ' + \
	'https://github.com/gpfernandezflorio/hub-godot-project ' + \
	'y vuelva a intentarlo.\n\nPresione cuaquier tecla para salir.'

var F = File.new()
var D = Directory.new()
func _ready():
	var error = false

	# Carpeta de usuario de Godot
	var ruta_godot_user = OS.get_data_dir()

	# Este booleano indica si los fuentes están en la carpeta de usuario de Godot
		# En el proyecto del repo hub-godot-project vale true ya que es la versión que se va a compilar al final
		# En el proyecto hub-godot-project-LOCAL vale false ya que es para probar y para compilar para web
	var userfs = Globals.get("userfs")

	# Este booleano indica si estoy ejecutando una versión compilada
		# OJO: Si habilito "debug_enabled" al compilar, va a valer false
	var compilado = not OS.is_debug_build()

	# Si estoy en la versión compilada y usando los funtes dentro del programa,
	if compilado and not userfs:
		# tengo que copiar los archivos a la carpeta de usuario de Godot (ej: web)
		var fs_file = ruta_raiz.plus_file("fs.txt")
		if F.file_exists(fs_file):
			F.open(fs_file, File.READ)
			var contenido = F.get_as_text().split("\n")
			F.close()
			var src = ruta_raiz
			var dst = ruta_godot_user
			copiar_carpeta(src,dst,contenido,0)
			ruta_raiz = ruta_godot_user
		else:
			error = true
			error("Te faltó ejecutar pre-compile.py")

	# Una vez que llego acá, no importa si estoy en versión compilada o no,
		# los fuentes tienen que estar en la carpeta de usuario de Godot
	if not error:
		var ruta_al_HUB = ruta_raiz.plus_file("src").plus_file("HUB.gd")
		if File.new().file_exists(ruta_al_HUB):
			var HUB = Node.new()
			HUB.set_name("HUB")
			add_child(HUB)
			HUB.set_script(load(ruta_al_HUB))
			if not HUB.inicializar(HUB):
				HUB.queue_free()
				error('Hubo un error al inicializar el HUB.' + \
				instrucciones)
		else:
			error('Error: No se puede iniciar porque no se ' + \
			'encuentra el archivo "HUB.gd" en la carpeta local.' + \
			instrucciones)

func error(mensaje):
	var label = Label.new()
	label.set_text(mensaje)
	label.set_autowrap(true)
	label.set_valign(1)
	label.set_align(1)
	label.set_size(Vector2(400,300))
	add_child(label)
	set_process_input(true)

func _input(ev):
	if (ev.type == InputEvent.KEY):
		if ev.pressed:
			get_tree().quit()

func copiar_carpeta(src,dst,contenido,j):
	var i = j
	while i<contenido.size() and contenido[i] != "||":
		var linea = contenido[i]
		if linea.begins_with("D|"):
			var d = linea.split("|")[1]
			D.open(dst)
			D.make_dir(d)
			i = copiar_carpeta(src.plus_file(d),dst.plus_file(d),contenido,i+1)
		elif linea.begins_with("F|"):
			var f = linea.split("|")[1]
			F.open(src.plus_file(f.replace(".gd",".h")), File.READ)
			var contenido = F.get_as_text()
			F.close()
			F.open(dst.plus_file(f), File.WRITE)
			F.store_string(contenido)
			F.close()
		i+=1
	return i