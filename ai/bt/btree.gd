class_name BTree
extends Node

signal behavior_tree_changed
signal tree_enabled*

@export_node_path("Node", "Node2D") var actor_path:= NodePath():
    set = set_actor
@export_enum("MANUAL:0", "IDLE:1", "PHYSICS_PROCESS:2") var bt_process_mode:int =1:
    set = set_bt_process_mode
@export var enabled:= false:
    set = set_enabled,
    get = is_enabled
@export var root: BTRoot:
    set = set_root

@onready var blackboard:BlackBoard = BlackBoard.new()
@onready var cache_key:String = "Tree#%s: Node#%s"%[self.name, self.get_instance_id()]

var actor: Node

var rank:int = 0

#region Setters

func set_actor(value:NodePath) -> void:
    actor_path = value
    actor = get_node(actor_path)

func set_bt_process_mode(value:int) -> void:
    bt_process_mode = value
    set_process(bt_process_mode==1)
    set_physics_process(bt_process_mode==2)

func set_enabled(value:bool) -> void:
    enabled = value
    if enabled:
        set_bt_process_mode(bt_process_mode)
    else:
        set_process(enabled)
        set_physics_process(enabled)
    blackboard._set_("status", (int(value) << 2), cache_key)
    tree_enabled.emit(enabled)

func set_root(value:BTRoot) -> void:
    root = value
    root.init_tree(self)

#endregion

#region Getters
func is_enabled() -> bool:
    return enabled

func get_last_action() -> String:
    return blackboard._get_("last_action")

func get_last_condition() -> String:
    return blackboard._get_("last_condition")

func get_delta() -> float:
    return blackboard._get_("delta")

#endregion

#region Methods
func _process(delta:float) -> void:
    tick(delta)

func _physics_process(delta:float) -> void:
    tick(delta)

func tick(_delta:float) -> void:
    if is_enabled:
        blackboard._set_("delta", _delta)
        blackboard._set_("status, 0b110, cache_key)
        var status: int = self.root._tick(actor, blackboard)
        blackboard._set_("status", status, cache_key)

#endregion
