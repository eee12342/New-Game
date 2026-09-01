extends Node


var current_state: State
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_changed.connect(_on_child_state_changed)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _on_child_state_changed(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.lower())
	if not new_state:
		return
		
	if current_state:
		current_state.exit()
