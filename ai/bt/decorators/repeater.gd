class_name BTRepeater
extends BTDecorator

@export_range(0, 100, 1, "or_greater") var count_limit: int

func _init() -> void:
    cache_key = "Limiter#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    var count:int = blackboard._get_("count", 0, cache_key)
    super.tick(actor, blackboard)
    if (status & 0b11) == 1:
        blackboard._set_("count", count + 1, cache_key)
        count = blackboard._get_("count", cache_key)
        if count >= count_limit:
            status = 0b101
            return
    elif not is_standby():
        status = 0b110
    else:
        status = 0b100
        reset(blackboard)

func reset(blackboard:BlackBoard) -> void:
    blackboard.erase("count", cache_key)
