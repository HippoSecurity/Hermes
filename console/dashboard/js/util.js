define('js/util', function() {
	$.fn.delegates = function(configs) {
		el = $(this[0]);
		for (var name in configs) {
			var value = configs[name];
			if (typeof value == 'function') {
				var obj = {};
				obj.click = value;
				value = obj;
			};
			for (var type in value) {
				el.delegate(name, type, value[type]);
			}
		}
		return this;
	}
})