@tool
extends TabContainer

const Table = preload("res://addons/roxysqlitemanager/Database/Table.gd")
const Database = preload("res://addons/roxysqlitemanager/Database/Database.gd")

var icon_close: RoxyThemableIcon = preload("res://addons/roxysqlitemanager/RoxyIcons/close.tres")
var tab_table_columns_prefab: PackedScene = preload("res://addons/roxysqlitemanager/UI/Tabs/TableColumns/table_columns.tscn")

@onready var _log = preload("res://addons/roxysqlitemanager/Tools/log.gd").ContextualLog.new("TabManager")

var _table_columns_register: Dictionary[Table, Control] = {}

func _on_tab_button_pressed(tab_inx: int) -> void:
	var tab = self.get_tab_control(tab_inx)
	tab.queue_free()
	
	self._table_columns_register.erase(self._table_columns_register.find_key(tab))

func open_table_columns_tab(table: Table, db: Database) -> void:
	if !is_instance_valid(table):
		_log.error("Try to open tab for invalid tab")
		return
	
	if _table_columns_register.has(table):
		current_tab = self.get_tab_idx_from_control(self._table_columns_register[table])
	else: 
		var tab = tab_table_columns_prefab.instantiate()
		self._table_columns_register[table] = tab
		self.add_child(tab)
		tab.assign_table(table, db.dbname)
		
		var tab_idx = self.get_tab_idx_from_control(tab)
		self.set_tab_button_icon(tab_idx, icon_close)
		self.set_tab_title(tab_idx, "%s - Columns" % table.name)
		self.current_tab = tab_idx
	
func _on_db_tree_table_deleted(table: Table) -> void:
	if _table_columns_register.has(table):
		var tab = self._table_columns_register[table]
		tab.queue_free()
		self._table_columns_register.erase(table)

func _on_db_tree_database_exited(db: Database) -> void:
	for table in db.tables.values():
		_on_db_tree_table_deleted(table)

func _on_db_tree_database_refreshed(db: Database) -> void:
	var table_to_reopen: Dictionary[String, Control]
	for table in _table_columns_register.keys():
		table_to_reopen[table.name] = self._table_columns_register[table]
		self._table_columns_register.erase(table)
	
	for table in db.tables.values():
		if table_to_reopen.has(table.name):
			var tab = table_to_reopen[table.name]
			tab.assign_table(table, db.dbname)
			self._table_columns_register[table] = tab
