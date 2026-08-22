@tool
extends EditorPlugin

const PluginGlobals = preload("res://addons/roxysqlitemanager/globals.gd")
const Log = preload("res://addons/roxysqlitemanager/Tools/log.gd")

var plugin_icon: RoxyThemableIcon
var main_control_instance: Control

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	_update_log_color()
	load_main_control()

func load_main_control() -> void:
	var _already_exists := false
	if main_control_instance:
		main_control_instance.queue_free()
		_already_exists = true
		
	main_control_instance = load("res://addons/roxysqlitemanager/UI/DBViewer.tscn").instantiate()
	main_control_instance.plugin_instance = self
	EditorInterface.get_editor_main_screen().add_child(main_control_instance)
	
	if !_already_exists:
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

func _on_theme_change() -> void:
	_load_plugin_icon()
	_update_log_color()
	
	# Change all RoxyThemableIcon color according to new theme
	var icons_reg := Engine.get_meta(PluginGlobals.ROXY_SQLITE_MANAGER_REGISTRY_NAME) as Dictionary[int, WeakRef]
	var icons_dead_keys: Array[int] = []
	for k in icons_reg:
		var icon = icons_reg[k].get_ref() as RoxyThemableIcon
		if icon:
			icon.generate_image()
		else:
			icons_dead_keys.append(k)
	for k in icons_dead_keys:
		icons_reg.erase(k)
	
func _load_plugin_icon() -> void:
	if !plugin_icon:
		plugin_icon = RoxyThemableIcon.new()
		plugin_icon.orig_image = load("res://addons/roxysqlitemanager/Icons/database.svg")
		plugin_icon.default_size = 16

func _update_log_color() -> void:
	Log.error_color = EditorInterface.get_editor_theme().get_color("error_color", "Editor").to_html(false)
	Log.warning_color = EditorInterface.get_editor_theme().get_color("warning_color", "Editor").to_html(false)
