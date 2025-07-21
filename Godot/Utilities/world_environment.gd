class_name CustomWorldEnvironment
extends WorldEnvironment

func _ready() -> void:
	init()


func init() -> void:
	set_ssao(Settings.ssao)


func set_ssr(level : int) -> void:
	if level == 0: # Disabled (default)
		environment.set_ssr_enabled(false)
	elif level == 1: # Low
		environment.set_ssr_enabled(true)
		environment.set_ssr_max_steps(8)
	elif level == 2: # Medium
		environment.set_ssr_enabled(true)
		environment.set_ssr_max_steps(32)
	elif level == 3: # High
		environment.set_ssr_enabled(true)
		environment.set_ssr_max_steps(56)


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


func set_ssil(level : int) -> void:
	if level == 0: # Disabled (default)
		environment.ssil_enabled = false
	else: # Enabled
		environment.ssil_enabled = true
	
	if level == 1: # Very Low
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_VERY_LOW, true, 0.5, 4, 50, 300)
	if level == 2: # Low
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_LOW, true, 0.5, 4, 50, 300)
	if level == 3: # Medium
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_MEDIUM, true, 0.5, 4, 50, 300)
	if level == 4: # High
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_HIGH, true, 0.5, 4, 50, 300)
	if level == 5: # Ultra
		RenderingServer.environment_set_ssil_quality(RenderingServer.ENV_SSIL_QUALITY_ULTRA, true, 0.5, 4, 50, 300)


func set_sdfgi(level : int) -> void:
	if level == 0: # Disabled (default)
		environment.sdfgi_enabled = false
	if level == 1: # Low
		environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(true)
	if level == 2: # High
		environment.sdfgi_enabled = true
		RenderingServer.gi_set_use_half_resolution(false)


func set_glow(level : int) -> void:
	if level == 0: # Disabled (default)
		environment.glow_enabled = false
	if level == 1: # Low
		environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(false)
	if level == 2: # High
		environment.glow_enabled = true
		RenderingServer.environment_glow_set_use_bicubic_upscale(true)


func set_volumetric_fog(level : int) -> void:
	if level == 0: # Disabled (default)
		environment.volumetric_fog_enabled = false
	if level == 1: # Low
		environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(false)
	if level == 2: # High
		environment.volumetric_fog_enabled = true
		RenderingServer.environment_set_volumetric_fog_filter_active(true)
