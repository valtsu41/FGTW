
var getTime = numGetter("/sim/time/elapsed-sec", 2);

var crd = {
	getLon: numGetter("/position/longitude-deg", 7),
	getLat: numGetter("/position/latitude-deg", 7),
	getAlt: numGetter("/position/altitude-ft", 3, FT2M),

	getRoll: numGetter("/orientation/roll-deg", 3),
	getPitch: numGetter("/orientation/pitch-deg", 3),
	getHeading: numGetter("/orientation/heading-deg", 3)
};

var getterMap = {
	T: func return [
		crd.getLon(),
		crd.getLat(),
		crd.getAlt(),
		crd.getRoll(),
		crd.getPitch(),
		crd.getHeading()
	],

	CallSign: getter("/sim/multiplay/callsign"),
	Squawk: getter("/instrumentation/transponder/transmitted-id"),

	CAS: numGetter("/velocities/airspeed-kt", 2, KT2MPS),
	Mach: numGetter("/velocities/mach", 2),

	AOA: numGetter("/orientation/alpha-deg", 1),
	AOS: numGetter("/orientation/side-slip-deg", 1),

	AGL: numGetter("/position/altitude-agl-ft", 1, FT2M),

	Throttle: numGetter("/controls/engines/engine/throttle", 3),

	AirBrakes: numGetter("/surface-positions/speedbrake-pos-norm", 3),
	Flaps: numGetter("/surface-positions/flap-pos-norm", 3),
	LandingGear: numGetter("/gear/gear/position-norm", 3),
	LandingGearHandle: numGetter("controls/gear/gear-down", 1),

	RollControlInput: numGetter("/controls/flight/aileron", 3),
	PitchControlInput: numGetter("/controls/flight/elevator", 3),
	YawControlInput: numGetter("/controls/flight/rudder", 3),

	#RollTrimTab: numGetter("/controls/flight/aileron-trim", 3),
	#PitchTrimTab: numGetter("/controls/flight/elevator-trim", 3),
	#YawTrimTab: numGetter("/controls/flight/rudder-trim", 3),

	AileronLeft: numGetter("/surface-positions/left-aileron-pos-norm", 3),
	AileronRight: numGetter("/surface-positions/right-aileron-pos-norm", 3),
	Elevator: numGetter("/surface-positions/elevator-pos-norm", 3),
	Rudder: numGetter("/surface-positions/rudder-pos-norm", 3)
};

var ubergetter = newMapGetter(getterMap);

var stampy = maketimestamp();

var timer = maketimer(1, func() {
	stampy.stamp();

	var properties = ubergetter.getChanged();
	if (size(properties) > 0) fgtw.acmi.writeTimeFrame(file, getTime(), {1: properties});

	setprop("/sim/fgtw/local-writing-usec", stampy.elapsedUSec());

	timer.restart(getprop("sim/fgtw/interval"));
});

setlistener("/sim/fgtw/recording", func(node) node.getValue() ? timer.start() : timer.stop());