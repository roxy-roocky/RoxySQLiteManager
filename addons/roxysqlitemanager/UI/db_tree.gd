@tool
extends Tree

signal database_exited(db: Database)
signal database_refreshed(db: Database)
signal table_deleted(table: Table)

const BTN_DB_CLOSE = 0
const BTN_DB_REFRESH = 1
const BTN_TABLE_CREATE = 100
const BTN_TABLE_DELETE = 101
const BTN_TABLE_EDIT = 102

enum _TreeitemTypes {
	DATABASE,
	FOLDER_TABLES,
	TABLE
}

const Database = preload("res://addons/roxysqlitemanager/Database/Database.gd")
const Table = preload("res://addons/roxysqlitemanager/Database/Table.gd")

func _check_treeitem_type(item: TreeItem, action: String, type: _TreeitemTypes, silent: bool = false) -> bool:
	if !is_instance_valid(item):
		if !silent:
			_log.error("Attempt to %s from an invalid treeitem" % action)
		return false
		
	if item.get_meta("type") != type:
		if !silent:
			_log.error("Attempt to %s from a non-%s treeitem" % [action, _TreeitemTypes.find_key(type).to_lower()])
		return false
		
	return true

# Instantiate contextual log for DbTree
@onready var _log = preload("res://addons/roxysqlitemanager/Tools/log.gd").ContextualLog.new("DbTree")

@onready var icon_database: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/database.svg"), 16)
@onready var icon_table: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/table.svg"), 16)
@onready var icon_folder: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/folder.svg"), 16)
@onready var icon_opened_folder: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/folder-open.svg"), 16)
@onready var icon_close: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/xmark.svg"), 16)
@onready var icon_add: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/add.svg"), 16)
@onready var icon_delete: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/trash-can.svg"), 16)
@onready var icon_edit: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/edit.svg"), 16)
@onready var icon_refresh: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/refresh.svg"), 16)

@onready var root: TreeItem = create_item()

const TableColumnsScript = preload("res://addons/roxysqlitemanager/UI/Tabs/TableColumns/table_columns.gd")
const table_columns_prefab: PackedScene = preload("res://addons/roxysqlitemanager/UI/Tabs/TableColumns/table_columns.tscn")

func _ready() -> void:
	_adapt_theme()
	set_column_expand(0, true)
	set_column_expand(1, false)
	
func _exit_tree() -> void:
	# Explicitly close all databases
	for item_db in _registry.keys():
		database_close(item_db)

var _recursive_lock := false
func _adapt_theme() -> void:
	if !_recursive_lock:
		_recursive_lock = true
		add_theme_stylebox_override("panel", get_theme_stylebox("normal", &"CodeEdit"))
		_recursive_lock = false

var _registry: Dictionary[TreeItem, Database] = {}



func database_add(filename: String, create: bool = false) -> bool:
	var db := Database.new(_log, filename, create)

	if !db.sqlite:
		return false
		
	var item := create_item(root)
	item.set_meta("type", _TreeitemTypes.DATABASE)
	item.set_icon(0, icon_database)
	item.set_text(0, db.dbname)
	
	item.add_button(1, icon_refresh, BTN_DB_REFRESH, false, "Refresh database informations")
	item.add_button(1, icon_close, BTN_DB_CLOSE, false, "Close database")
	
	_registry[item] = db
	
	_log.info("Register database %s" % db.dbname)
	
	database_list_tables(item)
	
	return true

func database_refresh(item: TreeItem) -> bool:
	if !_check_treeitem_type(item, "refresh database", _TreeitemTypes.DATABASE):
		return false
		
	if !_registry.has(item):
		_log.error("Attempt to remove not owned treeitem")
		return false
	
	var db: Database = _registry[item]
	db.refresh_structure()
	self.database_list_tables(item)
	
	self.database_refreshed.emit(db)
	
	return true

func database_close(item: TreeItem) -> bool:
	if !_check_treeitem_type(item, "close database", _TreeitemTypes.DATABASE):
		return false
		
	if !_registry.has(item):
		_log.error("Attempt to remove not owned treeitem")
		return false
	
	var db = _registry[item]
	
	self.database_exited.emit(db)
	
	db.sqlite.close_db()
	_registry.erase(item)
	
	root.remove_child(item)
	_clear_treeitem(item)
	item.free()
	
	_log.info("Close database %s" % db.dbname)
	
	return true

func database_list_tables(db_item: TreeItem) -> void:
	if !_check_treeitem_type(db_item, "list tables", _TreeitemTypes.DATABASE):
		return
		
	var db = _registry[db_item]
	# Empty the database tree item
	_clear_treeitem(db_item)
	
	var tables_item = create_item(db_item, 0)
	tables_item.set_meta("type", _TreeitemTypes.FOLDER_TABLES)
	tables_item.set_icon(0, icon_folder)
	tables_item.set_text(0, "Tables (%d)" % db.tables.size())
	tables_item.add_button(1, icon_add, BTN_TABLE_CREATE, false, "Add table to database")
	tables_item.set_collapsed_recursive(true)
	
	for table in db.tables.values():
		var t_item = create_item(tables_item)
		t_item.set_meta("type", _TreeitemTypes.TABLE)
		
		# I prefer store Weakref in an Object that can be subject to data leak due to forgotten free() call
		t_item.set_meta("ref", weakref(table))
		t_item.set_meta("db_ref", weakref(db))
		
		t_item.set_icon(0, icon_table)
		t_item.set_text(0, table.name)
		t_item.add_button(1, icon_edit, BTN_TABLE_EDIT, false, "Edit table column and indexes")
		t_item.add_button(1, icon_delete, BTN_TABLE_DELETE, false, "Delete table")
		
	_log.info("Read %d tables in database %s" % [db.tables.size(), db.dbname])
	
	
	
func _clear_treeitem(item: TreeItem):
	for child in item.get_children():
		_clear_treeitem(child)
		item.remove_child(child)
		child.free()

func table_open_columns_tab(item: TreeItem):
	if ! _check_treeitem_type(item, "open table columns tab", _TreeitemTypes.TABLE):
		return
	
	var table_ref = item.get_meta("ref") as WeakRef
	var db_ref = item.get_meta("db_ref") as WeakRef
	if table_ref and db_ref:
		%TabManager.open_table_columns_tab(table_ref.get_ref(), db_ref.get_ref())
	else:
		_log.error("No Table in metadata of TreeItem")

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		match id:
			BTN_DB_CLOSE:
				database_close(item)
			BTN_DB_REFRESH:
				database_refresh(item)
			BTN_TABLE_EDIT:
				table_open_columns_tab(item)

func _on_item_collapsed(item: TreeItem) -> void:
	if _check_treeitem_type(item, "", _TreeitemTypes.FOLDER_TABLES, true):
		item.set_icon(0, icon_folder if item.collapsed else icon_opened_folder)

func _on_item_activated() -> void:
	var item: TreeItem = self.get_selected()
	var type: _TreeitemTypes = item.get_meta("type")
	
	match type:
		_TreeitemTypes.TABLE:
			self.table_open_columns_tab(item)
		_TreeitemTypes.FOLDER_TABLES, _TreeitemTypes.DATABASE:
			item.collapsed = !item.collapsed
	
