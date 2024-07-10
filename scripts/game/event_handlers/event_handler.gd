## This is a base class for all [EventHandler]s to
## inherit from.
##
## It shares some common behavior but its purpose
## is to handle incoming mid-song events that are
## processed from a given chart or chart events file.
class_name EventHandler extends Node


## This is a variable to store the name of the event
## that should be handled by this [EventHandler] node.
@export var event: StringName = &'Event Name'


## This function is called when the events load and
## is used to initialize any data relating to this
## specific event handler or event in general.
func init(data: EventData) -> void:
	pass


## This function is called when the event is passed / fired
## while in-game, and should be where most actual
## functionality takes place.
func handle(data: EventData) -> void:
	print('Handling %s.' % data)
