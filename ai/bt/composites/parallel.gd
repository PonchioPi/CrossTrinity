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
    return (status & 0b10000) >> 4 == 1

func _init() -> void:
    cache_key = "Parallel#%s"%[self.get_instance_id()]

func init_tree(tree_node:Object) -> void:
    results.resize(branches.size())
    child_order = branches.duplicate()
    super.init_tree(tree_node)

func _reset() -> void:
    results.clear()
    results.resize(branches.size())
    if random:
        child_order = branches.duplicate()
    super._reset()

func tick(actor:Node, blackboard:BlackBoard) -> void:
    if is_random():
        child_order.shuffle()
    for index in branches.size():
        status = child_order[index]._tick(actor, blackboard)
        results[index] = status
        blackboard._set_("status", status, cache_key)
        if (status & 0b11) == 1:
            if is_selector():
                return
        elif not is_standby():
            continue
        else:
            if not is_selector():
                return
    if 0b110 in results or 0b111 in results:
        status = 0b110
        return
    if not is_selector():
        status = 0b101
        return
    else:
        status = 0b100
        return
