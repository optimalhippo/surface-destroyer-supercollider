// Load buffers and create SynthDef in one go:
(
Buffer.freeAll;
~samples = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath++"sounds/").entries.collect({
    arg path;
    Buffer.readChannel(s, path.fullPath, channels: [0]);
});

SynthDef(\grainer, {
    arg trigType = 1, dens = 20, grainDur = 0.1, durRand  = 1, buf = 0,
    rate = 1, pos = 0, posSpeed = 1, posRand = 0,
    grainEnv = -1, pan = 0, panHz = 0.1, panRand = 0,
    atk = 1, sus = 2, rel = 1, c0 = 1, c1 = -1, amp = 1, out = 0;

    var sig, env, densCtrl, durCtrl, posCtrl, panCtrl;

    env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, rel], [c0, 0, c1]), doneAction: 2);
    densCtrl = Select.ar(trigType, [Dust.ar(dens), Impulse.ar(dens)]);
    durCtrl = grainDur * LFNoise1.kr(100).exprange(1/durRand, durRand);

    posCtrl = Phasor.ar(0, posSpeed * BufRateScale.ir(buf), 0, BufSamples.ir(buf) - 1);
    posCtrl = posCtrl + LFNoise1.kr(100).bipolar(posRand * SampleRate.ir);
    posCtrl = posCtrl / BufSamples.ir(buf);
    posCtrl = posCtrl + pos;

    panCtrl = pan + LFNoise1.kr(panHz).bipolar(panRand);

    sig = GrainBuf.ar(
        2,
        densCtrl,
        durCtrl,
        buf,
        rate,
        posCtrl,
        2,
        panCtrl,
        grainEnv
    );

    sig = sig * env * amp;

    Out.ar(out, sig);
}).add;
)

// default version plays buffer at normal rate
(
Synth(\grainer, [
    \buf, ~samples[1]
])
)

// set sustain to sample length to hear the exact length
(
Synth(\grainer, [
    \buf, ~samples[1],
    \atk, 0,
    \sus, ~samples[1].duration,
    \rel, 0
])
)

// sample other values
(
Synth(\grainer, [
    \buf, ~samples[1],
    \trigType, 0,
    \dens, 400,
    \grainDur, 0.2,
    \posSpeed, 0.8,
    \pos, 0,
    \rate, -7.midiratio,
    \amp, 0.3,
    \sus, 2
])
)

// Define a pattern
(
Pbindef(
    \grains,
    \instrument, \grainer,
    \buf, ~samples[0],
    \trigType, 0,
    \dens, Pexprand(40, 100, inf),
    \grainDur, Pexprand(0.001, 0.1, inf),
    // \durRand,
    \rate, Pexprand(0.5, 3, inf),
    \pos, Pwhite(0.1, 0.8, inf),
    \posSpeed, Pexprand(0.1, 4, inf),
    // \posRand,
    // \pan,
    // \panHz,
    \panRand, 0.3,
    \atk, Pexprand(0.001, 0.05, inf),
    \sus, Pexprand(0.05, 2, inf),
    \rel, Pexprand(0.001, 0.05, inf),
    \dur, Pexprand(0.01, 1.5, inf),
    \amp, Pexprand(0.1, 0.25, inf)
);
)

// Automate starting, changing values, stopping
(
Routine({
    "Starting".postln;
    Pbindef(\grains).play;
    5.wait;
    "Change density".postln;
    Pbindef(\grains, \dens, Pwhite(100, 500, inf));
    5.wait;
    "Change sustain and duration".postln;
    Pbindef(\grains, \sus, 0.4, \dur, 0.5);
    5.wait;
    "Stopping".postln;
    Pbindef(\grains).stop;
}).play;
)