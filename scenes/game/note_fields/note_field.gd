class_name NoteField extends Node2D


@export var takes_input: bool = false
@export_enum('Opponent', 'Player') var side: int = 0
@export var dynamic_positioning: bool = false

@onready var _receptors_node: Node2D = $receptors
@onready var _receptors: Array = []
@onready var _notes: Node2D = $notes

var _note_index: int = 0
var _chart: Chart = null
var _scroll_speed: float = -1.0
var _lanes: int
var _input_zone: float = 0.18
var _default_character: Character = null


signal note_hit(note: Note)
signal note_miss(note: Note)


func _ready() -> void:
	if is_instance_valid(Game.chart):
		_chart = Game.chart
	if _scroll_speed <= 0.0:
		_scroll_speed = Game.scroll_speed
	
	# If you have another node in here that isn't a Node2D
	# that is just currently not supported.
	_receptors = _receptors_node.get_children()
	_lanes = _receptors.size()
	
	for receptor in _receptors:
		receptor._automatically_play_static = not takes_input


func _physics_process(delta: float) -> void:
	if (not is_instance_valid(_chart)) and is_instance_valid(Game.chart):
		_chart = Game.chart
	
	call_deferred_thread_group('_try_spawning')


func _process(delta: float) -> void:
	var receptor_y: float = _receptors[0].position.y
	
	for note in _notes.get_children():
		var receptor: Receptor = null
		
		if dynamic_positioning:
			receptor = _receptors[note.data.direction % _lanes]
			note.position = receptor.position
		else:
			note.position.y = receptor_y
		
		note.position.y += (Conductor.time - note.data.time) * 1000.0 * 0.45 * _scroll_speed
		
		# This is probably a bit more costly
		# than you'd expected, but whatever.
		if dynamic_positioning and not note._clip_target == NAN:
			note._clip_target = receptor.global_position.y
		
		if (not note._hit) and (note.data.time + note.data.length
				- Conductor.time < -_input_zone):
			miss_note(note)
	
	if not takes_input:
		_input_bot()
	elif is_instance_valid(_default_character):
		for i in _lanes:
			if Input.is_action_pressed('input_%s' % i):
				_default_character._sing_timer = 0.0
				return


func hit_note(note: Note):
	# If issues somehow arise with this potential
	# edge case, then uncomment this code.
	# if not _notes.has_node(note.get_path()):
	# 	return
	
	var receptor: Receptor = _receptors[note.data.direction % _lanes]
	receptor.play_anim('confirm', true)
	
	if (not is_instance_valid(note._character)) and \
			is_instance_valid(_default_character):
		_default_character.sing(note, true)
	
	if note._hit:
		return
	
	note_hit.emit(note)
	note._hit = true
	note._clip_target = _receptors[0].global_position.y
	note._field = self
	
	if note.length > 0.0 and Conductor.time > note.data.time:
		note.length -= Conductor.time - note.data.time
		note.sustain.size.y = note.length * 1000.0 * 0.45 * Game.scroll_speed / note.scale.y \
				- note.tail.texture.get_height()
		note.sustain.position.y = note.clip_rect.size.y - note.sustain.size.y


func miss_note(note: Note) -> void:
	note_miss.emit(note)
	note.queue_free()


func _try_spawning() -> void:
	if (not is_instance_valid(_chart)) or _note_index > _chart.notes.size() - 1:
		return
	
	while _note_index < _chart.notes.size() and \
			_chart.notes[_note_index].time - Conductor.time < 2.5:
		if _note_index > _chart.notes.size() - 1:
			return
		
		var data := _chart.notes[_note_index]
		var skip: bool = data.direction < 0 or \
				(data.direction < 4 if side == 0 else data.direction > 3)
		
		if skip:
			_note_index += 1
			continue
		
		var note: Note = Game.note_types['default'].duplicate()
		note.data = data
		note.position.x = _receptors[0].position.x + \
				(112.0 * (absi(note.data.direction) % _lanes))
		_notes.add_child(note)
		_note_index += 1


func _input_bot() -> void:
	# This should never happen but just in case.
	if takes_input:
		return
	
	for note in _notes.get_children():
		if note._hit:
			continue
		if Conductor.time >= note.data.time:
			hit_note(note)
			continue
		
		break


func _unhandled_key_input(event: InputEvent) -> void:
	if not takes_input:
		return
	
	# If this SOMEHOW, by a MIRCALE
	# becomes an issue, then uncomment this code.
	# if not event is InputEventKey:
	# 	return
	
	var pressed: Array = []
	for i in _lanes:
		pressed.push_back(Input.is_action_just_pressed('input_%s' % i))
	
	var released: Array = []
	for i in _lanes:
		released.push_back(not Input.is_action_pressed('input_%s' % i))
	
	if pressed.has(true):
		for i in _lanes:
			if pressed[i]:
				_receptors[i].play_anim('press')
				_receptors[i]._automatically_play_static = false
		
		for note in _notes.get_children():
			if not pressed[absi(note.data.direction) % _lanes]:
				continue
			if Conductor.time >= note.data.time - _input_zone:
				hit_note(note)
				pressed[absi(note.data.direction) % _lanes] = false
				continue
			
			break
	elif released.has(true):
		for i in _lanes:
			if released[i]:
				_receptors[i].play_anim('static')
		
		for note in _notes.get_children():
			if not released.has(true):
				break
			if not note._hit:
				continue
			var index: int = absi(note.data.direction) % _lanes
			if not released[index]:
				continue
			# Give a bit of lee-way
			if note.length <= 1.0 / (Conductor.beat_delta * 8.0):
				# We do this because the animations get funky sometimes lol.
				_receptors[index]._automatically_play_static = true
				continue
			
			miss_note(note)
			released[index] = false
