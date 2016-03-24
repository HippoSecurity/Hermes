== 雪球的登录

-- form_uri
http://www.xueqiu.com

-- shifter
<input type="text" name="(username)" placeholder="手机号 / 邮箱">
-- to
$1 -> random_string(length = 8)

-- shifter
<input type="(password)" name="(password)" placeholder="密码">
-- to
$1 -> hide_password_type()
$2 -> random_string(length = 8)

-- phantom
<input type="text" name="username" placeholder="手机号 / 邮箱">
<input type="password" name="password" placeholder="密码">
-- to
/login/dark
