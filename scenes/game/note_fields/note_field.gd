class_name NoteField extends Node2D


@export var takes_input: bool = false
@export_enum('Opponent', 'Player') var side: int = 0
@export var dynamic_positioning: bool = false
@export var ignore_speed_changes: bool = false
@export var default_note_splash: PackedScene = null

@onready var _receptors_node: Node2D = $receptors
@onready var _receptors: Array = []
@onready var _notes: Node2D = $notes

var _note_index: int = 0
var _chart: Chart = null
var _scroll_speed: float = -1.0
var _scroll_speed_modifier: float = 1.0
var _default_character: Character = null
var _note_types: NoteTypes = null
var _note_splash_alpha: float = 0.6
var _lane_count: int
var _game: Game = null

signal note_hit(note: Note)
signal note_miss(note: Note)


func _ready() -> void:
	if is_instance_valid(Game.instance):
		_game = Game.instance
		_game.scroll_speed_changed.connect(_on_scroll_speed_changed)
		
		if not is_instance_valid(_note_types):
			_note_types = _game.note_types
	if is_instance_valid(Game.chart):
		_chart = Game.chart
	if _scroll_speed <= 0.0:
		_scroll_speed = Game.scroll_speed
	_note_splash_alpha = Config.get_value('interface', 'note_splash_alpha') / 100.0
	
	# If you have another node in here that isn't a Node2D
	# that is just currently not supported.
	_receptors = _receptors_node.get_children()
	_lane_count = _receptors.size()
	
	for receptor: Receptor in _receptors:
		receptor.play_anim(&'static')
		receptor.takes_input = takes_input
		receptor._automatically_play_static = not takes_input
		receptor.on_hit_note.connect(_on_hit_note)
		receptor.on_miss_note.connect(miss_note)


func _process(delta: float) -> void:
	if (not is_instance_valid(_chart)) and is_instance_valid(Game.chart):
		_chart = Game.chart
	if is_inside_tree(): # multithreading weirdness
		call_deferred_thread_group(&'_try_spawning')
	
	var receptor_y: float = _receptors[0].position.y
	
	for note: Note in _notes.get_children():
		var receptor: Receptor = null
		
		if dynamic_positioning:
			receptor = _receptors[note.lane]
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
				- Conductor.time < -Receptor.input_zone):
			miss_note(note)
	
	if not (takes_input and is_instance_valid(_default_character)):
		return
	
	for receptor: Receptor in _receptors:
		if not receptor._pressed:
			continue
		
		_default_character._sing_timer = 0.0
		return


func _on_hit_note(note: Note):
	# If issues somehow arise with this potential
	# edge case, then uncomment this code.
	#if not _notes.has_node(note.get_path()):
	#	return
	
	if (not is_instance_valid(note._character)) and \
			is_instance_valid(_default_character):
		_default_character.sing(note, true)
	
	if note._hit:
		return
	
	note_hit.emit(note)
	note._hit = true
	note._clip_target = _receptors[note.lane].global_position.y
	
	if note.length > 0.0:
		note.length -= Conductor.time - note.data.time
		note.data.length -= Conductor.time - note.data.time
		note._sustain_offset = -(Conductor.time - note.data.time)


func miss_note(note: Note) -> void:
	if (not is_instance_valid(note._character)) and \
			is_instance_valid(_default_character):
		_default_character.sing_miss(note, true)
	
	note_miss.emit(note)
	note.queue_free()


func _try_spawning() -> void:
	if (not is_instance_valid(_chart)) or _note_index > _chart.notes.size() - 1:
		return
	var wait_allowed: float = 800.0 / (450.0 * _scroll_speed * absf(_scroll_speed_modifier))
	while _note_index < _chart.notes.size() and \
			_chart.notes[_note_index].time - Conductor.time < wait_allowed:
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
		note.data = data.duplicate()
		note.lane = absi(data.direction) % _lane_count
		note.position.x = _receptors[0].position.x + 112.0 * (note.lane % _lane_count)
		note.position.y = -100000.0
		note._splash = default_note_splash
		_notes.add_child(note)
		_note_index += 1


func _on_scroll_speed_changed() -> void:
	if ignore_speed_changes:
		return
	_scroll_speed = Game.scroll_speed


func get_receptor_from_lane(lane: int) -> Receptor:
	for receptor: Receptor in _receptors:
		if receptor.lane == lane:
			return receptor
	return null
