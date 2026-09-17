class_name BTParallel
extends BTComposite

@export var selector_policy:bool =false:
    set = set_policy

var results:= PackedByteArray()
var child_order:Array[BTTask]

func set_policy(value:bool) -> void:
    selector_policy = value
    status = ((int(value) << 4) | status & 0b1111)

func is_selector() -> bool:
    return (status >> 4) == 1

func _init() -> void:
    cache_key = "Parallel#%s"%[self.get_instance_id()]

func init_tree(tree_node:Object) -> void:
    results.resize(branches.size())
    for i in range(branches.size()):
        child_order.append(i)
    super.init_tree(tree_node)

func _reset() -> void:
    results.clear()
    results.resize(branches.size())
    if random:
        child_order = branches
    super._reset()

func tick(actor:Node, blackboard:BlackBoard) -> void:
    
