## An utility class to collect and transfer data across an architecture.

class_name BlackBoard
extends RefCounted

var blackboard:= {}

func _set_(key:Variant, value:Variant, blackboard_name:String ='default') -> void:
    if !blackboard.has(blackboard_name):
        blackboard[blackboard_name] = {}
    blackboard[blackboard_name][key] = value

func _get_(key:Variant, default_value = null, blackboard_name:String ='default') -> Variant:
    if has(key, blackboard_name):
        return blackboard[blackboard_name].get(key, default_value)
    return default_value

func has(key, blackboard_name:String ='default') -> bool:
    return blackboard.has(blackboard_name) and blackboard[blackboard_name].has(key) and blackboard[blackboard_name][key]!= null

func erase(key, blackboard_name:String ='default') -> void:
    if has(key, blackboard_name):
        blackboard[blackboard_name].erase(key)
