(
SynthDef(\synth1, {
	arg freq = 440, atk = 1, rel = 1, amp = 1, pan = 0.5,
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env([0,1,0], [atk, rel], [1,1]), doneAction: 2);
	sig = sig*env;
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(0, sig);
}).add;
)

(
Synth(\synth1, [
	\atk, 0.025,
	\rel, 0.2,
	\amp, 0.5,
	\freq, (440.0.rand + 440).postln,
	\pan, 1
]);
)

(
Pdef(
	\surfDes,
	Pbind(
		\instrument, \synth1,
		// \freq, Prand([110, 220, 440, 660, 880, 990, 1110, 1220], inf ),
		\degree, Pexprand(1, 7),
		\scale, Scale.gong,
		\amp, Pexprand(0.1, 0.25, inf),
		\atk, Pexprand(0.025, 0.06, inf),
		\rel, Pexprand(1, 1.5, inf),
		\dur, Pseq(([0.25, 0.5, 0.25, Prand([0.25, 0.5, 0.75, 1], 6)])*0.8, inf),
		\pan, Prand([-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1], inf)
	);
).play;
)

Scale.directory