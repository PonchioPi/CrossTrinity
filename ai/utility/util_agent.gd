class_name UtilityAgent
extends Node

signal utility_agent_enabled(new_status)
signal transitioned(new_action_name)
signal selection_mode_changed(new_mode)

enum SelectionMode {
    MAX,
    ROULETTE
}

enum UtilProcessMode {
    PHYSICS_PROCESS,
    IDLE,
    MANUAL
}

@export var selection_mode: SelectionMode = SelectionMode.MAX:
    set = set_selection_mode
@export var util_process_mode: UtilProcessMode = UtilProcessMode.IDLE

@export var actions: Array[UtilityAction]
@export var enabled: bool = false:
    set = set_enabled
@export var actor: Node:
    set = set_actor

@onready var blackboard := Blackboard.new()
@onready var current_action := actions[0]
@onready var cache_key := "UtilityAgent#%s"% [get_instance_id()]

var scores: PackedFloat32Array
var score: float

func set_actor(value: Node) -> void:
    actor = value

func set_selection_mode(
