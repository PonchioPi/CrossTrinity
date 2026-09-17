class_name AlwaysSucceed
extends BTDecorator

func _init() -> void:
    cache_key = "AlwaysSucceed#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    super.tick(actor, blackboard)
    if not is_standby():
        return
    status = 0b101
