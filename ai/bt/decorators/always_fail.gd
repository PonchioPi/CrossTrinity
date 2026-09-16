class_name BTAlwaysFail
extends BTDecorator

func _init() -> void:
    cache_key = "AlwaysFail#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    status = branches[0]._tick(actor, blackboard)
    if not is_standby():
        return
    status = 0b100
