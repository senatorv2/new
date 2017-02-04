package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  .. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

-- @Senator_tea
tdcli = dofile('tdcli.lua')
redis = (loadfile "./libs/redis.lua")()
sudo_users = {
  170146015,
  204507468,
  196568905
}

-- Print message format. Use serpent for prettier result.
function vardump(value, depth, key)
  local linePrefix = ''
  local spaces = ''

  if key ~= nil then
    linePrefix = key .. ' = '
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do 
      spaces = spaces .. '  '
    end
  end

  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces .. linePrefix .. '(table) ')
    else
      print(spaces .. '(metatable) ')
        value = mTable
    end
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)  == 'function' or 
    type(value) == 'thread' or 
    type(value) == 'userdata' or 
    value == nil then --@H_Terminal
      print(spaces .. tostring(value))
  elseif type(value)  == 'string' then
    print(spaces .. linePrefix .. '"' .. tostring(value) .. '",')
  else
    print(spaces .. linePrefix .. tostring(value) .. ',')
  end
end

-- Print callback
function dl_cb(arg, data)
  vardump(arg)
  vardump(data)
end

function is_sudo(msg)
  local var = false
  -- Check users id in config
  for v,user in pairs(sudo_users) do
    if user == msg.sender_user_id_ then
      var = true
    end
  end
  return var
end


function tdcli_update_callback(data)
  vardump(data)

  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    local input = msg.content_.text_
    local chat_id = msg.chat_id_
    local user_id = msg.sender_user_id_
    local reply_id = msg.reply_to_message_id_
    vardump(msg)
    if msg.content_.ID == "MessageText" then
      if input == "ping" then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '`pong`', 1, 'md')
		
      end
      if input == "PING" then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>PONG</b>', 1, 'html')
      end
      if input:match("^ایدی$") then
	  tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ایدی سوپرگروه: </b><code>'..string.sub(chat_id, 5,14)..'</code>\n<b>ایدی یوزر: </b><code>'..user_id..'</code>\n<b>ایدی کانال تیم سناتور: </b>@Senator_tea', 1, 'html')
      end

      if input:match("^سنجاق") and reply_id then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>سنجاق شد✅</b>', 1, 'html')
        tdcli.pinChannelMessage(chat_id, reply_id, 1)
      end

      if input:match("^حذف سنجاق") and reply_id then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>سنجاق حذف شد✅</b>', 1, 'html')
        tdcli.unpinChannelMessage(chat_id, reply_id, 1)
      end

      		-----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
		if input:match("^اضافه$") and is_sudo(msg) then
		 redis:sadd('groups',chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ربات به گروه اضافه شد✅</b>!*', 1, 'md')
		end
		-------------------------------------------------------------------------------------------------------------------------------------------
		if input:match("^حذف$") and is_sudo(msg) then
		redis:srem('groups',chat_id)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅<b>ربات از گروه رفت</b>✅ !*', 1, 'md')
		 end
		 -----------------------------------------------------------------------------------------------------------------------------------------------
			
			--lock links
groups = redis:sismember('groups',chat_id)
      if input:match("^قفل لینک$") and is_sudo(msg) and groups then
       if redis:get('lock_linkstg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>لینک از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('lock_linkstg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '_لینک قفل شد_', 1, 'md')
      end
      end 
      if input:match("^بازکردن لینک$")  and is_sudo(msg) and groups then
       if not redis:get('lock_linkstg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>لینک از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('lock_linkstg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>لینک آزاد شد✅</b>', 1, 'md')
      end
      end
	  --lock username
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل یوزرنیم$") and is_sudo(msg) and groups then
       if redis:get('usernametg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ارسال یوزرنیم از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('usernametg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>ارسال یوزرنیم قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن یوزرنیم$") and is_sudo(msg) and groups then
       if not redis:get('usernametg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ارسال یوزرنیم از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('usernametg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>ارسال یوزرنیم آزاد شد</b>', 1, 'md')
      end
      end
	  --lock tag
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل تگ$") and is_sudo(msg) and groups then
       if redis:get('tagtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ارسال تگ از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('tagtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>ارسال تگ قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن تگ$") and is_sudo(msg) and groups then
       if not redis:get('tagtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ارسال تگ از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('tagtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>ارسال تگ آزاد شد</b>', 1, 'md')
      end
      end
	  --lock forward
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل فروارد$") and is_sudo(msg) and groups then
       if redis:get('forwardtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>فروارد کردن از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('forwardtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>فروارد کردن قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن فروارد$") and is_sudo(msg) and groups then
       if not redis:get('forwardtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>فروارد کردن از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('forwardtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>فروارد کردن آزاد شد</b>', 1, 'md')
      end
      end
	  --arabic/persian
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل عربی$") and is_sudo(msg) and groups then
       if redis:get('arabictg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>استفاده از کلمات عربی از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('arabictg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>استفاده از کلمات عربی قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن عربی$") and is_sudo(msg) and groups then
       if not redis:get('arabictg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>استفاده از کلمات عربی از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('arabictg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>استفاده از کلمات عربی آزاد شد</b>', 1, 'md')
      end
      end
	 ---english
	 groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل انگلیسی$") and is_sudo(msg) and groups then
       if redis:get('engtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>استفاده از کلمات انگلیسی از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('engtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>استفاده از کلمات انگلیسی قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن انگلیسی$") and is_sudo(msg) and groups then
       if not redis:get('engtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>استفاده از کلمات انگلیسی از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('engtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>استفاده از کلمات انگلیسی آزاد شد</b>', 1, 'md')
      end
      end
	  --lock foshtg
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل فحش$") and is_sudo(msg) and groups then
       if redis:get('badwordtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>فحش از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('badwordtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>فحش ممنوع شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن فحش$") and is_sudo(msg) and groups then
       if not redis:get('badwordtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>فحش از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('badwordtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>فحش آزاد شد</b>', 1, 'md')
      end
      end
	  --lock edit
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل ویرایش$") and is_sudo(msg) and groups then
       if redis:get('edittg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ویرایش از قبل ممنوع بود</b>', 1, 'md')
       else 
        redis:set('edittg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>ویرایش قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن ویرایش$") and is_sudo(msg) and groups then
       if not redis:get('edittg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ویرایش از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('edittg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>ویرایش آزاد شد</b>d', 1, 'md')
      end
      end
	  --lock emoji
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل ایموجی") and is_sudo(msg) and groups then
       if redis:get('emojitg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>شکلک از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('emojitg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>شکلک قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن ایموجی$") and is_sudo(msg) and groups then
       if not redis:get('emojitg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>شکلک از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('emojitg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>شکلک آزاد شد</b>', 1, 'md')
      end
      end
	  --lock tgservice
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل سرویس$") and is_sudo(msg) and groups then
       if redis:get('tgservice:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>سرویس ها از قبل قفل بود</b>', 1, 'md')
       else 
        redis:set('tgservice:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>سرویس ها قفل شد</b>', 1, 'md')
      end
      end 
      if input:match("^بازکردن سرویس$") and is_sudo(msg) and groups then
       if not redis:get('tgservice:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>سرویس ها از قبل آزاد بود</b>', 1, 'md')
       else
         redis:del('tgservice:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<b>سرویس ها آزاد شد</b>', 1, 'md')
      end
      end
	  
	  -----------------------------------------------------------------------------------------------------------------
local link = 'lock_linkstg:'..chat_id
	 if redis:get(link) then
	  link = "✅"
	  else 
	  link = "❎"
	 end
	 
	 local username = 'usernametg:'..chat_id
	 if redis:get(username) then
	  username = "✅"
	  else 
	  username = "❎"
	 end
	 
	 local tag = 'tagtg:'..chat_id
	 if redis:get(tag) then
	  tag = "✅"
	  else 
	  tag = "❎"
	 end
	 
	 local forward = 'forwardtg:'..chat_id
	 if redis:get(forward) then
	  forward = "✅"
	  else 
	  forward = "❎"
	 end
	 
	 local arabic = 'arabictg:'..chat_id
	 if redis:get(arabic) then
	  arabic = "✅"
	  else 
	  arabic = "❎"
	 end
	 
	 local eng = 'engtg:'..chat_id
	 if redis:get(eng) then
	  eng = "✅"
	  else 
	  eng = "❎"
	 end
	 
	 local badword = 'badwordtg:'..chat_id
	 if redis:get(badword) then
	  badword = "✅"
	  else 
	  badword = "❎"
	 end
	 
	 local edit = 'edittg:'..chat_id
	 if redis:get(edit) then
	  edit = "✅"
	  else 
	  edit = "❎"
	 end
	 
	 local emoji = 'emojitg:'..chat_id
	 if redis:get(emoji) then
	  emoji = "✅"
	  else 
	  emoji = "❎"
	 end
	 ----------------------------
		--muteall
		groups = redis:sismember('groups',chat_id)
            if input:match("^ممنوعیت همه$") and is_sudo(msg) and groups then
       if redis:get('mute_alltg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال همه چی از قبل ممنوع بود</b>*', 1, 'md')
       else 
       redis:set('mute_alltg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال همه چی ممنوع است</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن همه$") and is_sudo(msg) and groups then
       if not redis:get('mute_alltg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال همخ چی از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_alltg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال همه چی آزاد شد</b>*', 1, 'md')
      end
      end	 

--mute sticker
groups = redis:sismember('groups',chat_id)
if input:match("^ممنوعیت استیکر$") and is_sudo(msg) and groups then
       if redis:get('mute_stickertg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال استیکر از قبل قفل بود</b>*', 1, 'md')
       else
        redis:set('mute_stickertg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>رسال استیکر ممنوع است</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن استیکر$") and is_sudo(msg) and groups then
       if not redis:get('mute_stickertg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>رسال استیکر از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_stickertg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال استیکر آزاد شد</b>*', 1, 'md')
      end
      end		  
	  --mute gift
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت گیف$") and is_sudo(msg) and groups then
       if redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال گیفاز قبل قفل بود</b>*', 1, 'md')
       else 
        redis:set('mute_contacttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال گیف قفل شد</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن گیف$") and is_sudo(msg) and groups then
       if not redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال گیف از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_contacttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>گیف آزاد شد</b>*', 1, 'md')
      end
      end
	  --mute contact
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت شماره$") and is_sudo(msg) and groups then
       if redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال شماره از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_contacttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال شماره ممنوع شد</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن شماره$") and is_sudo(msg) and groups then
       if not redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال شماره از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_contacttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال شماره آزاد شد</b>*', 1, 'md')
      end
      end
	  --mute photo
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت عکس$") and is_sudo(msg) and groups then
       if redis:get('mute_phototg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال عکس از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_phototg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال عکس ممنوع شد</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن عکس$") and is_sudo(msg) and groups then
       if not redis:get('mute_phototg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال عکس از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_phototg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال عکس آزاد شد</b>*', 1, 'md')
      end
      end
	  --mute audio
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت آهنگ$") and is_sudo(msg) and groups then
       if redis:get('mute_audiotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال آهنگ از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_audiotg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال آهنگ ممنوع شد</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن آهنگ$") and is_sudo(msg) and groups then
       if not redis:get('mute_audiotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال آهنگ از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_audiotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال آهنگ آزاد شد</b>*', 1, 'md')
	  end
      end
		--mute voice
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت صدا$") and is_sudo(msg) and groups then
       if redis:get('mute_voicetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال صدا از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_voicetg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال صدا ممنوع شد</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن صدا$") and is_sudo(msg) and groups then
       if not redis:get('mute_voicetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال صدا از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_videotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال صدا آزاد شد</b>*', 1, 'md')
		end
		end
		--mute video
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت فیلم $") and is_sudo(msg) and groups then
       if redis:get('mute_videotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال فیلم از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_videotg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال فیلم ممنوع شد</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن فیلم$") and is_sudo(msg) and groups then
       if not redis:get('mute_videotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال فیلم از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_videotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال فیلم آزاد شد</b>*', 1, 'md')
		end
		end
		--mute document
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت یاداشت$") and is_sudo(msg) and groups then
       if redis:get('mute_documenttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال یاداشت از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_documenttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال یاداشت ممنوع شد</b>*', 1, 'md')
      end
      end
      if input:match("^بازکردن یاداشت$") and is_sudo(msg) and groups then
       if not redis:get('mute_documenttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال یاداشت از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_documenttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال یاداشت آزاد شد</b>*', 1, 'md')
		end
		end
		--mute  text
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت متن$") and is_sudo(msg) and groups then
       if redis:get('mute_texttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال متن از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_texttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*ارسال متن ممنوع شد*', 1, 'md')
      end
      end
      if input:match("^بازکردن متن$") and is_sudo(msg) and groups then
       if not redis:get('mute_texttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال متن از قبل آزاد بود</b>*', 1, 'md')
       else 
         redis:del('mute_texttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>ارسال متن آزاد شد</b>*', 1, 'md')
		end
		end
		--settings
		local all = 'mute_alltg:'..chat_id
	 if redis:get(all) then
	  All = "✅"
	  else 
	  All = "❎"
	 end
	 
	 local sticker = 'mute_stickertg:'..chat_id
	 if redis:get(sticker) then
	  sticker = "✅"
	  else 
	  sticker = "❎"
	 end
	 
	 local gift = 'mute_gifttg:'..chat_id
	 if redis:get(gift) then
	  gift = "✅"
	  else 
	  gift = "❎"
	 end
	 
	 local contact = 'mute_contacttg:'..chat_id
	 if redis:get(contact) then
	  contact = "✅"
	  else 
	  contact = "❎"
	 end
	 
	 local photo = 'mute_phototg:'..chat_id
	 if redis:get(photo) then
	  photo = "✅"
	  else 
	  photo = "❎"
	 end
	 
	 local audio = 'mute_audiotg:'..chat_id
	 if redis:get(audio) then
	  audio = "✅"
	  else 
	  audio = "❎"
	 end
	 
	 local voice = 'mute_voicetg:'..chat_id
	 if redis:get(voice) then
	  voice = "✅"
	  else 
	  voice = "❎"
	 end
	 
	 local video = 'mute_videotg:'..chat_id
	 if redis:get(video) then
	  video = "✅"
	  else 
	  video = "❎"
	 end
	 
	 local document = 'mute_documenttg:'..chat_id
	 if redis:get(document) then
	  document = "✅"
	  else 
	  document = "❎"
	 end
	 
	 local text1 = 'mute_texttg:'..chat_id
	 if redis:get(text1) then
	  text1 = "✅"
	  else 
	  text1 = "❎"
	 end
      if input:match("^تنظیمات$") and is_sudo(msg) then
		local text = "⚙Super Group Settings⚙".."\n"
		.."🔰`قفل لینک:` ".."*"..link.."*".."\n"
		.."🔰`قفل تگ:` ".."*"..tag.."*".."\n"
		.."🔰`قفل یوزرنیم:` ".."*"..username.."*".."\n"
		.."🔰`قفل فروارد:` ".."*"..forward.."*".."\n"
		.."🔰`قفل عربی:` ".."*"..arabic..'*'..'\n'
		.."🔰`قفل انگلیسی:` ".."*"..eng..'*'..'\n'
		.."🔰`قفل فحش:` ".."*"..badword..'*'..'\n'
		.."🔰`قفل ویرایش:` ".."*"..edit..'*'..'\n'
		.."🔰`قفل ایموجی:` ".."*"..emoji..'*'..'\n'
		.."*🚏🚏🚏🚏🚏🚏🚏🚏🚏🚏*".."\n"
		.."📢لیست ممنوعیت📢".."\n"
		.."🔰`ممنوعیت همه: `".."*"..All.."*".."\n"
		.."🔰`ممنوعیت استیکر: `".."*"..sticker.."*".."\n"
		.."🔰`ممنوعیت گیف: `".."*"..gift.."*".."\n"
		.."🔰`ممنوعیت شماره: `".."*"..contact.."*".."\n"
		.."🔰`ممنوعیت عکس: `".."*"..photo.."*".."\n"
		.."🔰`ممنوعیت آهنگ: `".."*"..audio.."*".."\n"
		.."🔰`ممنوعیت صدا: `".."*"..voice.."*".."\n"
		.."🔰`ممنوعیت فیلم: `".."*"..video.."*".."\n"
		.."🔰`ممنوعیت متن: `".."*"..document.."*".."\n"
		.."🔰`ممنوعیت تکست: `".."*"..text1.."*".."\n"
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
		end
      if input:match("^ارسال$") then
        tdcli.forwardMessages(chat_id, chat_id,{[0] = reply_id}, 0)
      end
	  
      if input:match("^یوزرنیم") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 11))
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Username Changed To </b>@'..string.sub(input, 11), 1, 'html')
      end
	  
      if input:match("^[Ee]cho") then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, string.sub(input, 7), 1, 'html')
      end

      if input:match("^تغییر دادن اسم") then
        tdcli.changeChatTitle(chat_id, string.sub(input, 10), 1)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup Name Changed To </b><code>'..string.sub(input, 10)..'</code>', 1, 'html')
      end
	  if input:match("^چک کردن اسم") and is_sudo(msg) then
        tdcli.changeName(string.sub(input, 13), nil, 1)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot Name Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  if input:match("^چک کردن یوزر") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 13), nil, 1)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot UserName Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  if input:match("^حذف یوزر") and is_sudo(msg) then
        tdcli.changeUsername('')
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '#Done\nUsername Has Been Deleted', 1, 'html')
      end
      if input:match("^وایش") then
        tdcli.editMessageText(chat_id, reply_id, nil, string.sub(input, 7), 'html')
      end

	  if input:match("^delpro") then
        tdcli.DeleteProfilePhoto(chat_id, {[0] = msg.id_})
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>#done profile has been deleted</b>', 1, 'html')
      end
	  
      if input:match("^[Ii]nvite") and is_sudo(msg) then
        tdcli.addChatMember(chat_id, string.sub(input, 9), 20)
      end
      if input:match("^[Cc]reatesuper") and is_sudo(msg) then
        tdcli.createNewChannelChat(string.sub(input, 14), 1, 'My Supergroup, my rules')
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup </b>'..string.sub(input, 14)..' <b>Created</b>', 1, 'html')
      end

      if input:match("^هستی") then
        tdcli.viewMessages(chat_id, {[0] = msg.id_})
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>اره هستم </b>', 1, 'html')
      end
    end

   local input = msg.content_.text_
if redis:get('mute_alltg:'..chat_id) and msg and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end

   if redis:get('mute_stickertg:'..chat_id) and msg.content_.sticker_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_contacttg:'..chat_id) and msg.content_.animation_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_contacttg:'..chat_id) and msg.content_.contact_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_phototg:'..chat_id) and msg.content_.photo_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_audiotg:'..chat_id) and msg.content_.audio_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_voicetg:'..chat_id) and msg.content_.voice_  and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_videotg:'..chat_id) and msg.content_.video_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_documenttg:'..chat_id) and msg.content_.document_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_texttg:'..chat_id) and msg.content_.text_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
      	  if redis:get('forwardtg:'..chat_id) and msg.forward_info_ and not is_sudo(msg) then 
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('lock_linkstg:'..chat_id) and input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	        if redis:get('tagtg:'..chat_id) and input:match("#") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('usernametg:'..chat_id) and input:match("@") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('arabictg:'..chat_id) and input:match("[\216-\219][\128-\191]") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	 local is_english_msg = input:match("[a-z]") or input:match("[A-Z]")
	  if redis:get('engtg:'..chat_id) and is_english_msg and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  local is_fosh_msg = input:match("کیر") or input:match("کس") or input:match("کون") or input:match("85") or input:match("جنده") or input:match("ننه") or input:match("ننت") or input:match("مادر") or input:match("قهبه") or input:match("گایی") or input:match("سکس") or input:match("kir") or input:match("kos") or input:match("kon") or input:match("nne") or input:match("nnt")
	  if redis:get('badwordtg:'..chat_id) and is_fosh_msg and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	 local is_emoji_msg = input:match("😀") or input:match("😬") or input:match("😁") or input:match("😂") or  input:match("😃") or input:match("😄") or input:match("😅") or input:match("☺️") or input:match("🙃") or input:match("🙂") or input:match("😊") or input:match("😉") or input:match("😇") or input:match("😆") or input:match("😋") or input:match("😌") or input:match("😍") or input:match("😘") or input:match("😗") or input:match("😙") or input:match("😚") or input:match("🤗") or input:match("😎") or input:match("🤓") or input:match("🤑") or input:match("😛") or input:match("😏") or input:match("😶") or input:match("😐") or input:match("😑") or input:match("😒") or input:match("🙄") or input:match("🤔") or input:match("😕") or input:match("😔") or input:match("😡") or input:match("😠") or input:match("😟") or input:match("😞") or input:match("😳") or input:match("🙁") or input:match("☹️") or input:match("😣") or input:match("😖") or input:match("😫") or input:match("😩") or input:match("😤") or input:match("😲") or input:match("😵") or input:match("😭") or input:match("😓") or input:match("😪") or input:match("😥") or input:match("😢") or input:match("🤐") or input:match("😷") or input:match("🤒") or input:match("🤕") or input:match("😴") or input:match("💋") or input:match("❤️")
	  if redis:get('emojitg:'..chat_id) and is_emoji_msg and not is_sudo(msg)  then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
		end
		
	  if redis:get('captg:'..chat_id) and  msg.content_.caption_ then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end

  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    -- @H_Terminal
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
