// Taken from: https://youtu.be/WBqAM_94TW4

// Run below for meter and node tree; uncomment scopes if needed
(
s.meter;
s.plotTree;
// s.scope;
// FreqScope.new;
)

// Run below every time server is booted to load the sound file(s)
(
Buffer.freeAll;
~samples = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath++"sounds/").entries.collect({
    arg path;
    Buffer.readChannel(s, path.fullPath, channels: [0]);
});
)

// Run below to test that the sound file works (remember, it will play left channel only!)
~samples[0].play;

// Run below to granulate a file; comments show a few possibilities,
// but remember to double check values all make sense together before running!
(
{
    var sig;
    sig = GrainBuf.ar(
        // ==== NUMCHANNELS ====
        // 1,
        2,

        // ==== TRIGGER ====
        Impulse.ar(
            10
            // 60
            // MouseX.kr(1, 200, 1)
        ),
        /*    Dust.ar(
        // 12
        MouseX.kr(1, 200, 1)
        ),*/
        // Impulse.ar([60, 60.5]),
        // Impulse.ar({ExpRand(60, 60.5)}!12), // use Splay; also swap for "Dust.ar"

        // ==== DUR ====
        0.09,
        // 0.0001,
        // MouseX.kr(0.0002, 2, 1), // use sig * 0.3 for values close to 2
        // LFNoise1.kr(0.3!2).exprange(0.0002, 0.1),
        // LFNoise1.kr(0.3!12).exprange(0.0002, 0.1), // use Splay

        // ==== SNDBUF ====
        ~samples[0],

        // ==== RATE ====
        1,

        // ==== POS ====
        // 0.2,
        // MouseX.kr(0.1, 0.9, 1),
        LFNoise1.ar(0.1).range(0, 1), // try values like 500, 10 (matching impulese at 10), and 0.1

        // ==== INTERP ====
        2,

        // ==== PAN ====
        0,

        // ==== EVNBUFNUM ====
        -1,

        // ==== MAXGRAINS ====
        512
    );

    // sig = sig * 0.3;
    // sig = Splay.ar(sig);

}.play;
)

// Below is a compact version to be copied and values altered
// It plays through the file in real time, but adds a 40hz "buzz"
(
{
    var sig;
    sig = GrainBuf.ar(
        2,
        Impulse.ar(40),
        0.02,
        ~samples[0],
        1,
        Line.ar(0, 1, BufDur.ir(~samples[0]), doneAction: 2),
        2,
        0,
        -1,
        512
    );
}.play;
)

// Same as above except dur matches trigger (2x recip of trig)
// LFNoise adds deviations at rate of 100
// bipolar means + or - and the deviation measured in seconds,
// which are calculated useing SampleRate.ir * [desired seconds]
// sounds "wobbly"
(
{
    var sig;
    sig = GrainBuf.ar(
        2,
        Impulse.ar(40),
        1/20,
        ~samples[0],
        1,
        (
            Line.ar(0, BufSamples.ir(~samples[0]) - 1, BufDur.ir(~samples[0]), doneAction: 2)
            + LFNoise1.ar(100).bipolar(0.2 * SampleRate.ir)
        ) / BufSamples.ir(~samples[0]),
        2,
        0,
        -1,
        512
    );
}.play;
)

// Using Phasor
(
{
    var sig;
    sig = GrainBuf.ar(
        2,
        Impulse.ar(40),
        1/20,
        ~samples[0],
        1,
        (
            Phasor.ar(0, 1 * BufRateScale.ir(~samples[0]), 0, BufSamples.ir(~samples[0]) - 1)
            + LFNoise1.ar(100).bipolar(0.2 * SampleRate.ir)
        ) / BufSamples.ir(~samples[0]),
        2,
        0,
        -1,
        512
    );
}.play;
)

// Scale pitch using midiratio (negative values for transpose down)
(
{
    var sig;
    sig = GrainBuf.ar(
        2,
        Impulse.ar(100),
        0.2,
        ~samples[1],
        6.midiratio,
        (
            Phasor.ar(0, 1 * BufRateScale.ir(~samples[0]), 0, BufSamples.ir(~samples[0]) - 1)
            + LFNoise1.ar(100).bipolar(0.2 * SampleRate.ir)
        ) / BufSamples.ir(~samples[0]),
        2,
        0,
        -1,
        512
    );
    sig = sig * 0.4;
}.play;
)

// Mouse controlled pitch shift
(
{
    var sig;
    sig = GrainBuf.ar(
        2,
        Dust.ar(100),
        0.2,
        ~samples[0],
        MouseX.kr(0.5, 2, 1),
        (
            Phasor.ar(0, 1 * BufRateScale.ir(~samples[0]), 0, BufSamples.ir(~samples[0]) - 1)
            + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
        ) / BufSamples.ir(~samples[0]),
        2,
        0,
        -1,
        512
    );
    sig = sig * 0.4;
}.play;
)

// Mouse controls pitch and time simultaneously
(
{
    var sig;
    sig = GrainBuf.ar(
        2,
        Dust.ar(100),
        0.2,
        ~samples[1],
        MouseX.kr(0.5, 2, 1),
        (
            Phasor.ar(0, MouseY.kr(0.1, 2, 1) * BufRateScale.ir(~samples[1]), 0, BufSamples.ir(~samples[1]) - 1)
            + LFNoise1.ar(100).bipolar(0.01 * SampleRate.ir)
        ) / BufSamples.ir(~samples[1]),
        2,
        0,
        -1,
        512
    );
    sig = sig * 0.4;
}.play;
)