extends RefCounted
class_name ConflictResolver

static func _resolve(batch:ConflictBatch) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for target_id in batch.target_ids:
		var inputs := batch.get_inputs_for_target(target_id)
		results.append(_resolve_target(batch, target_id, inputs))
	return results

static func _resolve_target(
	batch: ConflictBatch, target_id: String,
	inputs: Array[Dictionary]) -> Dictionary:
	if inputs.is_empty():
		return {
			"source_id" : batch.source_id,
			"target_id" : target_id,
			"outcome" : "miss",
		}
	var best := inputs[0]
	for i in range(1, inputs.size()):
		if _better_candidature(inputs[i], best):
			best = inputs[i]
	return _build_result(batch, target_id, best)

static func _better_candidature(a: Dictionary, b: Dictionary) -> bool:
	var sa := _score(
		a.get("response_type", ConflictBatch.ResponseType.MISS),
		a.get("late", false))
	var sb := _score(
		b.get("response_type", ConflictBatch.ResponseType.MISS),
		b.get("late", false))
	if sa != sb:
		return sa > sb
	return a.get("sequence", 0) < b.get("sequence", 0)

static func _score(response_type: ConflictBatch.ResponseType, late: bool) -> int:
	return response_type - 200 if late else response_type

static func _build_result(
	batch: ConflictBatch, target_id: String,
	candidate: Dictionary) -> Dictionary:
		var response_type :ConflictBatch.ResponseType = candidate.get("response_type", ConflictBatch.ResponseType.MISS)
		return _compute_result(batch, target_id, candidate, response_type)

static func _compute_result(
	batch: ConflictBatch, target_id: String,
	candidate: Dictionary, response: ConflictBatch.ResponseType) -> Dictionary:
	var result := {
		"source_id" : batch.source_id,
		"target_id" : target_id,
		"outcome" : "miss",
	}
	match response:
		ConflictBatch.ResponseType.EXCELLENT:
			pass
		ConflictBatch.ResponseType.AMAZING:
			pass
		ConflictBatch.ResponseType.SUPER:
			pass
		ConflictBatch.ResponseType.GOOD:
			pass
		ConflictBatch.ResponseType.MISS:
			pass
		_:
			pass
	candidate.merge(result, true)
	return candidate
