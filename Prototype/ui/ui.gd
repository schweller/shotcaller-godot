extends CanvasLayer

var game:Node
var map_tiles:Node
var minimap:Node
var map_sprite:Node

func _ready():
	game = get_tree().get_current_scene()
	map_tiles = game.get_node("map/tiles")
	map_sprite = game.get_node("map/sprite")
	minimap = get_node("bot_left/minimap")


func update_stats():
	var stats = get_node("bot_mid/stats")
	var unit = game.selected_unit
	
	if unit:
		stats.show()
		var name = unit.name
		stats.get_node("name").text = name
	else:
		stats.hide()

func minimap_default():
	map_tiles.visible = true
	minimap.visible = true
	map_sprite.visible = false
	for unit in game.all_units:
		unit.get_node("symbol").visible = false
		unit.get_node("hud").visible = true
		unit.get_node("shadow").visible = true
		unit.get_node("sprites").visible = true
		unit.get_node("animations").current_animation = unit.state
	
func minimap_cover():
	map_tiles.visible = false
	minimap.visible = false
	map_sprite.visible = true
	for unit in game.all_units:
		unit.get_node("symbol").visible = true
		unit.get_node("hud").visible = false
		unit.get_node("shadow").visible = false
		unit.get_node("sprites").visible = false
		unit.get_node("animations").current_animation = ""
