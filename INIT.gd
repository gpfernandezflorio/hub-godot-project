extends Node

var ruta_raiz = "user://"

func _ready():
	var hub_script = ruta_raiz+"src/HUB.gd"
	var file = File.new()
	if file.file_exists(hub_script):
		var HUB = Node.new()
		HUB.set_name("HUB")
		add_child(HUB)
		HUB.set_script(load(hub_script))
		HUB.inicializar(HUB)
	else:
		var label = Label.new()
		label.set_text('Error: No se puede iniciar porque no se ' + \
		'encuentra el archivo "HUB.gd" en la carpeta local.\n\n' + \
		'Lea detenidamente las instrucciones de instalación en ' + \
		'https://github.com/gpfernandezflorio/hub-godot-project ' + \
		'y vuelva a intentarlo.\n\nPresione cuaquier tecla para salir.')
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