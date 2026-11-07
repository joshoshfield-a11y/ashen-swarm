extends RefCounted
# Procedural one-shots: no ripped audio, everything synthesized at runtime.
# WAV builder: 16-bit mono PCM, 22050 Hz.

static func make_wav(f0: float, f1: float, dur: float, kind: int, vol: float) -> AudioStreamWAV:
	var sr := 22050
	var n := int(sr * dur)
	var data := PackedByteArray()
	data.resize(44 + n * 2)
	# RIFF header
	data[0] = 82; data[1] = 73; data[2] = 70; data[3] = 70  # RIFF
	var sz := 36 + n * 2
	data[4] = sz & 255; data[5] = (sz >> 8) & 255; data[6] = (sz >> 16) & 255; data[7] = (sz >> 24) & 255
	data[8] = 87; data[9] = 65; data[10] = 86; data[11] = 69  # WAVE
	data[12] = 102; data[13] = 109; data[14] = 116; data[15] = 32  # fmt
	data[16] = 16; data[17] = 0; data[18] = 0; data[19] = 0
	data[20] = 1; data[21] = 0  # PCM mono
	data[22] = 1; data[23] = 0
	data[24] = sr & 255; data[25] = (sr >> 8) & 255; data[26] = (sr >> 16) & 255; data[27] = (sr >> 24) & 255
	data[28] = (sr * 2) & 255; data[29] = ((sr * 2) >> 8) & 255; data[30] = ((sr * 2) >> 16) & 255; data[31] = ((sr * 2) >> 24) & 255
	data[32] = 2; data[33] = 0; data[34] = 16; data[35] = 0
	data[36] = 100; data[37] = 97; data[38] = 116; data[39] = 97  # data
	data[40] = (n * 2) & 255; data[41] = ((n * 2) >> 8) & 255; data[42] = ((n * 2) >> 16) & 255; data[43] = ((n * 2) >> 24) & 255
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in range(n):
		var t := float(i) / float(sr)
		var f := lerpf(f0, f1, float(i) / max(1, n - 1))
		var ph := fmod(f * t, 1.0)
		var s: float = 0.0
		if kind == 0:  # square-ish
			s = 1.0 if ph < 0.5 else -1.0
		elif kind == 1:  # sine
			s = sin(ph * TAU)
		elif kind == 2:  # noise
			s = rng.randf_range(-1.0, 1.0)
		elif kind == 3:  # saw
			s = ph * 2.0 - 1.0
		var env := 1.0 - float(i) / float(n)
		env = env * env
		var v := int(clamp(s * env * vol, -1.0, 1.0) * 28000.0)
		var idx := 44 + i * 2
		data[idx] = v & 255
		data[idx + 1] = (v >> 8) & 255
	var wav := AudioStreamWAV.new()
	wav.data = data
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sr
	wav.stereo = false
	return wav

static func build_bank() -> Dictionary:
	return {
		"shoot": make_wav(880.0, 320.0, 0.12, 0, 0.35),
		"hit": make_wav(300.0, 120.0, 0.08, 2, 0.5),
		"pickup": make_wav(660.0, 1320.0, 0.10, 1, 0.4),
		"levelup": make_wav(523.0, 1046.0, 0.35, 1, 0.5),
		"die": make_wav(400.0, 60.0, 0.25, 2, 0.6),
		"hurt": make_wav(220.0, 90.0, 0.20, 3, 0.6),
		"click": make_wav(1000.0, 700.0, 0.05, 1, 0.3),
		"boss": make_wav(140.0, 55.0, 0.6, 2, 0.7),
		"nova": make_wav(200.0, 900.0, 0.25, 3, 0.5),
	}
