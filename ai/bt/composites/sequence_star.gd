## Inspired by BitBrain's BeehaveSequenceStar Beehave node
class_name BTSequence
extends BTComposite

var last_success:int = 0

func _init() -> void:
    cache_key = "Sequence_*#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    if is_random():
        if !random_children:
            random_children = branches.duplicate()
        random_children.shuffle()
        for index in random_children.size():
            if index < last_success:
                continue
            status = random_children[index]._tick(actor, blackboard)
            blackboard._set_("status", status, cache_key)
            if (status & 0b11) == 0:
                random_children = null
                last_success = 0
                return
            elif not is_standby():
                continue
            else:
                last_success += 1
        if last_success >= branches.size():
            last_success = 0
            status = 0b101
            return
        _reset()
        return
    else:
        for index in branches.size():
            if index < last_success:
                continue
            status = branches[index]._tick(actor, blackboard)
            blackboard._set_("status", status, cache_key)
            if (status & 0b11) == 0:
                last_success = 0
                return
            elif not is_standby():
                continue
            else:
                last_success += 1
        if last_success >= branches.size():
            last_success = 0
            status = 0b101
            return
        _reset()
        return
    status = 0b100
    return
