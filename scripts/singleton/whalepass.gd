class_name Whalepass
extends Node

class AnyResp:
	pass

class EnrollResp:
	var id: String
	var externalPlayerId: String # player id
	var gameId: String
	var userId: Variant # null
	var accountConnected: bool
	var createdAt: String
	var updatedAt: String

class RedirectLinkResp:
	var redirectionLink: String
	
class PlayerInventoryResp:
	var items: Array

class PlayerBaseProgressResp:
	var currentExp: int
	var lastCompletedLevel: int

const api_key_header := "X-Api-Key"
const api_key_value := "dc2abf737024ae762b8fd50a540e5efa" # "407b186e6b73ba3b2314bc7a569357a9"
const battlepass_id := "bcce814a-6661-4bb4-850f-5cc2e4c5f937"
const game_id := "92045a22-957c-4962-88be-36b890cac6f5"

const challenge_kill_bad_teddy := "44226f7c-0de2-409d-b0a5-63831908652e"

var player_id := ""
var whalepass_pid := ""

var rest_call : RESTCall

func _generate_player_id() -> String:
	return "USER-" + Time.get_datetime_string_from_system().replace(":", "-") + "-" +  str(randi())
func get_or_create_player_id() -> String:
	var cfg := ConfigFile.new()
	cfg.load("user://save.cfg")
	var pid := cfg.get_value("whalepass", "playerId", "") as String
	if pid == "":
		pid = _generate_player_id()
		cfg.set_value("whalepass", "playerId", pid)
		cfg.save("user://save.cfg")
	return pid

func _ready() -> void:
	rest_call = RESTCall.new()
	rest_call.custom_headers = [api_key_header+": "+api_key_value, "X-Battlepass-Id: "+battlepass_id]
	add_child(rest_call)

func enroll(pid: String) -> bool:
	var resp := EnrollResp.new()
	var success := rest_call.rest_call(
		"https://api.whalepass.gg/enrollments",
		resp, RESTCall.POST, ["Content-Type: application/json"],
		JSON.stringify({"playerId": pid, "gameId": game_id})
	)
	if not success:
		return false
	await rest_call.done
	player_id = pid
	whalepass_pid = resp.id
	return true

func redirect_link() -> String:
	var resp := RedirectLinkResp.new()
	var success := rest_call.rest_call(
		"https://api.whalepass.gg/players/%s/redirect?gameId=%s" % [player_id, game_id],
		resp, RESTCall.GET, [],
		""
	)
	if not success:
		return ""
	await rest_call.done
	
	if rest_call._obj == null:
		return ""
	return resp.redirectionLink

func progress_action(actionId: String) -> bool:
	var resp := AnyResp.new()
	var success := rest_call.rest_call(
		"https://api.whalepass.gg/players/%s/progress/action" % [player_id],
		resp, RESTCall.POST, ["Content-Type: application/json"],
		JSON.stringify({"actionId": actionId, "gameId": game_id})
	)
	if not success:
		return false
	await rest_call.done
	
	if rest_call._obj == null:
		return false
	return true

func progress_xp(xp: int) -> bool:
	var resp := AnyResp.new()
	var success := rest_call.rest_call(
		"https://api.whalepass.gg/players/%s/progress/exp" % [player_id],
		resp, RESTCall.POST, ["Content-Type: application/json"],
		JSON.stringify({"additionalExp": xp, "gameId": game_id})
	)
	if not success:
		return false
	await rest_call.done
	
	if rest_call._obj == null:
		return false
	return true

func progress_challenge(challenge_id: String) -> bool:
	var resp := AnyResp.new()
	var success := rest_call.rest_call(
		"https://api.whalepass.gg/players/%s/progress/challenge" % [player_id],
		resp, RESTCall.POST, ["Content-Type: application/json"],
		JSON.stringify({"challengeId": challenge_id, "gameId": game_id})
	)
	if not success:
		return false
	await rest_call.done
	
	if rest_call._obj == null:
		return false
	return true

func player_inventory() -> bool:
	var resp := PlayerInventoryResp.new()
	var success := rest_call.rest_call(
		"https://api.whalepass.gg/players/%s/inventory?gameId=%s" % [player_id, game_id],
		resp, RESTCall.GET, [],
		""
	)
	if not success:
		return false
	await rest_call.done
	
	if rest_call._obj == null:
		return false
	return true
	
func player_progress() -> int:
	var resp := PlayerBaseProgressResp.new()
	var success := rest_call.rest_call(
		"https://api.whalepass.gg/players/%s/progress/base?gameId=%s" % [player_id, game_id],
		resp, RESTCall.GET, [],
		""
	)
	if not success:
		return -1
	await rest_call.done
	
	if rest_call._obj == null:
		return -1
	return resp.lastCompletedLevel
