extends Control


@onready var template: Panel = %template
@onready var list_parent: VBoxContainer = $panel/list/scroll_container/v_box
@onready var base_list: FreeplayList = load('res://resources/freeplay_list.tres')
@onready var tab_container: TabContainer = %tab_container

var real_list: FreeplayList = FreeplayList.new()


func _ready() -> void:
	template.visible = false
	
	for song: FreeplaySong in base_list.list:
		var good_song := song.duplicate(true)
		real_list.list.append(good_song)
		_make_song(good_song)


func _make_song(song: FreeplaySong) -> void:
	var node := template.duplicate()
	node.visible = true
	node.name = str(list_parent.get_child_count() - 1)
	
	var icon: Sprite2D = node.get_node('icon')
	icon.texture = song.icon.texture
	icon.hframes = song.icon.frames.x
	icon.vframes = song.icon.frames.y
	icon.texture_filter = song.icon.filter
	
	var label: Label = node.get_node('song_label')
	label.text = song.song_name
	
	var delete: Button = node.get_node('delete')
	delete.pressed.connect(func():
		real_list.list.erase(song)
		node.queue_free()
	)
	
	var up: Button = node.get_node('move_up')
	up.pressed.connect(func():
		var cur_index: int = real_list.list.find(song)
		var prev_index: int = clampi(cur_index - 1, 0, real_list.list.size() - 1)
		
		if cur_index == prev_index:
			return
		
		var prev_song := real_list.list[prev_index]
		var prev_node := list_parent.get_child(prev_index + 1)
		real_list.list[prev_index] = song
		real_list.list[cur_index] = prev_song
		
		list_parent.move_child(prev_node, cur_index + 1)
		list_parent.move_child(node, prev_index + 1)
	)
	
	var down: Button = node.get_node('move_down')
	down.pressed.connect(func():
		var cur_index: int = real_list.list.find(song)
		var prev_index: int = clampi(cur_index + 1, 0, real_list.list.size() - 1)
		
		if cur_index == prev_index:
			return
		
		var prev_song := real_list.list[prev_index]
		var prev_node := list_parent.get_child(prev_index + 1)
		real_list.list[prev_index] = song
		real_list.list[cur_index] = prev_song
		
		list_parent.move_child(prev_node, cur_index + 1)
		list_parent.move_child(node, prev_index + 1)
	)
	
	var edit: Button = node.get_node('edit')
	edit.pressed.connect(func():
		_edit(song, node)
	)
	
	list_parent.add_child(node)


func _edit(song: FreeplaySong, node: Panel) -> void:
	tab_container.current_tab = 1
