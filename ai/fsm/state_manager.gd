## A node to manage state machines in parallel.
class_name StateManager
extends Node

@export_enum("MANUAL:0", "IDLE:1", "PHYSICS_PROCESS:2") var fsm_process_mode: int = 1:
    set = set_fsm_process_mode
@export var state_machines:Dictionary[String, StateMachine] = {}

@onready var cache_key:String = "StateManager_%s"%[self.get_instance_id()]

var blackboard:BlackBoard = BlackBoard.new()

func set_fsm_process_mode(value:int) -> void:
    fsm_process_mode = value
    set_process(fsm_process_mode==1)
    set_physics_process(fsm_process_mode==2)

func _ready() -> void:
    set_fsm_process_mode(fsm_process_mode)
    blackboard._set_('manager', self)
    if state_machines:
        for machine in state_machines.values():
            machine.set_blackboard(blackboard)
            machine.set_actor(owner)
            machine.set_handler(self)
            machine.ready()

func _process(delta: float) -> void:
    blackboard._set_("delta", delta)
    for machine in state_machines.values():
        machine._process(delta)

func _physics_process(delta: float) -> void:
    blackboard._set_("delta", delta)
    for machine in state_machines.values():
        machine._physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
    for machine in state_machines.values():
        machine._unhandled_input(event)
