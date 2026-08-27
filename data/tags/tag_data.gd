extends Resource
class_name TagData

@export var id: StringName
@export var display_name: String = ""
@export var category: StringName
# @export var parent_id: StringName
@export var requires: Array[StringName] = []
@export var forbids: Array[StringName] = []
@export var implies: Array[StringName] = [] ##By default, contains category and parent_id. 
