@tool
extends PanelContainer

const Table = preload("res://addons/roxysqlitemanager/Database/Table.gd")
const Column = preload("res://addons/roxysqlitemanager/Database/Column.gd")

signal save_changes(data: Array[Column])

const COL_TYPE = 1

const row_prefab: PackedScene = preload("res://addons/roxysqlitemanager/UI/Tabs/TableColumns/property_row.tscn")

@export var col_type_size := 200:
	get:
		return col_type_size
	set(val):
		col_type_size = val
		_update_col_size(COL_TYPE, col_type_size)
		
func _update_col_size(col: int, size: float):
	if self.is_node_ready():
		for node_row in $VBoxContainer.get_children():
			if node_row is HBoxContainer:
				var node_col = node_row.get_child(col)
				if node_col is Control:
					node_col.custom_minimum_size.x = size

func _ready() -> void:
	_update_col_size(COL_TYPE, col_type_size)

func assign_table(table: Table, database_name: String) -> void:
	for child in $VBoxContainer.get_children().filter(func(c): return c != $VBoxContainer/Headers and c != $VBoxContainer/Breadcrumb):
		child.queue_free()
	
	for row in table.columns:
		var node_row = row_prefab.instantiate()
		node_row.get_node("NameEdit").text = row.name
		node_row.get_node("TypeEdit").text = row.type
		$VBoxContainer.add_child(node_row)
		
	$VBoxContainer/Breadcrumb/Label.text = "[b]%s    >    %s[/b]" % [database_name.replace("[","[lb]"), table.name.replace("[","[lb]")]
		
	_update_col_size(COL_TYPE, col_type_size)
