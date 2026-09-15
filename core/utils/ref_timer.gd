## An utility class in order to implement a non-node timer, just in case.

class_name RefTimer
extends RefCounted

signal timeout

## 1: enabled
## 2: one_shot
## 3: autostart
## 8: process mode -> 0: physics_process, 1: process
@export_flags("enabled","one_shot","autostart","process_mode") var conds:int =0b0

var time_ref:Node
var time:float = .0
var wait_time:float: set = set_wait_time
var index: int = -1: set = set_index

#region Setters

func set_wait_time(value:float) -> void:
    wait_time = value
    reset()

func set_index(value:int) -> void:
    index = value
#endregion

#region Getters

func is_stopped() -> bool:
    return (conds & 0b1) ^ 0b1 #!enabled

func is_oneshot() -> bool:
    return ((conds & 0b10) >> 1) & 0b1 #oneshot

func is_autostart() -> bool:
    return ((conds & 0b100) >> 2) & 0b1 #autostart

func get_process_mode() -> bool:
    return (conds >> 3) & 0b1 #process mode else physics_process mode
#endregion

#region Methods

func start() -> void:
    if is_stopped() and time < wait_time:
        reset()
    if is_stopped():
        conds = conds | 0b1

func stop() -> void:
    if !is_stopped():
        conds = conds ^ 0b1

func tick() -> void:
    if !is_stopped():
        time -= time_ref.get_process_delta_time() if get_process_mode() else time_ref.get_physics_process_delta_time()
        if wait_time >=0 and time <= 0:
            timeout.emit()
            if is_oneshot():
                stop()
            else:
                reset()

func _init(ref:Node, process:int= 1, _wait_time:float= -1, oneshot:int= 0, autostart:int = 0) -> void:
    time_ref = ref
    set_wait_time(_wait_time)
    set("conds", (oneshot<<1)+(autostart<<2)+(process<<3))
    if is_autostart():
        start()
