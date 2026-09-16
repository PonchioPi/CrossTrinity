class_name BTSubTree
extends BTDecorator

signal behavior_subtree_changed
signal subtree_enabled

var blackboard:BlackBoard

func _init() -> void:
    cache_key = "SubTree#%s"%[self.get_instance_id()]

func set_branches(value:Array[BTTask]) -> void:
    branches = value
    if branches.size() != 1:
        push_error("Behavior Tree error: %s must have only one child (Tree %s)"%[cache_key, tree.cache_key])
        return
    if not branches[0] is BTRoot:
        push_error("Behavior Tree error: %s must have a BTRoot as its child (Tree %s)"%[cache_key, tree.cache_key]
        return
    branches[0].rank = rank + 1
    branches[0].set_tree(self)
    branches_changed.emit(self.get_instance_id(), branches)
    behavior_subtree_changed.emit()

func get_last_action() -> String:
    return blackboard._get_("last_action", "", cache_key)

func get_last_condition() -> String:
    return blacboard._get_("last_condition", "", cache_key)

func get_delta() -> float:
    return blackboard._get_("delta")

func init_tree(tree_node:Object) -> void:
    set_tree(tree_node)
    set_enabled(true)
    blackboard = tree_node.blackboard
    if branches.size() > 0:
        branches[0].init_tree(self)
    branches_changed.emit(self.get_instance_id(), branches)
    behavior_subtree_changed.emit()

func tick(actor:Node, blackboard:BlackBoard) -> void:
    status = branches[0]._tick(actor, blackboard)
