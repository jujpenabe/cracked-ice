extends Control

const FORE_COLOR := Color.BLACK
const BACK_COLOR := Color.LIGHT_SLATE_GRAY
const ITEM_SIZE := Vector2(40.0, 60.0)
const COMMIT_DOT_OFFSET := Vector2(ITEM_SIZE.x / 2, 8.0)
const FIRST_TAG_OFFSET := Vector2(0, 24.0)
const ITER_TAG_OFFSET := Vector2(0, 11.0)
const COMMIT_DOT_RADIUS := 5.0
const LINE_WIDTH := 2.0
const TAG_FONT_SIZE := 12

var font = ThemeDB.fallback_font
var reverter: CReverter


func setup(p_reverter: CReverter) -> void:
	reverter = p_reverter


func _draw() -> void:
	_draw_background()

	# Draw commit line
	for i in reverter.history.size():
		_draw_commit_dot(i)
		if i != 0:
			_draw_connecting_line(i - 1, i)

	# Draw cursor
	var cursor := reverter.get_cursor()
	_draw_commit_rect(cursor)

	# Draw tags
	for i in reverter.history.size():
		_draw_tags(i, reverter.history.get_tags_at(i))


func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_rect().size), BACK_COLOR)


func _draw_commit_dot(item_number: int) -> void:
	var center := _get_item_rect(item_number).position + COMMIT_DOT_OFFSET
	var radius := COMMIT_DOT_RADIUS
	draw_circle(center, radius, FORE_COLOR)


func _draw_connecting_line(item_number_1: int, item_number_2: int) -> void:
	var point_1 := _get_item_rect(item_number_1).position + COMMIT_DOT_OFFSET
	var point_2 := _get_item_rect(item_number_2).position + COMMIT_DOT_OFFSET
	draw_line(point_1, point_2, FORE_COLOR, LINE_WIDTH)


func _draw_commit_rect(item_number: int) -> void:
	var rect := _get_item_rect(item_number)
	draw_rect(rect, FORE_COLOR, false, LINE_WIDTH)


func _draw_tags(item_number: int, tags: Array) -> void:
	# Dictionary.erase() doesn't work with StringName apparently,
	# so you have to manually convert CReverter.CURSOR_TAG to a String
	# to remove it from arrays returned by CRHistory.get_tags_at().
	tags.erase(str(CReverter.CURSOR_TAG))

	if tags.size() >= 4:
		tags[3] = "..."
		tags.resize(4)

	var tag_position := _get_item_rect(item_number).position + FIRST_TAG_OFFSET
	for tag in tags:
		draw_string(font, tag_position, tag, HORIZONTAL_ALIGNMENT_CENTER,
				ITEM_SIZE.x, TAG_FONT_SIZE, FORE_COLOR)
		tag_position += ITER_TAG_OFFSET


func _get_item_rect(item_number: int) -> Rect2:
	return Rect2(Vector2(item_number * ITEM_SIZE.x, 0.0), ITEM_SIZE)
