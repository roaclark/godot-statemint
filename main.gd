extends Node

func _ready():
	print('Starting state:', Store.get_state())
	Store.subscribe([], self, '_on_store_changed')
	Store.subscribe(['turn'], self, '_on_turn_changed')
	
	# These actions would typically be triggered reactively
	# e.g. on a button press
	print('\n-> dispatching UNITS_ADD_UNIT')
	Store.dispatch({
		'type': Reducer.ActionType.UNITS_ADD_UNIT,
		'id': '1',
		'unit': 'Unit 1',
	})
	print('\n-> dispatching UNITS_ADD_UNIT')
	Store.dispatch({
		'type': Reducer.ActionType.UNITS_ADD_UNIT,
		'id': '2',
		'unit': 'Unit 2',
	})
	print('\n-> dispatching UNITS_CLEAR_UNITS')
	Store.dispatch({
		'type': Reducer.ActionType.UNITS_CLEAR_UNITS,
	})
	print('\n-> dispatching TIMELINE_NEXT_TURN')
	Store.dispatch({
		'type': Reducer.ActionType.TIMELINE_NEXT_TURN,
	})

func _on_store_changed(state, old_state):
	print('\n~~~ Store update ~~~')
	print('old state:', old_state)
	print('new state:', state)
	print('full state:', Store.get_state())

func _on_turn_changed(state, old_state):
	print('\n~~~ Turn update ~~~')
	print('old state:', old_state)
	print('new state:', state)
	print('full state:', Store.get_state())
