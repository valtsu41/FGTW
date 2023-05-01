
var getTime = numGetter("/sim/time/elapsed-sec", 2);
var models = {};

var addModel = func(path) {
	var node = props.getNode(path);
	if (!node.getValue("valid")) die("Trying to add invalid model: "~path);

	var crd = {
		getLon: numGetter(path~"/position/longitude-deg", 7),
		getLat: numGetter(path~"/position/latitude-deg", 7),
		getAlt: numGetter(path~"/position/altitude-ft", 3, FT2M),

		getRoll: numGetter(path~"/orientation/roll-deg", 3),
		getPitch: numGetter(path~"/orientation/pitch-deg", 3),
		getHeading: numGetter(path~"/orientation/true-heading-deg", 3)
	};

	var maps = {
		base: func return {
			T: func return [
				crd.getLon(),
				crd.getLat(),
				crd.getAlt(),
				crd.getRoll(),
				crd.getPitch(),
				crd.getHeading()
			],

			Name: "Unknown",
			Type: "Misc + Minor",
			CallSign: getter(path~"/callsign"),

			TAS: numGetter(path~"/velocities/true-airspeed-kt", 2, KT2MPS)
		},
		carrier: func return copyHash(maps.ship(), {
			Type: "Sea + Watercraft + AircraftCarrier"
		}),
		ship: func return copyHash(maps.base(), {
			Type: "Sea + Watercraft"
		}),
		multiplayer: func return copyHash(maps.base(), {
			Type: "Air + FixedWing",

			Squawk: getter(path~"/instrumentation/transponder/transmitted-id"),


			AirBrakes: numGetter(path~"/surface-positions/speedbrake-pos-norm", 3),
			Flaps: numGetter(path~"/surface-positions/flap-pos-norm", 3),
			LandingGear: numGetter(path~"/gear/gear/position-norm", 3),

			AileronLeft: numGetter(path~"/surface-positions/left-aileron-pos-norm", 3),
			AileronRight: numGetter(path~"/surface-positions/right-aileron-pos-norm", 3),
			Elevator: numGetter(path~"/surface-positions/elevator-pos-norm", 3),
			Rudder: numGetter(path~"/surface-positions/rudder-pos-norm", 3)
			
		}),
};
	# If AI type is implemented, use it, else use base AI type
	models[path] = newMapGetter(contains(maps, node.getName()) ? maps[node.getName()]() : maps.base());
}

var removeModel = func(path) {
	delete(models, path);
}


var stampy = maketimestamp();

var timer = maketimer(1, func() {
	stampy.stamp();

	var objects = {};
	foreach (path; keys(models)) objects[getprop(path~"/id")+16] = models[path].getChanged();
	fgtw.acmi.writeTimeFrame(file, getTime(), objects);

	setprop("/sim/fgtw/ai-writing-usec", stampy.elapsedUSec());

	timer.restart(getprop("sim/fgtw/interval"));
});



foreach (node; props.getNode("/ai/models").getChildren()) if (node.getValue("valid")) addModel(node.getPath());

setlistener("/ai/models/model-added", func(node) {
	var path = node.getValue();

	# Wait until the props have been initialised.
	var validityListener = globals.setlistener(path~"/valid", func(valid) {
		if (!valid.getBoolValue()) return;
		removelistener(validityListener);
		addModel(path);
	}, 1);
});
setlistener("/ai/models/model-removed", func(node) removeModel(node.getValue()));

setlistener("/sim/fgtw/recording", func(node) if (node.getValue()) timer.start() else timer.stop());