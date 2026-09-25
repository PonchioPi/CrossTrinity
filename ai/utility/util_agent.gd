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

@export var actions: Array[UtilityAction]:
    set = set_actions
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

func set_actions(value: Array[UtilityAction]) -> void:
    actions = value
    scores.resize(actions.size())

func set_selection_mode(value: SelectionMode) -> void:
    selection_mode = value
    selection_mode_changed.emit(selection_mode)

func set_util_process_mode(value: UtilProcessMode) -> void:
    util_process_mode = value
    set_physics_process(value == UtilProcessMode.PHYSICS_PROCESS)
    set_process(value == UtilProcessMode.IDLE)

func set_enabled(value: bool) -> void:
    enabled = value
    utility_agent_enabled.emit(value)
    if enabled:
        initialize()
    else:
        reset()

func is_enabled() -> bool:
    return enabled

func _process(delta: float) -> void:
    if is_enabled():
        _tick(delta)

func _physics_process(delta: float) -> void:
    if is_enabled():
        _tick(delta)

func _tick(_delta: float) -> void:
    blackboard._set_("next_action", evaluate_actions(), cache_key)
    current_action.tick(actor, blackboard)

func gather_scores() -> void:
    for i in range(actions.size()):
        scores[i] = actions[i].evaluate_score()

func evaluate_actions() -> UtilityAction:
    gather_scores()
    match selection_mode:
        SelectionMode.MAX:
            score = max(scores)
        SelectionMode.ROULETTE:
            var random_scores := choose_best_scores(scores)
            random_scores.shuffle()
            score = random_scores[
                randi_range(0, random_scores.size()-1)
            ]
    return self.actions[scores.find(score)]

func choose_best_scores(array: PackedFloat32Array) -> Array[float]:
    array.sort()
    var limit := array.size() >> 1
    var new_array := Array(array.slice(0, limit))
    return new_array

func transition_to() -> void:
    blackboard._set_("previous_action", current_action, cache_key)
    current_action.finish()
    current_action = blackboard._get_("next_action", actions[0], cache_key)
    blackboard._set_("current_action", current_action, cache_key)
    transitioned.emit(current_action.name)
    current_action.act()

func initialize() -> void:
    for action in actions:
        action.action_finished.connect(transition_to)
    blackboard._set_("current_action", current_action, cache_key)
    current_action.act()

func reset() -> void:
    current_action = actions[0]
    if blackboard._get_("current_action", actions[0], cache_key) != current_action:
       blackboard._set_("current_action", current_action, cache_key) 
    current_action.act()
    
