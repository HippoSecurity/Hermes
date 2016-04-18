require([
	'js/vendors/template',
	'js/vendors/mock'
], function(tmpl, Mock, treeData) {
	var data = {
		labels: ["January", "February", "March", "April", "May", "June", "July"],
		datasets: [{
			label: "My First dataset",
			fillColor: "rgba(220,220,220,0.2)",
			strokeColor: "rgba(220,220,220,1)",
			pointColor: "rgba(220,220,220,1)",
			pointStrokeColor: "#fff",
			pointHighlightFill: "#fff",
			pointHighlightStroke: "rgba(220,220,220,1)",
			data: [65, 59, 80, 81, 56, 55, 40]
		}, {
			label: "My Second dataset",
			fillColor: "rgba(151,187,205,0.2)",
			strokeColor: "rgba(151,187,205,1)",
			pointColor: "rgba(151,187,205,1)",
			pointStrokeColor: "#fff",
			pointHighlightFill: "#fff",
			pointHighlightStroke: "rgba(151,187,205,1)",
			data: [28, 48, 40, 19, 86, 27, 90]
		}]
	};

	var EDGES_LIST_URL = 'data.json';

	Mock.mock(/\.json/, {
		'list|1-10': [{
			'id|+1': 1,
			'email': '@EMAIL',
			'regexp3': /\d{5,10}/
		}]
	});

	var $presentation = $('#presentation');
	var chart = $('#chart').get(0);
	var chartCtx = chart.getContext("2d");
	var lineChart = null;

	chart.width = $presentation.width() * 0.9;
	chart.height = 550;

	function renderPage() {
		$.getJSON(EDGES_LIST_URL, function(res) {
			console.log(res);
			// $('.edges-list').html(tmpl.template($('#edges-list').html(), res));
		});

		lineChart = new Chart(chartCtx).Line(data);
	}

	renderPage();
})