@tool
extends EditorPlugin

var plugin_icon: Texture2D
var main_control_instance: Control

func _enable_plugin() -> void:
	pass


func _disable_plugin() -> void:
	pass


func _enter_tree() -> void:
	main_control_instance = load("res://addons/roxysqlitemanager/UI/DBViewer.tscn").instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_control_instance)
	_make_visible(false)


func _make_visible(visible: bool) -> void:
	if main_control_instance:
		main_control_instance.visible = visible


func _exit_tree() -> void:
	if main_control_instance:
		main_control_instance.queue_free()
	
	
func _has_main_screen() -> bool:
	return true
	
	
func _get_plugin_icon() -> Texture2D:
	_load_plugin_icon()
	return plugin_icon
	
	
func _get_plugin_name() -> String:
	return "SQLite manager"
	
func _load_plugin_icon() -> void:
	if !plugin_icon:
		var raw: Texture2D = load("res://addons/roxysqlitemanager/Icons/database.svg")
		var image:= raw.get_image()
		
		var max_size := maxf(image.get_size().x, image.get_size().y)
		var scale_factor : float = (16.0 / max_size) * EditorInterface.get_editor_scale()
		
		image.resize(roundi(image.get_size().x * scale_factor), roundi(image.get_size().y * scale_factor), Image.INTERPOLATE_LANCZOS)
		
		plugin_icon = ImageTexture.create_from_image(image)
