## Generic state machine.
## Initializes states annd delegates engine methods (_process, physics_process, _unhandled_input)
## to the active state.

## Emitted when transitioning to a new state.
signal transitioned(state_machine)

signal active_state_machine(state_machine, is_active)

## Path to the initial active state. We export it to be able to pick it in the inspector.
@export var initial_state:String

## A dictionary to contain every state child of the state machine.
@export var states:Dictionary[String, State]

@export_node_path("AnimationMixer") var animation_path: NodePath

var animation_player: AnimationMixer:
    set = set_animation

var actor: Node:
    set = set_actor

var handler: Node:
    set = set_handler

var previous_state:State = null

## A states array to obtain the reversed order in which states stack themselves.
var states_stack:= PackedStringArray()

## An array containing any non-primary state name
var secondary_states_map:= PackedStringArray()

## The current active state. At the start of the game, the state machine's initialization state we set.
var _state:State

var _active:bool =false:
    set = set_active

var blackboard:Blackboard :
    set = set_blackboard

func set_actor(value:Node) -> void:
    actor = value

func set_animation(value: AnimationMixer) -> void:
    animation_player = value
    if animation_player:
        animation_player.animation_finished.connect(self._on_animation_finished)
        animation_player.animation_started.connect(self._on_animation_started)

func set_handler(value:Node) -> void:
    handler = value

func set_blackboard(value:Blackboard) -> void:
    blackboard = value
    if states:
        for state in states.values():
            state.set('blackboard', blackboard)

func set_active(value:bool) -> void:
    _active = value
    active_state_machine.emit(get_instance_id(), value)
    if not _active:
        states_stack = [initial_state]
        _state = states[initial_state]
        previous_state = null

func ready() -> void:
    _state = states.get(initial_state, states.values().front())
    set_animation(actor.get_node(animation_path))
    blackboard._set_('actor', actor, 'StateMachine@%s'%[get_instance_id()])
    blackboard._set_('animation', animation_player, 'StateMachine@%s'%[get_instance_id()])
    for state in states.values():
        state.set('blackboard', blackboard)
        state.set('state_machine', self)
        state.set_handler(handler)
        state.finished.connect(self._transition_to)
        if !state.primary_state:
            secondary_states_map.append(states.find_key(state))
    _state_initialize(_state)

func _state_initialize(start_state:State) -> void:
    states_stack.push_back(states.find_key(start_state))
    set_active(true)
    _state.enter(actor)

#region NodeMethods: the state machine subscribes to node callbacks and delegates them to the state objects.

func _unhandled_input(event: InputEvent) -> void:
    if _active:
        _state.handle_input(event, actor)

func _process(delta:float) -> void:
    if _active:
        _state.update(delta, actor)

func _physics_process(delta:float) -> void:
    if _active:
        _state.physics_update(delta, actor)

func _on_animation_finished(current_animation: StringName) -> void:
    if _active:
        _state._on_animation_finished(current_animation)

func _on_animation_started(current_animation: StringName) -> void:
    if _active:
        _state._on_animation_started(new_animation)

#endregion

func _action_changed(manager:Node, active:bool) -> void:
    if manager == handler:
        set_active(active)

func _transition_to(target_state_name:String) -> void:
    if not _active:
        return
    previous_state = _state

    if target_state_name in secondary_states_map:
        states_stack.push_back(target_state_name)
    if not target_state_name in states.keys():
        if target_state_name == 'previous':
            target_state_name = states_stack[-2]
            states_stack.remove_at(-1)
        else:
            return
    _state.exit(actor)
    states_stack[-1] = target_state_name
    _state = states.get(target_state_name)
    emit_signal("transitioned", states_stack[-1])
    _state.enter(actor)
