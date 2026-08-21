@tool

var name: String
var type: String
var length: int
var default_val: String
var nullable: bool
var primary_key: bool
var autoincrement: bool

func _init(col_name: String = "", infos: String = "") -> void:
	if !col_name.is_empty() and !infos.is_empty():
		self.name = col_name.remove_chars("\"`")
	
		# Type (always the second term)
		self.type = infos.get_slice(" ", 0).remove_chars("\"`")
		
		var def_start_idx = infos.find("(", infos.to_upper().find("DEFAULT")) # Compute before to avoid to get parenthesis of the default value
		# Length
		var len_start_idx = infos.find("(", infos.find(self.type))
		if len_start_idx >= 0 and (def_start_idx < 0 or len_start_idx < def_start_idx):
			var len_end_idx = infos.find(")", len_start_idx)
			self.length = int(infos.substr(len_start_idx + 1, len_end_idx - len_start_idx - 1).strip_edges())
			self.type = self.type.get_slice("(", 0)
		
		# Default
		if def_start_idx >= 0:
			var def_end_idx = infos.find(")", def_start_idx)
			self.default_val = infos.substr(def_start_idx + 1, def_end_idx - def_start_idx - 1).remove_chars("\"`").strip_edges().trim_prefix("'").trim_suffix("'")
			
		# (strip default val to avoid detect term in default text)
		var sanatized_infos = infos.replace(self.default_val, "").to_upper()

		self.primary_key = sanatized_infos.contains("PRIMARY KEY")
		self.nullable = !self.primary_key and !sanatized_infos.contains("NOT NULL")
		self.autoincrement = sanatized_infos.contains("AUTOINCREMENT")
