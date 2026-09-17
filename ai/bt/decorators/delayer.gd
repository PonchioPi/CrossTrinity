class_name BTDelayer
extends BTDecorator

@export_range(0.0, 3600, 0.001, "or_greater") var delay:float

func _init() -> void:
    cache_key = "Delayer#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    var remaining:float = blackboard._get_("remaining_time", 0.0, cache_key)
    if remaining < delay:
        remaining += tree.get_delta()
        blackboard._set_("remaining_time", remaining, cache_key)
        status = ((status & (~0b11)) | 0b110)
    else:
        super.tick(actor, blackboard)
        if is_standby():
            blackboard.erase("remaining_time", cache_key)
    return
