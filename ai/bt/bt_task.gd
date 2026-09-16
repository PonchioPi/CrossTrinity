## Virtual base class for every behavior tree task. 
class_name BTTask
extends Resource

signal enabled(value)
signal branches_changed(root_id, new_branches)

var status:int = 0b10

@export var branches: Array[BTTask]:
    set = set_branches,
    get = get_branches

var cache_key: String
var tree: Object
var rank: int = 0

#region Setters

func set_enabled(value:bool) -> void:
    status = (int(value) << 2) | (status & 0b11)
    if !is_enabled:
        _reset()
    enabled.emit(is_enabled())

func set_branches(value:Array[BTTask]) -> void:
    branches = value
    for branch in branches:
        branch.rank = rank + 1
        branch.set_tree(tree)
    branches_changed.emit(self.get_instance_id(), branches)

func set_tree(value: Object) -> void:
    tree = value

#endregion

#region Getters

func is_enabled() -> bool:
    return status >> 2

func is_standby() -> bool:
    return ((status & 0b10) >> 1) ^ 0b1

func get_branches() -> Array[BTTask]:
    return branches

#endregion

#region Methods

func init_tree(tree_node: Object) -> void:
    set_tree(tree_node)
    set_enabled(true)
    if branches.size() > 0:
        for branch in branches:
            branch.init_tree(tree)
    branches_changed.emit(self.get_instance_id(), branches)

func _reset() -> void:
    status = (status & 0b101) | 0b10

func _tick(actor:Node, blackboard:Blackboard) -> int:
    if is_enabled():
        if is_standby():
            _reset()
        blackboard._set_("status", status, cache_key)
        tick(actor, blackboard)
        blackboard._set_("status", status, cache_key)
        return status
    return 0

func tick(actor:Node, blackboard:BlackBoard) -> void:
    pass

#endregion
  
