extends Node

var ruta_raiz = Globals.get("ruta_raiz")

var instrucciones = \
	'\n\nLea detenidamente las instrucciones de instalación en ' + \
	'https://github.com/gpfernandezflorio/hub-godot-project ' + \
	'y vuelva a intentarlo.\n\nPresione cuaquier tecla para salir.'

func _ready():
	var ruta_al_HUB = ruta_raiz + "src/HUB.gd"
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