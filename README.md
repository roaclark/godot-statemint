# Godot Statemint

Statemint is a centralized state management tool for [Godot](https://godotengine.org/) applications. It operates similarly to [Redux](https://redux.js.org/) in that the user specifies a reducer function to modify state in response to dispatched actions. The key difference for Statemint is that it allows reducers and subscribers to specify a narrow slice of the state that they intend to interact with. This limits the number of updates that a subscriber is notified about, thereby simplifying logic and improving performance.

Statemint was also inspired by [Redux for Godot](https://github.com/glumpyfish/godot_redux).

### Why use Statemint instead of Godot signals?

Statemint and signals are both tools used to decouple parts of your application. Signals accomplish this by allowing nodes to connect and listen for  messages about relevant topics. Statemint uses a centralized store where nodes subscribe to parts of the state rather than to signals.

While signals are useful for decoupling a large number of indepedent nodes, their decentralized nature makes it hard to reason about your entire state at once. A single node may need to connect to many different signals to ensure that it can keep its own state up to date, and in more complex systems it is easy to miss a signal connection that should update the node's state or to forget to fire a signal to trigger an update in all cases.

Statemint reduces this complexity by having both dispatchers and subscribers work with a single centralized store. Subscibers only need to specify what state they are interested in rather than knowing all of the different ways that state could be modified. Similarly, dispatchers only need to define how they want the state to change rather than being aware of all of the notifications that need to be fired about that change.

Statemint works best in situations where there is complex, interconnected global state and where there are several actions and subscribers that are interested in the same or overlapping bits of state.

## Usage
1. Save `reducer.gd` and `store.gd` and add them to "Project > Project Settings > AutoLoad" as `Reducer` and `Store`. Ensure that "Enable" is checked for both and that `Reducer` comes before `Store`.
1. Replace the logic in `reducer.gd` with your own state management. See the API docs for `Reducer` for details.
1. Register store subscribers for your responsive nodes. This usually happens in `_ready()`. See the notes about subscribers below for details and see `main.gd` for examples.
1. Dispatch actions to the store. This is usually based on user interactions such as button presses. See `main.gd` for examples.

## Notes

### State
Your state should be a dictionary, optionally with additional nested dictionaries inside. While it can have non-dictionary entries such as arrays or objects, Statemint treats these as leaf values and does not support subscribing to or updating only part of an object or array in the store.

### Subscribers
Subscribers specify a narrow part of the state they want to subscribe to at registration time. This is represented by a path through the state as an array of dictionary keys. A subscriber will be called if the part of the state they specify or any of its ancestors or any of its desendents are modified by the reducer. For example, a subscriber may provide the path `["game_state", "turn_data", "active_unit"]`. That subscriber will be notified if the reducer updates `["game_state", "turn_data", "active_unit", "hp"]` or `["game_state", "turn_data"]`. The subscriber will *not* be notified if the reducer updates `["game_state", "turn_data", "turn_count"]`.

If a subscriber provides an empty path (`[]`) then it will be called any time the state is updated.

The method provided on registration will be called with the new and old state slice at the specified path. For example, using the path `["game_state", "turn_data", "active_unit"]` will mean that the subscriber will receive the active unit and the previous active unit. If needed, the subscriber can use `store.get_state()` to access the full state beyond what it subscribed to.

### Reducer
The Reducer receives dispatched actions and updates the store accordingly. Similar to the subscribers, the reducer uses a path array to specify what it intends to update. If the reducer is modifying multiple parts of the state, it should return the lowest shared ancestor for those fields. For example, the reducer may respond to a `TURN_ENDED` action by changing both `store.game_state.turn_data.active_unit` and `store.game_state.turn_data.turn_count`. It would return `["game_state", "turn_data"]` as the shared ancestor so that all relevant subscribers can be notified from the store.

**Note**: The reducer should never modify the passed in state directly. It should always return a new object value to be used by the store.

## API

### Store
The global state container for your application. Nodes should interact with the state via this object.

#### Store.subscribe(path, target, method)
Adds a subscriber to the store that will be called when the relevant state is updated.

Parameter | Type | Description
--- | --- | ---
`path` | Array | The path to the state data that the subscriber should respond to, defined as an array of dictionary keys. See the notes on subscribers for more detail and examples.
`target` | Object | The node that will respond to updates to the state. See `method` param.
`method` | String | The name of the method on `target` that will be called if the state at `path` is updated. This method will be called with two parameters `(new_state, old_state)` which will be the updated and previous state data at the location specified by `path`.

#### Store.dispatch(action)
Emits an action that may update the state. The reducer is called with this action to determine whether any state changes are needed. If state changes occur, this will trigger notifications to any relevant subscribers.

Parameter | Type | Description
--- | --- | ---
`action` | Dictionary | The action that may modify state. The action should have a `type` field with a value from the `Reducer.ActionType` enum. Other data can optionally be provided to the reducer via other fields.

#### Store.get_state()
Fetches the global state. This state should not be modified.

Returns: (`Dictionary`) The global application state.


### Reducer
The logic for how state is updated in your application. These methods are called from the store and generally do not need to be referenced directly by your code.

#### Reducer.initial_state()
Seeds the initial state for the store. This state should be a dictionary. See the notes on state for more details.

Returns: (`Dictionary`) The initial global application state.

#### Reducer.reduce(state, action)
Computes the change to state needed based on the provided action. The return value controls how the state is updated and which subscribers are notified. Typically this is implemented as a switch statement over the values for `ActionType` with handler logic for each action.

Parameter | Type | Description
--- | --- | ---
`state` | Dictionary | The current state of the store. **This value should not be updated directly.**
`action` | Dictionary | The dispatched action. `action["type"]` is a `Reducer.ActionType` to identify what action is being performed. Additional data about the action may be included in other dictionary fields.

Returns: (`{path: Array, new_value: Any}`) The updated state slice and its path. `path` is an array of dictionary keys indicating what part of the state was updated. `new_value` will be put in the state at `path`. Returning `null` will not update the state or notify subscribers. Returning a `new_value` of `null` will delete any existing field at `path` from the state. If `path` is returned, it must have a length of at least one. See the notes on reducer for more details and examples.

#### enum Reducer.ActionType
The set of action types that can modify the application state.

## Authors

* **Rachel Rosalia** <<rachel@rosalia.me>>

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.
