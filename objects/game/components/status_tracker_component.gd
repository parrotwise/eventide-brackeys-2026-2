class_name StatusTrackerComponent
extends Node


## All active status effects in combat_level
var active_statuses: Array[Status] = []


func start_tracking(status: Status) -> void:
	if status == null:
		return
	
	if status in active_statuses:
		return
	
	active_statuses.append(status)

func stop_tracking(status: Status) -> void:
	if status == null:
		return
	
	active_statuses.erase(status)

func get_active_statuses() -> Array[Status]:
	return active_statuses
