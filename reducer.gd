extends Node

enum ActionType {
	UNITS_ADD_UNIT,
	UNITS_CLEAR_UNITS,
	TIMELINE_NEXT_TURN,
}

func initial_state() -> Dictionary:
	return {
		'units': {},
		'turn': 1,
	}

# Returns a path and a new value for the state. This will trigger a
#   state update and dispatches to any subscribers who listen for the
#   path or one of its ancestors or descendents.
# Returning null will have no effect on the state or subscribers.
# Setting the new_value to null will cause the state value at path to
#   be deleted.
# The path must have at least one entry.
# The path can only navigate through dictionary entries. You cannot
#   index into an array or object in the state.
# If the full path does not exist in the state, empty dictionaries
#   will be created along the path.
func reduce(state, action):
	match action['type']:
		ActionType.UNITS_CLEAR_UNITS:
			return {
				'path': ['units'],
				'new_value': {},
			}
		ActionType.UNITS_ADD_UNIT:
			return {
				'path': ['units', action['id']],
				'new_value': action['unit'],
			}
		ActionType.TIMELINE_NEXT_TURN:
			return {
				'path': ['turn'],
				'new_value': state['turn'] + 1,
			}
		_:
			return null
