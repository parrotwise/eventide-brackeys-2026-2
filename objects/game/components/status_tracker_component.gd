class_name StatusTrackerComponent
extends Node


## All active status effects in combat_level
var _active_statuses: Array[Status] = []
var active_statuses: Array[Status]:
	get: return _active_statuses


func track(status: Status) -> void:
	if status == null:
		return
	
	if status in _active_statuses:
		return
	
	_active_statuses.append(status)


func untrack(status: Status) -> void:
	if status == null:
		return
	
	_active_statuses.erase(status)
