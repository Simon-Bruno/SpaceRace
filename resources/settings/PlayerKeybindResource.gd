class_name PlayerKeybindResource
extends Resource


const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_FORWARD : String = "move_forward"
const MOVE_BACK : String = "move_back"
const JUMP : String = "jump"
const INTERACT : String = "interact"
const ATTACK : String = "attack"
const OPEN_CHAT : String = "open_chat"
const USE_ITEM : String = "use_item"
const PULL : String = "pull"

@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_FORWARD_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_BACK_KEY = InputEventKey.new()
@export var DEFAULT_JUMP_KEY = InputEventKey.new()
@export var DEFAULT_INTERACT_KEY = InputEventKey.new()
@export var DEFAULT_ATTACK_KEY = InputEventKey.new()
@export var DEFAULT_OPEN_CHAT_KEY = InputEventKey.new()
@export var DEFAULT_USE_ITEM_KEY = InputEventKey.new()
@export var DEFAULT_PULL_KEY = InputEventKey.new()

var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var move_forward_key = InputEventKey.new()
var move_back_key = InputEventKey.new()
var jump_key = InputEventKey.new()
var interact_key = InputEventKey.new()
var attack_key = InputEventKey.new()
var open_chat_key = InputEventKey.new()
var use_item_key = InputEventKey.new()
var pull_key = InputEventKey.new()
