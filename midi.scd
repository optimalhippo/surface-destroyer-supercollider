(
SynthDef(\basic, {
	arg freq = 440, amp = 0.3, gate = 0;
	var sig, env;
	sig = LFTri.ar(freq)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction: 2);
	sig = sig * env * amp;
	Out.ar(0, sig);
}).add;

MIDIClient.init;
MIDIn.connectAll;
MIDIdef.freeAll;

~notes = Array.newClear(128)

MIDIdef.noteOn(\on, {
	arg vel, nn;
	// [vel, nn].postln;
	~notes[nn] = Synth(
		\basic,
		[
			\freq, nn.midicps,
			\amp, vel.linexp(1,127,0.01,0.3),
			\gate, 1
		]
	);
}).permanent_(true);

MIDIdef.noteOff(\off, {
	arg vel, nn;
	// [vel, nn].postln;
	~notes[nn].set(\gate, 0);
	~notes[nn] = nil;
}).permanent_(true);
)
