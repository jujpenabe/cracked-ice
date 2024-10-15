class_name GameOptionsMenu
extends Control

func _update_ui():
	pass

func _ready():
	_update_ui()

func _on_reset_button_pressed() -> void: # TODO: list all saved games
	%ConfirmResetDialog.popup_centered()
	%ResetButton.disabled = true

func _on_confirmation_dialog_confirmed() -> void:
	LevelManager.delete()

func _on_confirmation_dialog_canceled() -> void:
	%ResetButton.disabled = false
