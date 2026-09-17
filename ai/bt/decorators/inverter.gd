class_name BTInverter
extends BTDecorator

func _init() -> void:
    cache_key = "Inverter#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    super.tick(actor, blackboard)
    if not is_standby():
        return
    else:
        status = (status ^ 0b1)
