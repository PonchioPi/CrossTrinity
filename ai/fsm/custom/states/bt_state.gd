## A custom state to run a behavior tree within a state machine.
class_name StateBT
extends State

signal behavior_tree_changed
signal tree_enabled

@export var root:BTRoot :
    set = set_root

var rank: int = 0

func _init() -> void:
    primary_state = true
    cache_key = "FSTree_%s"%[self.get_instance_id()]

func set_root(value:BTRoot) -> void:
    root = value

func enter(actor:Node) -> void:
    root.init_tree(self)

func update(_delta:float, actor:Node) -> void:
    tick(actor)

func physics_update(_delta:float, actor:Node) -> void:
    tick(actor)

func tick(actor:Node) -> void:
    blackboard._set_("status", 0b110, cache_key)
    var status:int = self.root._tick(actor, blackboard)
    blackboard._set_("status", status, cache_key)
