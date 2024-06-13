class_name PlayerKeybindResource
extends Resource


const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_FORWARD : String = "move_forward"
const MOVE_BACK : String = "move_back"
const JUMP : String = "jump"

@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_FORWARD_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_BACK_KEY = InputEventKey.new()
@export var DEFAULT_JUMP_KEY = InputEventKey.new()

var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var move_forward_key = InputEventKey.new()
var move_back_key = InputEventKey.new()
var jump_key = InputEventKey.new()
