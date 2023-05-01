var copyHash = func(dest, src) {
	foreach(key; keys(src)) dest[key] = src[key];
	return dest;
};

var getter = func(proparg) {
	var prop = isa(proparg, props.Node) ? proparg : props.getNode(proparg, 1);
	if (prop == nil) {
		logprint(5, "getter could not get property "~proparg);
		return;
	}
	return func return prop.getValue();
}

var numGetter = func(proparg, prec=6, coeff=1) {
	var prop = isa(proparg, props.Node) ? proparg : props.getNode(proparg, 1);
	if (prop == nil) {
		logprint(5, "numGetter could not get property "~proparg);
		return;
	}
	return func return sprintf("%."~prec~"f", (prop.getValue() or 0.0)*coeff);
}

var newMapGetter = func(getterMap) return {
	getters: getterMap,
	cache: {},

	getChanged: func {
		var properties = getChanged(me.getters, me.cache);
		foreach (name; keys(properties)) me.cache[name] = properties[name];
		return properties;
	}
};


var getMap = func(getterMap) {
	var map = {};
	foreach (key; keys(getterMap)) {
		var type = typeof(getterMap[key]);
		if (type == "func") 
			map[key] = getterMap[key]();
		elsif (type == "scalar") 
			map[key] = getterMap[key];
		else 
			die("getterMap invalid type: "~name~"  ("~type~")");
	}
	return map;
}

var getChanged = func(getterMap, prevMap) {
	var map = {};
	var value = nil;
	foreach (key; keys(getterMap)) {
		var type = typeof(getterMap[key]);
		if (type == "func") 
			value = getterMap[key]();
		elsif (type == "scalar")
			value = getterMap[key];
		elsif (type == "nil")
			value = nil
		else 
			die("getterMap invalid type: "~name~"  ("~type~")");

		if (value == nil) continue;

		if (prevMap[key] != value) map[key] = value;
	}
	return map;
}

var dround = func(x, decimals) {
	var p = math.pow(10, -decimals);
	var v = math.fmod(x, p);

	if (v <= (p * 0.5)) return x - v;
	else return x + p - v;
}

var dtrunk = func(x, decimals) {
	return x - math.fmod(x, math.pow(10, -decimals));
}