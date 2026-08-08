@tool
extends PanelContainer

@onready var db_tree : Tree = %DbTree

const PluginType:= preload("res://addons/roxysqlitemanager/roxysqlitemanager.gd")
var plugin_instance: PluginType

## ⚠️ Only used for debugging plugin
func _on_debug_button_pressed() -> void:
	if plugin_instance:
		plugin_instance.load_main_control()

func _ready() -> void:
	pass


func _on_theme_changed() -> void:
	if plugin_instance:
		plugin_instance._on_theme_change()
