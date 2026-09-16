class_name BTCooldown
extends BTDecorator

@export_range(0.0, 3600, 0.001, "or_greater") var cooldown:float

func _init() -> void:
    cache_key = "Cooldown#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    var remaining:float = blackboard._get_("remaining_time", cooldown, cache_key)
    if remaining > 0.0:
        remaining -= tree.get_delta()
        blackboard._set_("remaining_time", remaining, cache_key)
        status = 0b100
    else:
        status = branches[0]._tick(actor, blackboard)
        if not is_standby():
            blackboard.erase("remaining_time", cache_key)
    return
