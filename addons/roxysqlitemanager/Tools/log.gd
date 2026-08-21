
const ROXY_LOG_PLUGINNAME = "Roxy SQLite Manager"

const _ERROR_FORMAT = "[b][color=red]%s[/color][/b]"
const _WARNING_FORMAT = "[color=orange]%s[/color]"

## INTERNAL - Format log global string and parameters
static func _format_log(context: String, format: String, params: Array) -> String:
		return ("[%s%s] %s: %s" % [ROXY_LOG_PLUGINNAME, 
			(" > %s" % context if !context.is_empty() else "") , 
			Time.get_time_string_from_system(), 
			(format % params) if !params.is_empty() else format]
		).replace("[","[lb]")

## Log an global information
static func info(format: String, ...params: Array):
	print_rich(_format_log("",format, params))

## Log an global error in red and bold
static func error(format: String, ...params: Array):
	print_rich(_ERROR_FORMAT % _format_log("",format, params))
	
## Log a global warning in yellow
static func warning(format: String, ...params: Array):
	print_rich(_WARNING_FORMAT % _format_log("",format, params))
	

const Log = preload("res://addons/roxysqlitemanager/Tools/log.gd")
class ContextualLog:
	var _context: String = ""

	func _init(context: String):
		self._context = context
		
	## Log an global information
	func info(format: String, ...params: Array):
		print_rich(Log._format_log(_context,format, params))

	## Log an error in red and bold
	func error(format: String, ...params: Array):
		print_rich(_ERROR_FORMAT % Log._format_log(_context,format, params))
		
	## Log a warning in yellow
	func warning(format: String, ...params: Array):
		print_rich(_WARNING_FORMAT % Log._format_log(_context,format, params))
	
