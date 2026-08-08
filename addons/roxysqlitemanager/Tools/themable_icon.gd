@tool
extends ImageTexture
class_name RoxyThemableIcon

const PluginGlobals = preload("res://addons/roxysqlitemanager/globals.gd")

@export var orig_image: Texture2D:
	get:
		return orig_image
	set(val):
		orig_image = val
		generate_image()
		
@export var default_size: float = 16
		
func generate_image():
	if orig_image:
		var img := orig_image.get_image()
		
		var max_size := maxf(img.get_size().x, img.get_size().y)
		var scale_factor : float = (default_size / max_size) * EditorInterface.get_editor_scale()
	
		img.resize(roundi(img.get_size().x * scale_factor), roundi(img.get_size().y * scale_factor), Image.INTERPOLATE_LANCZOS)
		
		var current_editor_color = EditorInterface.get_editor_theme().get_color("font_color", "Editor")
		for x in range(0, img.get_width()):
			for y in range(0, img.get_height()):
				var p = img.get_pixel(x, y)
				p.r = current_editor_color.r
				p.g = current_editor_color.g
				p.b = current_editor_color.b
				p = p.lightened(0.2)
				img.set_pixel(x,y,p)
		
		self.set_image(img)
	
func _init() -> void:
	var reg: Dictionary[int, WeakRef]
	if !Engine.has_meta(PluginGlobals.ROXY_SQLITE_MANAGER_REGISTRY_NAME):
		reg = {}
		Engine.set_meta(PluginGlobals.ROXY_SQLITE_MANAGER_REGISTRY_NAME, reg)
	else:
		reg = Engine.get_meta(PluginGlobals.ROXY_SQLITE_MANAGER_REGISTRY_NAME)
	
	if !reg.has(self.get_instance_id()):
		reg[self.get_instance_id()] = weakref(self)
