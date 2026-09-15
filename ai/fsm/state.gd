## Inspired from gdquest's state script.
## Virtual base class for states. 
## Extends this class and override its methods to implement a state.
class_name State
extends Resource


## Emitted when the state finishes and wants to transition to another.
signal finished(next_state)

## Tells if the state is primary as in compulsory candidate to be assigned as state machine's initial state.
@export var primary_state:bool =false

var use_tween:bool =false

var handler:Node :
    set = set_handler

## The state machine is referenced as this state's handler to call its [member StateMachine.transition_to] method directly.
## That's one unorthodox detail of this state implementation, as it adds a dependency between the state machine objects.
## But it's been found to be most efficient in this case.
var state_machine:StateMachine

var animation:AnimationMixer

## The state machine handler will set it.
var tween:Tween

var timer:RefTimer

var blackboard:Blackboard

var  cache_key: String

func set_handler(value:Node) -> void:
    handler = value
    animation = blackboard._get_('animation', null, 'StateMachine@'%[state_machine.get_instance_id()])

#region Virtual methods:Called by the state machine upon changing the active state.

func enter(actor:Node) -> void:
    pass

func tick(actor:Node) -> void:
    pass

func handle_input(_event:InputEvent, actor:Node) -> void:
    pass

func update(_delta:float, actor:Node) -> void:
    pass

func physics_update(_delta:float, actor:Node) -> void:
    pass

func _on_animation_finished(current_animation:StringName) -> void:
    pass

func _on_animation_started(new_animation:StringName) -> void:
    pass

func _on_tween_finished() -> void:
    pass

func _on_timer_timeout() -> void:
    pass

func exit(actor:Node) -> void:
    pass

func finish(next_state:String) -> void:
    finished.emit(next_state)

## If there's a need to reset a RefTimer.
static func reset_timer(timer: RefTimer, wait_time:float) -> void:
    timer.set_wait_time(wait_time)
    timer.start()
