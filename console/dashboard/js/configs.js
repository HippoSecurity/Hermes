require([
	'js/util',
	'js/vendors/template',
	'js/vendors/mock'
], function(util, tmpl, Mock) {
	// jquery变量缓存
	var $switchs = $('.switch');
	var tab = null;

	// Mock 拦截模拟数据
	Mock.mock(/\.json/, {
		'list|5-10': [{
			'id|+1': 1,
			'name': '@NAME',
			'condition': '@condition'
		}]
	})

	// 各种事件监听
	$(document.body).delegates({
		'.sub-menu li': function() {
			var $activeTab = $(this);
			$('.sub-menu li').removeClass('active');
			$activeTab.addClass('active');
			$switchs.hide();
			tab = $activeTab.attr('data-tab');
			$('#' + tab).show();
		}
	});

	function getTableData() {
		var promise = $.Deferred();
		$.getJSON('./data.json', function(res) {
			promise.resolve(res);
		});
		return promise;
	}

	function renderTable() {
		var rulesTable = $('#rules-tpl').html();
		getTableData().then(function(res) {
			console.log(res);
			$('#rules').html(tmpl.template(rulesTable, res));
		});
	}

	// 只有一次的效果，第一次初始化页面
	(function initPage() {
		$switchs.hide();
		$switchs.first().show();
		renderTable();
	})()
})