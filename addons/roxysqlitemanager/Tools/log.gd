
const ROXY_LOG_PLUGINNAME = "Roxy SQLite Manager"
	
## INTERNAL - Format log global string and parameters
static func _format_log(format: String, params: Array) -> String:
	if params.is_empty():
		return format
	else:
		return ("[%s] %s: %s" % [ROXY_LOG_PLUGINNAME, Time.get_time_string_from_system(), format % params]).replace("[","[lb]")

## Log an information
static func info(format: String, ...params: Array):
	print_rich(_format_log(format, params))

## Log an error in red and bold
static func error(format: String, ...params: Array):
	print_rich("[b][color=red]%s[/color][/b]" % _format_log(format, params))
	
## Log a warning in yellow
static func warning(format: String, ...params: Array):
	print_rich("[color=orange]%s[/color]" % _format_log(format, params))
