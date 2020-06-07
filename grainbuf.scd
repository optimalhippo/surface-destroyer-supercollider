(
s.meter;
s.plotTree;
s.scope;
)

(
Buffer.freeAll;
~samples = PathName.new(PathName.new(thisProcess.nowExecutingPath).parentPath++"sounds/").entries.collect({
	arg path;
	Buffer.readChannel(s, path.fullPath, channels: [0]);
});
)

~samples[0].play;

(
{
	var sig;
	sig = GrainBuf.ar(
		2,
		Impulse.ar(12),
		0.09,
		~samples[0],
		1,
		0.2,
		2,
		0,
		-1,
		512
	);
}.play;
)