# Acmi 2.2 writer

var coords = func {
	if (size(arg) == 3 or size(arg) == 6) return string.join("|", arg);
	else die("Invalid args to coords");
}


var writeTimeFrame = func(file, time, objects) {
	writeTime(file, time);
	writeObjects(file, objects);
}

var writeHeader = func(file) {
	io.write(file, "FileType=text/acmi/tacview\nFileVersion=2.2\n");
}

var writeTime = func(file, time) {
	io.write(file, "#"~time~"\n");
}

var writeObjects = func(file, objects) {
	foreach (id; keys(objects)) writeObject(file, id, objects[id]);
}

var writeObject = func(file, id, properties) {
	if (!size(properties)) return;
	io.write(file, sprintf("%X", id));
	foreach (name; keys(properties)) {
		var type = typeof(properties[name]);
		if (type == "vector") 
			var value = string.join("|", properties[name]);
		elsif (type == "scalar")
			 var value = properties[name];
		else {
			logprint(5, "Trying to write invalid type: "~name~"  ("~type~")");
			return;
		}

		io.write(file, ","~string.replace(name~"="~value, ",", "\,"));
	}
	io.write(file, "\n");
}

var writeRemove = func(file, id) {
	io.write(file, sprintf("-%X\n", id));
}