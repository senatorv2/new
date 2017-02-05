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
    value == nil then --@Senator_tea
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
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ربات به گروه اضافه شد✅<🚏>!*', 1, 'md')
		end
		-------------------------------------------------------------------------------------------------------------------------------------------
		if input:match("^حذف$") and is_sudo(msg) then
		redis:srem('groups',chat_id)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅<🚏>ربات از گروه رفت<🚏>✅ !*', 1, 'md')
		 end
		 -----------------------------------------------------------------------------------------------------------------------------------------------
			
		
							
      if input:match('^[!#/]([Ss]etowner)$') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^([Ss]etowner)$') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^تنظیم مالک$') and is_owner(msg) and msg.reply_to_message_id_ then
          tdcli.getMessage(chat_id,msg.reply_to_message_id_,setowner_reply,nil)
      end
			
			
        if input:match('^[!#/](Dd]elowner)$') and is_sudo(msg) and msg.reply_to_message_id_ or input:match('^(Dd]elowner)$') and is_sudo(msg) and msg.reply_to_message_id_ or input:match('^حذف مالک$') and is_sudo(msg) and msg.reply_to_message_id_ then
          tdcli.getMessage(chat_id,msg.reply_to_message_id_,deowner_reply,nil)
      end
			
			
        if input:match('^[!#/]([Oo]wner)$') or input:match('^([Oo]wner)$') or input:match('^مالک$') then
        local hash = 'owners:'..chat_id		
         local owner = redis:get(hash)
        if owner == nil then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🔸گروه `مالک` ندارد \n🎗 ', 1, 'md')
        end
	
        local owner_list = redis:get('owners:'..chat_id)
        text85 = '🎗 `مالک گروه:`\n\n '..owner_list		
         tdcli.sendText(chat_id, 0, 0, 1, nil, text85, 1, 'md')
      end	
	
        if input:match('^[/!#]setowner (.*)') and not input:find('@') and is_sudo(msg) then
        redis:del('owners:'..chat_id)		
        redis:set('owners:'..chat_id,input:match('^[/!#]setowner (.*)'))
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[/!#]setowner (.*)')..' ⏳به عنوان `مالک` منصوب شد\n🎗', 1, 'md')
      end

      if input:match('^[/!#]setowner (.*)') and input:find('@') and is_owner(msg) then
        function Inline_Callback_(arg, data)
          redis:del('owners:'..chat_id)
					
      redis:set('owners:'..chat_id,input:match('^[/!#]setowner (.*)'))
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[/!#]setowner (.*)')..'⏳ به عنوان `مالک` منصوب شد\n🎗', 1, 'md')
        end
        tdcli_function ({ID = "SearchPublicChat",username_ =input:match('^[/!#]setowner (.*)')}, Inline_Callback_, nil)
      end
			
     if input:match('^[/!#]delowner (.*)') and is_sudo(msg) then
        redis:del('owners:'..chat_id)
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[/!#]delowner (.*)')..' ⌛از عنوان `مالک` محروم شد\n🎗 ', 1, 'md')
      end
			
-------------------------------------------------------------------------------         
			
      if input:match('^[/!#]promote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^promote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^ارتقا') and is_owner(msg) and msg.reply_to_message_id_ then
          tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmod_reply,nil)
      end
      if input:match('^[/!#]demote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^demote') and is_owner(msg) and msg.reply_to_message_id_ or input:match('^عزل') and is_owner(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,remmod_reply,nil)
      end
		
      sm = input:match('^[/!#]promote (.*)') or input:match('^promote (.*)') or input:match('^ارتقا (.*)')
if sm and is_owner(msg) then
  redis:sadd('mods:'..chat_id,sm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #انجام شد!\n🏅 #کاربر '..sm..'⏳به عنوان _مدیر_ منصوب شد\n🎗 ', 1, 'md')
end
			
       dm = input:match('^[/!#]demote (.*)') or input:match('^demote (.*)') or input:match('^عزل (.*)')
if dm and is_owner(msg) then
  redis:srem('mods:'..chat_id,dm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #انجام شد\n🏅 #کاربر '..dm..'⏳از مقام _مدیر_ عزل شد\n🎗 ', 1, 'md')
end
if input:match('^[/!#]modlist') and is_mod(msg) or input:match('^modlist') and is_mod(msg) or input:match('^لیست مدیران') and is_mod(msg) then
if redis:scard('mods:'..chat_id) == 0 then
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅گروه _مدیری_ ندارد⏳', 1, 'md')
end
	
    local text = "🏅 `لیست مدیران` : \n"
for k,v in pairs(redis:smembers('mods:'..chat_id)) do
text = text.."_"..k.."_ - *"..v.."*\n"
end
tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'md')
end
-------------------------------------------------------------
			
      if input:match('^[/!#]setlink (.*)') and is_owner(msg) then
redis:set('link'..chat_id,input:match('^[/!#]setlink (.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, 'لينک گروه ذخيره شد🏅\n', 1, 'html')
end
if input:match('^[/!#]link$') and is_mod(msg) or input:match('^link$') and is_mod(msg) or input:match('^لينک$') and is_mod(msg) then
link = redis:get('link'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅لينک گروه :\n'..link, 1, 'html')
end
-------------------------------------------------------
			
      if input:match('^[/!#]setrules (.*)') and is_owner(msg) then
redis:set('gprules'..chat_id,input:match('^[/!#]setrules (.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅قوانين ثبت شد', 1, 'html')
end
if input:match('^[/!#]rules$') and is_mod(msg) or input:match('^rules$') and is_mod(msg) or input:match('^قوانين$') and is_mod(msg) then
rules = redis:get('gprules'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅قوانين گروه :\n'..rules, 1, 'html')
end
--------------------------------------------------------------------------
			
      if input:match('^[!#/](kick)$') and is_mod(msg) or input:match('^(kick)$') and is_mod(msg) or input:match('^اخراج$') and is_mod(msg) then
        tdcli.getMessage(chat_id,reply,kick_reply,nil)
      end
      if input:match('^[!#/]kick (.*)') and not input:find('@') and is_mod(msg) then
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[!#/]kick (.*)')..' `⏳اخراج`شد\n🎗 ', 1, 'md')
        tdcli.changeChatMemberStatus(chat_id, input:match('^[!#/]kick (.*)'), 'Kicked')
      end
      if input:match('^[!#/]kick (.*)') and input:find('@') and is_mod(msg) then
        function Inline_Callback_(arg, data)
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..input:match('^[!#/]kick (.*)')..' `⏳اخراج`شد\n🎗 ', 1, 'md')
          tdcli.changeChatMemberStatus(chat_id, data.id_, 'Kicked')
        end
        tdcli_function ({ID = "SearchPublicChat",username_ =input:match('^[!#/]kick (.*)')}, Inline_Callback_, nil)
      end
--------------------------------------------------------
 ----------------------------------------------------------
			
      if input:match('^[/!#]muteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^muteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^ساکت کردن') and is_mod(msg) and msg.reply_to_message_id_ then
        redis:set('tbt:'..chat_id,'yes')
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmute_reply,nil)
      end
      if input:match('^[/!#]unmuteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^unmuteuser') and is_mod(msg) and msg.reply_to_message_id_ or input:match('^-ساکت کردن') and is_mod(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,demute_reply,nil)
      end
      mu = input:match('^[/!#]muteuser (.*)') or input:match('^muteuser (.*)') or input:match('^ساکت کردن (.*)')
      if mu and is_mod(msg) then
        redis:sadd('muteusers:'..chat_id,mu)
        redis:set('tbt:'..chat_id,'yes')
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..mu..'🔇 به `لیست ساکت شدگان` افزوده شد\n🎗 ', 1, 'md')
      end
      umu = input:match('^[/!#]unmuteuser (.*)') or input:match('^unmuteuser (.*)') or input:match('^-ساکت کردن (.*)')
      if umu and is_mod(msg) then
        redis:srem('muteusers:'..chat_id,umu)
        tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅 #کاربر '..umu..'🔊 از `لیست ساکت شدگان` حذف شد\n🎗 ', 1, 'md')
      end
      if input:match('^[/!#]muteusers') and is_mod(msg) or input:match('^muteusers') and is_mod(msg) or input:match('^لیست ساکت شدگان') and is_mod(msg) then
        if redis:scard('muteusers:'..chat_id) == 0 then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '🏅🔇گروه هیچ `فرد ساکت شده ای` ندارد🏅', 1, 'md')
        end
        local text = "🏅🔉لیست ساکت شدگان:\n"
        for k,v in pairs(redis:smembers('muteusers:'..chat_id)) do
          text = text.."<b>"..k.."</b> - <b>"..v.."</b>\n"
        end
        tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'html')
      end
-------------------------------------------------------
			
         --lock links
			
     groups = redis:sismember('groups',chat_id)

    if input:match("^قفل لینک$") and is_sudo(msg) and groups then
       if redis:get('lock_linkstg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>لینک از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('lock_linkstg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '_لینک قفل شد_', 1, 'md')
      end
      end 
      if input:match("^بازکردن لینک$")  and is_sudo(msg) and groups then
       if not redis:get('lock_linkstg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>لینک از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('lock_linkstg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>لینک آزاد شد✅<🚏>', 1, 'md')
      end
      end
	  --lock username
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل یوزرنیم$") and is_sudo(msg) and groups then
       if redis:get('usernametg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>ارسال یوزرنیم از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('usernametg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>ارسال یوزرنیم قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن یوزرنیم$") and is_sudo(msg) and groups then
       if not redis:get('usernametg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>ارسال یوزرنیم از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('usernametg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>ارسال یوزرنیم آزاد شد<🚏>', 1, 'md')
      end
      end
	  --lock tag
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل تگ$") and is_sudo(msg) and groups then
       if redis:get('tagtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>ارسال تگ از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('tagtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>ارسال تگ قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن تگ$") and is_sudo(msg) and groups then
       if not redis:get('tagtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>ارسال تگ از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('tagtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>ارسال تگ آزاد شد<🚏>', 1, 'md')
      end
      end
	  --lock forward
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل فروارد$") and is_sudo(msg) and groups then
       if redis:get('forwardtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>فروارد کردن از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('forwardtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>فروارد کردن قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن فروارد$") and is_sudo(msg) and groups then
       if not redis:get('forwardtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>فروارد کردن از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('forwardtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>فروارد کردن آزاد شد<🚏>', 1, 'md')
      end
      end
	  --arabic/persian
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل عربی$") and is_sudo(msg) and groups then
       if redis:get('arabictg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>استفاده از کلمات عربی از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('arabictg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>استفاده از کلمات عربی قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن عربی$") and is_sudo(msg) and groups then
       if not redis:get('arabictg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>استفاده از کلمات عربی از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('arabictg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>استفاده از کلمات عربی آزاد شد<🚏>', 1, 'md')
      end
      end
	 ---english
	 groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل انگلیسی$") and is_sudo(msg) and groups then
       if redis:get('engtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>استفاده از کلمات انگلیسی از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('engtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>استفاده از کلمات انگلیسی قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن انگلیسی$") and is_sudo(msg) and groups then
       if not redis:get('engtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>استفاده از کلمات انگلیسی از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('engtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>استفاده از کلمات انگلیسی آزاد شد<🚏>', 1, 'md')
      end
      end
	  --lock foshtg
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل فحش$") and is_sudo(msg) and groups then
       if redis:get('badwordtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>فحش از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('badwordtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>فحش ممنوع شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن فحش$") and is_sudo(msg) and groups then
       if not redis:get('badwordtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>فحش از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('badwordtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>فحش آزاد شد<🚏>', 1, 'md')
      end
      end
	  --lock edit
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل ویرایش$") and is_sudo(msg) and groups then
       if redis:get('edittg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>ویرایش از قبل ممنوع بود<🚏>', 1, 'md')
       else 
        redis:set('edittg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>ویرایش قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن ویرایش$") and is_sudo(msg) and groups then
       if not redis:get('edittg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>ویرایش از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('edittg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>ویرایش آزاد شد<🚏>', 1, 'md')
      end
      end
	  --lock emoji
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل ایموجی") and is_sudo(msg) and groups then
       if redis:get('emojitg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>شکلک از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('emojitg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>شکلک قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن ایموجی$") and is_sudo(msg) and groups then
       if not redis:get('emojitg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>شکلک از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('emojitg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>شکلک آزاد شد<🚏>', 1, 'md')
      end
      end
	  --lock tgservice
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^قفل سرویس$") and is_sudo(msg) and groups then
       if redis:get('tgservice:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>سرویس ها از قبل قفل بود<🚏>', 1, 'md')
       else 
        redis:set('tgservice:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>سرویس ها قفل شد<🚏>', 1, 'md')
      end
      end 
      if input:match("^بازکردن سرویس$") and is_sudo(msg) and groups then
       if not redis:get('tgservice:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<🚏>سرویس ها از قبل آزاد بود<🚏>', 1, 'md')
       else
         redis:del('tgservice:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #تایید شد\n<🚏>سرویس ها آزاد شد<🚏>', 1, 'md')
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
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال همه چی از قبل ممنوع بود<🚏>*', 1, 'md')
       else 
       redis:set('mute_alltg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال همه چی ممنوع است<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن همه$") and is_sudo(msg) and groups then
       if not redis:get('mute_alltg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال همخ چی از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_alltg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال همه چی آزاد شد<🚏>*', 1, 'md')
      end
      end	 

--mute sticker
groups = redis:sismember('groups',chat_id)
if input:match("^ممنوعیت استیکر$") and is_sudo(msg) and groups then
       if redis:get('mute_stickertg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال استیکر از قبل قفل بود<🚏>*', 1, 'md')
       else
        redis:set('mute_stickertg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>رسال استیکر ممنوع است<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن استیکر$") and is_sudo(msg) and groups then
       if not redis:get('mute_stickertg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>رسال استیکر از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_stickertg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال استیکر آزاد شد<🚏>*', 1, 'md')
      end
      end		  
	  --mute gift
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت گیف$") and is_sudo(msg) and groups then
       if redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال گیفاز قبل قفل بود<🚏>*', 1, 'md')
       else 
        redis:set('mute_contacttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال گیف قفل شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن گیف$") and is_sudo(msg) and groups then
       if not redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال گیف از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_contacttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>گیف آزاد شد<🚏>*', 1, 'md')
      end
      end
	  --mute contact
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت شماره$") and is_sudo(msg) and groups then
       if redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال شماره از قبل ممنوع بود<🚏>*', 1, 'md')
       else 
        redis:set('mute_contacttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال شماره ممنوع شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن شماره$") and is_sudo(msg) and groups then
       if not redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال شماره از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_contacttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال شماره آزاد شد<🚏>*', 1, 'md')
      end
      end
	  --mute photo
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت عکس$") and is_sudo(msg) and groups then
       if redis:get('mute_phototg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال عکس از قبل ممنوع بود<🚏>*', 1, 'md')
       else 
        redis:set('mute_phototg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال عکس ممنوع شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن عکس$") and is_sudo(msg) and groups then
       if not redis:get('mute_phototg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال عکس از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_phototg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال عکس آزاد شد<🚏>*', 1, 'md')
      end
      end
	  --mute audio
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^ممنوعیت آهنگ$") and is_sudo(msg) and groups then
       if redis:get('mute_audiotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال آهنگ از قبل ممنوع بود<🚏>*', 1, 'md')
       else 
        redis:set('mute_audiotg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال آهنگ ممنوع شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن آهنگ$") and is_sudo(msg) and groups then
       if not redis:get('mute_audiotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال آهنگ از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_audiotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال آهنگ آزاد شد<🚏>*', 1, 'md')
	  end
      end
		--mute voice
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت صدا$") and is_sudo(msg) and groups then
       if redis:get('mute_voicetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال صدا از قبل ممنوع بود<🚏>*', 1, 'md')
       else 
        redis:set('mute_voicetg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال صدا ممنوع شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن صدا$") and is_sudo(msg) and groups then
       if not redis:get('mute_voicetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال صدا از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_videotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال صدا آزاد شد<🚏>*', 1, 'md')
		end
		end
		--mute video
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت فیلم $") and is_sudo(msg) and groups then
       if redis:get('mute_videotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال فیلم از قبل ممنوع بود<🚏>*', 1, 'md')
       else 
        redis:set('mute_videotg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال فیلم ممنوع شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن فیلم$") and is_sudo(msg) and groups then
       if not redis:get('mute_videotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال فیلم از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_videotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال فیلم آزاد شد<🚏>*', 1, 'md')
		end
		end
		--mute document
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت یاداشت$") and is_sudo(msg) and groups then
       if redis:get('mute_documenttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال یاداشت از قبل ممنوع بود<🚏>*', 1, 'md')
       else 
        redis:set('mute_documenttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال یاداشت ممنوع شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن یاداشت$") and is_sudo(msg) and groups then
       if not redis:get('mute_documenttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال یاداشت از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_documenttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال یاداشت آزاد شد<🚏>*', 1, 'md')
		end
		end
		--mute  text
		groups = redis:sismember('groups',chat_id)
		if input:match("^ممنوعیت متن$") and is_sudo(msg) and groups then
       if redis:get('mute_texttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال متن از قبل ممنوع بود</b>*', 1, 'md')
       else 
        redis:set('mute_texttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال یاداشت قفل شد<🚏>*', 1, 'md')
      end
      end
      if input:match("^بازکردن متن$") and is_sudo(msg) and groups then
       if not redis:get('mute_texttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال متن از قبل آزاد بود<🚏>*', 1, 'md')
       else 
         redis:del('mute_texttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال متن آزاد شد<🚏>*', 1, 'md')
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
		local text = "💈تنظیمات سوپرگروه💈".."\n"
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
    -- @Senator_tea
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
