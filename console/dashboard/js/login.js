/**
 * @author monkindey
 * @date 2016.4.18
 * @description 事件驱动，jquery的典型做法
 */
require(['js/vendors/md5'], function(md5) {
	var $user = $('#user');
	var $password = $('#password');
	$('#login-in').on('click', function() {
		$.post('/login', {
			user: md5.hex_md5($user.val()),
			password: md5.hex_md5($password.val())
		}, function() {

		})
	})
})