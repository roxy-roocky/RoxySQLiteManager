extends Resource

var filename: String
var dbname: String
var sqlite: SQLite = null

var _log = preload("res://addons/roxysqlitemanager/Tools/log.gd").ContextualLog.new("Database")

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

func fetch_tables_list() -> Array[String]:
	if !sqlite.query("
		SELECT name 
		FROM sqlite_master 
		WHERE type = 'table' and name not like 'sqlite_%'
	"):
		_log.error("Cannot list tables from %s" % dbname)
		return []
	
	return Array(sqlite.query_result.map(func(row: Dictionary): return row["name"]), TYPE_STRING, "", null)
