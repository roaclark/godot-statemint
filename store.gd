extends Node

# Redux-like store
# Inspired by https://github.com/glumpyfish/godot_redux

var _state: Dictionary = Reducer.initial_state()
var _subscribers = []

func subscribe(path: Array, target, method: String):
	_subscribers.append({
		'path': path,
		'func': funcref(target, method),
	})

func _update_field(obj, path: Array, new_val):
	if path.size() < 1:
		printerr("empty path passed to store._update_field")
		return obj
	var field = path[0]
	if typeof(obj) == TYPE_DICTIONARY:
		if path.size() > 1:
			if not field in obj:
				obj[field] = {}
			obj[field] = _update_field(obj[field], path.slice(1, path.size()-1), new_val)
		else:
			if new_val == null:
				obj.erase(field)
			else:
				obj[field] = new_val
	else:
		printerr("store._update_field path must only index into dictionary values", typeof(obj), path)
	return obj

func _is_affected(subscriber_path: Array, update_path: Array) -> bool:
	for i in range(min(subscriber_path.size(), update_path.size())):
		if subscriber_path[i] != update_path[i]:
			return false
	return true

func _get_value_at_path(path: Array, obj):
	var node = obj
	for step in path:
		if not step in node:
			return null
		node = node[step]
	return node

func _notify_subscribers(path: Array, new_state, old_state):
	for sub in _subscribers:
		var sub_path = sub['path']
		if _is_affected(sub_path, path):
			sub['func'].call_func(
				_get_value_at_path(sub_path, new_state),
				_get_value_at_path(sub_path, old_state)
			)

func dispatch(action):
	var reducer_result = Reducer.reduce(_state, action)
	if reducer_result != null:
		var old_state = _state
		_state = _state.duplicate(true)
		var path = reducer_result['path']
		var new_val = reducer_result['new_value']
		_update_field(_state, path, new_val)
		_notify_subscribers(path, _state, old_state)

func get_state():
	return _state
