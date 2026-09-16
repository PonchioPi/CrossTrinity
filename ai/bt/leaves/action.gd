class_name BTAction
extends BTLeaf

func _init() -> void:
    cache_key = "Action#%s:%s"%[self.get_instance_id, self.get_script().get_global_name()]
