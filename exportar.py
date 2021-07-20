import os

reemplazos_tscn = [
    {'2':'[gd_scene load_steps=2 format=1]\n', '3':'[gd_scene load_steps=2 format=2]\n'},
    {'2':'\nscript/script = ExtResource( 1 )\n', '3':'\nscript = ExtResource( 1 )\n'}
]
archivo_tscn = 'HUB.tscn'

def ajustar_a_version_godot(major):
    target = str(major)
    other = ('2' if major == 3 else '3')
    ajustar_a_version_godot_tscn(target, other)
    target = '#@' + target
    other = '#@' + other
    ajustar_a_version_godot_recursivo('.', target, other)

def ajustar_a_version_godot_tscn(target, other):
    f = open(archivo_tscn, 'r')
    data = f.read()
    f.close()
    for r in reemplazos_tscn:
        data = data.replace(r[other], r[target])
    f = open(archivo_tscn, 'w')
    f.write(data)
    f.close()


def ajustar_a_version_godot_recursivo(carpeta, target, other):
    for archivo in os.listdir(carpeta):
        ruta = os.path.join(carpeta, archivo)
        if os.path.isdir(ruta):
            ajustar_a_version_godot_recursivo(ruta, target, other)
        elif es_archivo_a_modificar(ruta):
            ajustar_a_version_godot_archivo(ruta, target, other)

def es_archivo_a_modificar(ruta):
    if not os.path.isfile(ruta):
        return False
    if ruta.endswith('.gd'):
        return True

def ajustar_a_version_godot_archivo(ruta, target, other):
    f = open(ruta, 'r')
    data = f.read()
    f.close()
    modificado = False
    resultado = []
    for l in data.split('\n'):
        if l.endswith(target) and l.startswith('#'):
            resultado.append(l[1:])
            modificado = True
        elif l.endswith(other) and not l.startswith('#'):
            resultado.append('#{l}'.format(l=l))
            modificado = True
        else:
            resultado.append(l)
    if modificado:
        f = open(ruta, 'w')
        f.write('\n'.join(resultado))
        f.close()

def main():
    ajustar_a_version_godot(3)

if __name__ == '__main__':
    main()
