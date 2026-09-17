## Inspired by BitBrain's BeehaveSelectorStar Beehave node
class_name BTSelector
extends BTComposite

var last_try:int = 0

func _init() -> void:
    cache_key = "Selector_*#%s"%[self.get_instance_id()]

func tick(actor:Node, blackboard:BlackBoard) -> void:
    if is_random():
        if !random_children:
            random_children = branches.duplicate()
        random_children.shuffle()
        for index in random_children.size():
            if index < last_try:
                continue
            status = (status & (~0b11)) | random_children[index]._tick(actor, blackboard)
            blackboard._set_("status", status, cache_key)
            if (status & 0b11) == 1:
                random_children = null
                last_try = 0
                return
            elif not is_standby():
                continue
            else:
                last_try += 1
        if last_try >= branches.size():
            last_try = 0
            status = (status & (~0b11)) | 0b100
            return
        _reset()
        return
    else:
        for index in branches.size():
            if index < last_try:
                continue
            status = (status & (~0b11)) | branches[index]._tick(actor, blackboard)
            blackboard._set_("status", status, cache_key)
            if (status & 0b11) == 1:
                last_try = 0
                return
            elif not is_standby():
                continue
            else:
                last_try += 1
        if last_try >= branches.size():
            last_try = 0
            status = (status & (~0b11)) | 0b100
            return
        _reset()
        return
    status =  (status & (~0b11)) | 0b100
    return
