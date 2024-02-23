class_name CancellableEvent extends Resource


var status: EventStatus = EventStatus.CONTINUE


enum EventStatus {
	CONTINUE = 0,
	CANCEL = 1,
}
