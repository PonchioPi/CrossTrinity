class_name BTCondition
extends BTLeaf

func _init() -> void:
    cache_key = "Condition#%s:%s"%[self.get_instance_id, self.get_script().get_global_name()]
