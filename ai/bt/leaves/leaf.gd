class_name BTLeaf
extends BTTask

func set_branches(value:Array) -> void:
    branches = value
    if branches.size() != 0:
        push_error("Behavior Tree error: %s must not have any child (%s)"%[cache_key, tree.cache_key])
        return
    branches_changed.emit(self.get_instance_id(), branches)
