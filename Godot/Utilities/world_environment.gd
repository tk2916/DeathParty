class_name CustomWorldEnvironment
extends WorldEnvironment

func _ready() -> void:
	init()


func init() -> void:
	set_ssao(Settings.ssao)


func set_ssao(level : int) -> void:
	if level > 0: # Enabled
		environment.ssao_enabled = true
	else: # Disabled
		environment.ssao_enabled = false

	if level == 1: # Very Low
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
	if level == 2: # Low
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
	if level == 3: # Medium
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
	if level == 4: # High
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
	if level == 5: # Ultra
		RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_ULTRA, true, 0.5, 2, 50, 300)
