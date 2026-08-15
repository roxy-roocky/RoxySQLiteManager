@tool
extends MenuBar

func _ready() -> void:
	var icon_max_size = floori(EditorInterface.get_editor_scale() * 16)
	for c in find_children("*","PopupMenu"):
		c.add_theme_constant_override("icon_max_width", icon_max_size)


func _on_theme_changed() -> void:
	for c in find_children("*","PopupMenu"):
		var pm = c as PopupMenu
		
