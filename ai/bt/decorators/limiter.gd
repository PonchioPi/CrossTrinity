class_name BTLimiter
extends BTDecorator

@export_range(0, 100, 1, "or_greater") var count_limit:int

func _init() -> void:
    cache_key = "Limiter#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    var count:int = blackboard._get_("count", 0, cache_key)
    if count < count_limit:
        super.tick(actor, blackboard)
        if is_standby():
            blackboard._set_("count", count + 1, cache_key)
        return
    else:
        status = 0b100
        return

func reset(blackboard:BlackBoard) -> void:
    blackboard.erase("count", cache_key)
        
