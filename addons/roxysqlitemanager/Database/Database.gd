@tool

const Table = preload("res://addons/roxysqlitemanager/Database/Table.gd")

var filename: String
var dbname: String
var sqlite: SQLite = null
var tables: Dictionary[StringName, Table]

var _log = preload("res://addons/roxysqlitemanager/Tools/log.gd").ContextualLog.new("Database")

func _init(log, filename: String, create: bool = false) -> void:
	if !create and !FileAccess.file_exists(filename):
		log.error("\"%s\" not exists.", filename)
	else:
		self.filename = filename
		self.dbname = self.filename.get_file().replace(filename.get_extension(), "").trim_suffix(".").replace_chars(" \t\n", ord("_"))
		
		self.sqlite = SQLite.new()
		self.sqlite.path = self.filename
		self.sqlite.open_db()
		
		if !sqlite.error_message.is_empty():
			log.error("Error when opening \"%s\": %s", self.filename, self.sqlite.error_message)
			self.sqlite = null
			
		self.refresh_structure()
					
				
func refresh_structure():		
	if !self.sqlite.query("
		SELECT name 
		FROM sqlite_master 
		WHERE type = 'table' and name not like 'sqlite_%'
	"):
		_log.error("Cannot list tables from %s" % dbname)
	else:
		self.tables.clear()
		for row in sqlite.query_result:
			self.tables[row["name"]] = Table.new(self.sqlite, row["name"], self.dbname)

func fetch_tables_list_str() -> Array[StringName]:
	return self.tables.keys()

func fetch_columns_list(table: String):
	pass
