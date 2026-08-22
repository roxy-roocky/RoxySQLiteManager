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

func _on_databases_menu_id_pressed(id: int) -> void:
	match id:
		0: # Open
			$OpenDatabaseFileDialog.popup()
		1: # Create
			$CreateDatabaseFileDialog.popup()

func _on_database_file_dialog_file_selected(path: String, create: bool) -> void:
	%DbTree.database_add(path, create)
