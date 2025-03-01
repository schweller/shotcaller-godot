extends Node
var game:Node

# self = game.utils

func _ready():
	game = get_tree().get_current_scene()


func circle_point_collision(p, c, r):
	return p.distance_to(c) < r


func circle_collision(c1, r1, c2, r2):
	return c1.distance_to(c2) < (r1 + r2)


func sort_by_hp(array):
	var sorted = []
	for neighbor in array:
		sorted.append({
			"unit": neighbor,
			"hp": neighbor.current_hp
		})
	sorted.sort_custom(self, "compare_hp")
	return sorted


func compare_hp(a: Dictionary, b: Dictionary) -> bool:
	return a.hp < b.hp


func sort_by_distance(unit1, array):
	var sorted = []
	for unit2 in array:
		sorted.append({
			"unit": unit2,
			"distance": unit1.global_position.distance_to(unit2.global_position)
		})
	sorted.sort_custom(self, "compare_distance")
	return sorted


func compare_distance(a: Dictionary, b: Dictionary) -> bool:
	return a.distance < b.distance


func closer_lane(point):
	var distances = []
	for lane in game.map.lanes:
		for lane_point in game.map.lanes_paths[lane]:
			distances.append({
				"distance": point.distance_to(lane_point),
				"lane": lane
			})
	distances.sort_custom(self, "compare_distance")
	return distances[0].lane


func closer_building(point, team):
	var distances = []
	var buildings = game.player_buildings
	if team != game.player_team: buildings = game.enemy_buildings
	for building in buildings:
		distances.append({
			"distance": point.distance_to(building.global_position),
			"building": building
		})
	distances.sort_custom(self, "compare_distance")
	return distances[0].building


func cut_path(unit, path):
	var distances = []
	var path_size = path.size()
	var first_point = path[0]
	for index in path_size:
		var point = path[index]
		var d1 = unit.global_position.distance_to(point)
		var d2 = first_point.distance_to(point)
		distances.append({
			"distance": d1 - (d2 / 10),
			"point": point,
			"index": index
		})
	distances.sort_custom(self, "compare_distance")
	var next_first_point = distances[0]
	
	var new_path = path.slice(next_first_point.index, path_size)
	return new_path


func limit_angle(a):
	if (a > PI): a -= PI*2
	if (a < -PI): a += PI*2
	return a


func random_point():
	var o = 50
	return Vector2(o+randf()*(game.map.size-o*2), o+randf()*(game.map.size-o*2))


func unit_collides(unit1, p):
	var c1 = p + unit1.collision_position
	var r1 = unit1.collision_radius
	for unit2 in game.all_units:
		if unit2.collide:
			var c2 = unit2.global_position + unit2.collision_position
			var r2 = unit2.collision_radius
			if circle_collision(c1, r1, c2, r2):
				return true
	return false


func offset_point_random(unit, point, offset):
	var x = (-offset) + (randf()*offset*2)
	var y = (-offset) + (randf()*offset*2)
	var p = point + Vector2(x, y)
	return p
# _no_coll
#	var counter = 8
#	while unit_collides(unit, p) and counter > 0:
#		counter -= 1
#		p = point_random_no_coll(unit, point, offset)
#	return p


func point_collision(unit1, point, s=0):
	var unit1_pos = unit1.global_position + unit1.collision_position
	return circle_point_collision(point, unit1_pos, unit1.collision_radius + s)


func unit_collision(unit1, unit2, delta):
	var unit1_pos = unit1.global_position + unit1.collision_position + (unit1.current_step * delta)
	var unit1_rad = unit1.collision_radius
	var unit2_pos = unit2.global_position + unit2.collision_position + (unit2.current_step * delta)
	var unit2_rad = unit2.collision_radius
	return circle_collision(unit1_pos, unit1_rad, unit2_pos, unit2_rad)


func get_units_around(unit1, delta):
	var unit1_pos = unit1.global_position + unit1.collision_position + (unit1.current_step * delta)
	var unit1_rad = unit1.collision_radius
	return game.map.blocks.get_units_in_radius(unit1_pos, unit1_rad)


var font
func label(string):
	var label_node = Label.new()
	label_node.text = string
	if not font:
		font = game.ui.shop.get_node("scroll_container/container/equip").get_font("font")
	label_node.add_font_override("font", font)
	return label_node


func buildings_click(point):
	for building in game.player_buildings:
		if click_distance(building, point): return building
	for building in game.enemy_buildings:
		if click_distance(building, point): return building
	for building in game.neutral_buildings:
		if click_distance(building, point): return building
	return null


func click_distance(unit, point):
	return unit.global_position.distance_to(point) <= unit.selection_radius
