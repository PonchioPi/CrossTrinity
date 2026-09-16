class_name BTCooldown
extends BTDecorator

@export_range(0.0, 3600, 0.001, "or_greater") var countdown:float

func _init() -> void:
    cache_key = "Countdown#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:Blackboard) -> void:
    var time_limit:float = blackboard._get_("remaining_time", countdown, cache_key)
    if time_limit > 0.0:
        time_limit -= tree.get_delta()
        blackboard._set_("remaining_time", time_limit, cache_key)
        status = branches[0]._tick(actor, blackboard)
    else:
        status = 0b100
    return

func reset(blackboard:BlackBoard) -> void:
    blackboard.erase("remaining_time", cache_key)
