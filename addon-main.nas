
io.include("utils.nas");

var file = nil;

var loadModule = func(path) {
	var function = compile(io.readfile(path), path);

	var err = nil;

	var module = {};
	call(bind(function, globals), nil, nil, module, err);

	if (err != nil) die(err);

	return module;
}

var start = func() {
	file = io.open(getprop("/sim/fg-home") ~ "/Export/out.txt.acmi", "w+");

	fgtw.acmi.writeHeader(file);
	fgtw.acmi.writeObject(file, 1, {});

	var root = props.getNode("/sim/fgtw");
	var meta = props.getNode("/sim/fgtw/metadata");

	# Metadata
	fgtw.acmi.writeObjects(file, {
		0.0: {
			DataSource: "FlightGear " ~ getprop("/sim/version/flightgear"),
			DataRecorder: "FGTW " ~ getprop("/addons/by-id/FGTW/version"),
			ReferenceTime: getprop("/sim/time/gmt"),
			#RecordingTime
			Author: meta.getValue("author"),
			Title: meta.getValue("title")
		},
		1: {
			Name: getprop("/sim/fgtw/aircraft/name"),
			Type: getprop("/sim/fgtw/aircraft/type")
		}
	});
	setprop("/sim/fgtw/recording", 1);
}
	
var stop = func() {
	setprop("/sim/fgtw/recording", 0);
	if (file != nil) io.close(file);
	file = nil;
}


var main = func(addon) {
	var dir = addon.basePath;

	globals["fgtw"] = {
		acmi: loadModule(dir ~ "/acmi.nas")
	};

	var modules = ["/aircraft.nas", "/ai.nas"];

	foreach (module; modules) compile(io.readfile(dir ~ module), module)();

	addcommand("fgtw-start", start);
	addcommand("fgtw-stop", stop);

	print("FGTW "~addon.version.str()~" loaded");
}

var unload = func(dontuse) { # Argument is weird, don't use
	delete(globals, "fgtw");

	removecommand("fgtw-start");
	removecommand("fgtw-stop");

	print("FGTW unloaded");
}


#io.close(file);
