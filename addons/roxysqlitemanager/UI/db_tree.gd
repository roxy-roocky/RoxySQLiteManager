@tool
extends Tree

const Log = preload("res://addons/roxysqlitemanager/Tools/log.gd")

@onready var icon_database: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/database.svg"), 16)
@onready var icon_table: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/table.svg"), 16)
@onready var icon_folder: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/folder.svg"), 16)
@onready var icon_opened_folder: Texture2D = RoxyThemableIcon.new(preload("res://addons/roxysqlitemanager/Icons/folder-open.svg"), 16)

@onready var root: TreeItem = create_item()

class _DbInfos:
	var filename: String
	var dbname: String
	var sqlite: SQLite = null
	func _init(filename: String, create: bool = false) -> void:
			if !create and !FileAccess.file_exists(filename):
				Log.error("\"%s\" not exists.", filename)
			else:
				self.filename = filename
				self.dbname = filename.get_file().replace(filename.get_extension(), "").trim_suffix(".").replace_chars(" \t\n", ord("_"))
				
				self.sqlite = SQLite.new()
				self.sqlite.path = filename
				self.sqlite.open_db()
				
				if !sqlite.error_message.is_empty():
					Log.error("Error when opening \"%s\": %s", filename, sqlite.error_message)
					sqlite = null

var _registry: Dictionary[TreeItem, _DbInfos] = {}

func database_add(filename: String, create: bool = false) -> bool:
	var db := _DbInfos.new(filename, create)
	
	if !db.sqlite:
		return false
		
	var item := create_item(root)
	item.set_icon(0, icon_database)
	item.set_text(0, db.dbname)
	
	_registry[item] = db
	
	return true
