/* ============ DEFINE FUNCTIONS ============ */

(
~transpose = {
	arg row, transposition = 0;
	transposition + row % 12;
};

~invert = {
	arg row, transposition = 0;
	row = 12 + row[0] - row % 12 + row[0];
	~transpose.(row, transposition);
};

~retrograde = {
	arg row, transposition = 0;
	row = row.reverse;
	~transpose.(row, transposition);
};

~retrogradeInvert = {
	arg row, transposition = 0;
	row = ~retrograde.(~invert.(row));
	~transpose.(row, transposition);
};

~printMatrix = {
	arg row = Array.series(12, 0);
	var inversion = ~invert.(row);
	inversion.do({
		arg pitch;
		var prime = ~transpose.(row, pitch - row[0]);
		prime.do({
			arg pitch;
			pitch.post;
			" ".post;
		});
		"".postln;
	});
	"".postln;
};

~makeMatrix = {
	arg row = Array.series(12, 0);
	var array = Array2D(12, 12);
	var inversion = ~invert.(row);
	inversion.do({
		arg pitch, i;
		var prime = ~transpose.(row, pitch - row[0]);
		prime.do({
			arg pitch, j;
			array[i, j] = pitch;
		});
	});
	array;
};
)

/* ============ TEST OPERATIONS ============ */

(
// ~row = Array.series(11, 1).scramble.insert(0, 0);
~row = Array.series(12, 0);

"Original: ".post; ~row.postln;
"Inversion: ".post; ~invert.(~row).postln;
"Retrograde: ".post; ~retrograde.(~row).postln;
"Retrograde Inversion: ".post; ~retrogradeInvert.(~row).postln;
"Transposition to 5: ".post; ~transpose.(~row, 5).postln;
)

/* ============ TEST MATRIX ============ */

// No input outputs numbers in order
(
~printMatrix.();
~makeMatrix.();
)

// Try it with a randomly generated row, with 0 at start or not
(
~randomRow = Array.series(11, 1).scramble.insert(0, 0);
// ~randomRow = Array.series(12, 0).scramble;
~printMatrix.(~randomRow);
~makeMatrix.(~randomRow);
)

// User specifed row
(
~myRow = [1, 0, 7, 6, 8, 9, 10, 11, 3, 2, 4, 5];
~printMatrix.(~myRow);
~makeMatrix.(~myRow);
)

/* ============ HEAR SOUNDS ============ */

// Define the sound
(
SynthDef(\basic, {
	arg freq = 440, amp = 0.5;
    var env = Env.perc;
    var gen = EnvGen.kr(env, doneAction: 2);
	var sig = SinOsc.ar(freq);
	sig = sig * gen * amp;
    Out.ar(0, sig);
}).add
)

// Test the sound
Synth(\basic);

(
var row = Array.series(12, 0).scramble;
var matrix = ~makeMatrix.(row);
var i = 12.rand;
var rows = Pseq((matrix.rowAt(i) + 60).midicps);
var cols = Pseq((matrix.colAt(i) + 60).midicps);
var choice = Prand([rows, cols]);
var durs = Pxrand(Array.series(6, 0.01, 0.05), inf);
// var durs = 0.1;
~printMatrix.(row);
p = Pbind(
	// \instrument, \basic,
	\freq, choice,
	\dur, durs
).play;
)

/* ============ PLAYGROUND ============ */

// Define the synth
(
SynthDef(\sine, {
	arg freq = 400, amp = 0.1, atk = 0.01, sus = 1, rel = 1, cur = \lin, pan = 0;
	var sig, env;
	sig = SinOsc.ar(freq, mul: amp);
	env = Env.linen(atk, sus, rel, curve: cur);
	sig = sig * EnvGen.kr(env, doneAction: 2);
	sig = Pan2.ar(sig, pan);
	OffsetOut.ar(0, sig);
}).add;
)

// Test parameters
Synth(\sine);
Synth(\sine, [\freq: 300, \atk: 0.1])

// Initialize a matrix
(
~matrix = ~makeMatrix.(Array.series(11, 1, 1).scramble.insert(0, 0));
"Original row: ".post; ~matrix.rowAt(0).post; "".postln;
)
// Create Pbind with initialized parameters
(
Pdefn(\pitch, Pseq(([~matrix.colAt((0..11).choose), ~matrix.rowAt((0..11).choose)].choose + 56), inf));
Pdefn(\duration, Pxrand([0.1, 0.2, 0.3, 0.4, 0.5], inf));
Pdefn(\attack, 0.8);
Pdefn(\sustain, 0.5);
Pdefn(\release, 0.01);
Pdefn(\amp, 0.1);
Pdefn(\pan, Prand([-0.5, 0, 0.5], inf));

a = Pbind(
	\instrument, \sine,
	\midinote, Pdefn(\pitch),
	\dur, Pdefn(\duration),
	\atk, Pdefn(\attack),
	\sus, Pdefn(\sustain),
	\rel, Pdefn(\release),
	\amp, Pdefn(\amp),
	\pan, Pdefn(\pan),
	);

Pdef(\butts,
	a
).play;
Pdef(\butts2,
	a
).play;

)
Pdef(\butts).play;
Pdef(\butts).stop;
Pdef(\butts2).play;
Pdef(\butts2).stop;

// Change parameters in groups...
(
Pdefn(\pitch, Pseq(([~matrix.colAt((0..11).choose), ~matrix.rowAt((0..11).choose)].choose + 56), inf));
Pdefn(\duration, Pxrand([0.1, 0.2, 0.3, 0.4, 0.5], inf));
Pdefn(\attack, 1);
Pdefn(\sustain, 0.01);
Pdefn(\release, 0.01);
Pdefn(\amp, 0.1);
Pdefn(\pan, Prand([-0.5, 0, 0.5], inf));
)

// ...or one by one
Pdefn(\duration, Pseq([0.1, 0.5], inf));
Pdefn(\pitch, Pseq([[60, 61], [62, 73]], inf));
Pdefn(\amp, 0.1);
Pdefn(\duration, 1);
Pdefn(\pitch, Pseq(([~matrix.colAt((0..11).choose), ~matrix.rowAt((0..11).choose)].choose + 56), inf));


// Try to output matrix to Fosc Lilypond score
(
var randomRow, matrix, chosenRow, foscVoice;

randomRow = Array.series(11, 1).scramble.insert(0, 0);
matrix = ~makeMatrix.(randomRow);
chosenRow = [matrix.colAt((0..11).choose), matrix.rowAt((0..11).choose)].choose + 60;

chosenRow.do({
	arg pitch, i;
	chosenRow.put(i, FoscNote(pitch, 1));
});

foscVoice = FoscVoice(chosenRow);
foscVoice.show;
)