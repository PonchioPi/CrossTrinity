class_name BTUntilFail
extends BTDecorator

func _init() -> void:
    cache_key = "UntilSuccess#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    status = ((status & (~0b11)) | branches[0]._tick(actor, blackboard))
    if (status & 0b11) == 0:
        status = 0b101
        return
    else:
        status = 0b110
