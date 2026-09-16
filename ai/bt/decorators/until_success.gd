class_name BTUntilSuccess
extends BTDecorator

func _init() -> void:
    cache_key = "UntilSuccess#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    status = branches[0]._tick(actor, blackboard)
    if (status & 0b11) == 1:
        status = 0b101
        return
    else:
        status = 0b110
