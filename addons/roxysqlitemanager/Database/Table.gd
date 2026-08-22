@tool

const Column = preload("res://addons/roxysqlitemanager/Database/Column.gd")

var _log = preload("res://addons/roxysqlitemanager/Tools/log.gd").ContextualLog.new("Table")

class Index:
	var name: String
	var columns: Array[Column]

var name: String
var columns: Array[Column]
var indexes: Array[Index]

var _ddl: String
var _sqlite: SQLite

func _init(sqlite: SQLite, table_name: String, db_name: String):
	self.name = table_name
	self._sqlite = sqlite
	
	if !sqlite.query('SELECT sql from sqlite_master WHERE type = "table" and name = "%s";' % table_name) or sqlite.query_result.size() < 1:
		_log.error("Cannot get SQL DDL for table %s in database %s" % [table_name, db_name])
		return
	
	# Format DDL string
	self._ddl = (sqlite.query_result[0]["sql"] as String).remove_chars("\n\r\t").replace("  ", " ").replace("  ", " ")
	var cols_start_idx := self._ddl.find("(")
	var cols_end_idx := self._ddl.rfind(")")
	var cols: Dictionary[String, String]
	
	for c in self._ddl.substr(cols_start_idx + 1, cols_end_idx - cols_start_idx - 1).split(",",false):
		var tmp = c.split(" ",false, 1)
		cols[tmp[0]] = tmp[1]
	
	if !sqlite.query("PRAGMA table_info(%s);" % table_name):
		_log.error("Cannot list columns from table %s in database %s" % [table_name, db_name])
		return
		
	for col_name in cols.keys():
		self.columns.append(Column.new(col_name, cols[col_name]))
