@tool
extends Tree

# Instantiate contextual log for DbTree
@onready var _log = preload("res://addons/roxysqlitemanager/Tools/log.gd").ContextualLog.new("DbTree")

@onready var icon_database: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/database.svg"), 16)
@onready var icon_table: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/table.svg"), 16)
@onready var icon_folder: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/folder.svg"), 16)
@onready var icon_opened_folder: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/folder-open.svg"), 16)
@onready var icon_close: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/xmark.svg"), 16)

@onready var root: TreeItem = create_item()

class _DbInfos:
	var filename: String
	var dbname: String
	var sqlite: SQLite = null
	func _init(log, filename: String, create: bool = false) -> void:
			if !create and !FileAccess.file_exists(filename):
				log.error("\"%s\" not exists.", filename)
			else:
				self.filename = filename
				self.dbname = filename.get_file().replace(filename.get_extension(), "").trim_suffix(".").replace_chars(" \t\n", ord("_"))
				
				self.sqlite = SQLite.new()
				self.sqlite.path = filename
				self.sqlite.open_db()
				
				if !sqlite.error_message.is_empty():
					log.error("Error when opening \"%s\": %s", filename, sqlite.error_message)
					sqlite = null

func _ready() -> void:
	_adapt_theme()
	set_column_expand(0, true)
	set_column_expand(1, false)

var _recursive_lock := false
func _adapt_theme() -> void:
	if !_recursive_lock:
		_recursive_lock = true
		add_theme_stylebox_override("panel", get_theme_stylebox("normal", &"CodeEdit"))
		_recursive_lock = false

var _registry: Dictionary[TreeItem, _DbInfos] = {}

func database_add(filename: String, create: bool = false) -> bool:
	var db := _DbInfos.new(_log, filename, create)
	
	if !db.sqlite:
		return false
		
	var item := create_item(root)
	item.set_icon(0, icon_database)
	item.set_text(0, db.dbname)
	
	item.add_button(1, icon_close, 0, false, "Close database")
	
	_registry[item] = db
	
	_log.info("Register database %s" % db.dbname)
	
	return true

func database_close(item: TreeItem) -> bool:
	if !is_instance_valid(item):
		_log.error("Attempt to remove invalid treeitem")
		return false
		
	if !_registry.has(item):
		_log.error("Attempt to remove not owned treeitem")
		return false
	
	var db = _registry[item]
	db.sqlite.close_db()
	_registry.erase(item)
	
	root.remove_child(item)
	
	_log.info("Close database %s" % db.dbname)
	
	return true

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	if column == 1 and id == 0 and mouse_button_index == MOUSE_BUTTON_LEFT:
		database_close(item)
