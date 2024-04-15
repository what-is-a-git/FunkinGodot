class_name NoteField extends Node2D


@export var takes_input: bool = false
@export_enum('Opponent', 'Player') var side: int = 0
@export var dynamic_positioning: bool = false
@export var ignore_speed_changes: bool = false
@export var note_splash: PackedScene = null

@onready var _receptors_node: Node2D = $receptors
@onready var _receptors: Array = []
@onready var _notes: Node2D = $notes

var _note_index: int = 0
var _chart: Chart = null
var _scroll_speed: float = -1.0
var _scroll_speed_modifier: float = 1.0
var _lanes: int
var _input_zone: float = 0.18
var _default_character: Character = null
var _note_types: NoteTypes = null
var _note_splash_alpha: float = 0.6


signal note_hit(note: Note)
signal note_miss(note: Note)


func _ready() -> void:
	if is_instance_valid(Game.instance) and not is_instance_valid(_note_types):
		_note_types = Game.instance.note_types
	if is_instance_valid(Game.chart):
		_chart = Game.chart
	if _scroll_speed <= 0.0:
		_scroll_speed = Game.scroll_speed
	_note_splash_alpha = Config.get_value('interface', 'note_splash_alpha') / 100.0
	
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
		
		note.position.y -= (Conductor.time - note.data.time) * 1000.0 * 0.45 \
				* _scroll_speed * _scroll_speed_modifier
		
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
	
	if note.length > 0.0:
		note.length -= Conductor.time - note.data.time
		
		if Conductor.time > note.data.time:
			note.sustain.size.y = note.data.length * 1000.0 * 0.45 * _scroll_speed \
					/ note.scale.y - note.tail.texture.get_height()


func miss_note(note: Note) -> void:
	if (not is_instance_valid(note._character)) and \
			is_instance_valid(_default_character):
		_default_character.sing_miss(note, true)
	
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
		
		var note: Note = _note_types.types['default'].instantiate()
		note._field = self
		note.data = data
		note.position.x = _receptors[0].position.x + \
				(112.0 * (absi(note.data.direction) % _lanes))
		note._splash = note_splash
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
	if event.is_echo():
		return
	
	# If this SOMEHOW, by a MIRCALE
	# becomes an issue, then uncomment this code.
	# if not event is InputEventKey:
	# 	return
	
	var is_input: bool = false
	var lane: int = -1
	
	for i in _lanes:
		if event.is_action('input_%s' % i):
			is_input = true
			lane = i
			break
	
	if not is_input:
		return
	
	var pressed: bool = event.is_pressed()
	
	if pressed:
		_receptors[lane].play_anim('press')
		_receptors[lane]._automatically_play_static = false
		
		for note in _notes.get_children():
			if note._hit:
				continue
			var index: int = absi(note.data.direction) % _lanes
			if index != lane:
				continue
			
			var before_zone: bool = Conductor.time < note.data.time - _input_zone
			var after_zone: bool = Conductor.time > note.data.time + _input_zone
			
			if not (before_zone or after_zone):
				hit_note(note)
				break
			# break
	else:
		_receptors[lane].play_anim('static')
		
		for note in _notes.get_children():
			if not note._hit:
				continue
			var index: int = absi(note.data.direction) % _lanes
			if index != lane:
				continue
			
			# Give a bit of lee-way
			if note.length <= 1.0 / (Conductor.beat_delta * 8.0):
				# We do this because the animations get funky sometimes lol.
				_receptors[index]._automatically_play_static = true
				continue
			
			miss_note(note)


func _on_scroll_speed_changed() -> void:
	if ignore_speed_changes:
		return
	
	_scroll_speed = Game.scroll_speed
