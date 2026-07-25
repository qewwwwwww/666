local selfUrl = "https://raw.githubusercontent.com/qewwwwwww/666/main/%E8%87%AA%E5%90%AF%E5%8A%A8.lua"
local cmd = "loadstring(game:HttpGet('" .. selfUrl .. "'))()"

pcall(function() if syn and syn.queue_on_teleport then syn.queue_on_teleport(cmd) end end)
pcall(function() if queue_on_teleport then queue_on_teleport(cmd) end end)
pcall(function() if KRNL and KRNL.queue_on_teleport then KRNL.queue_on_teleport(cmd) end end)
pcall(function() if fluxus and fluxus.queue_on_teleport then fluxus.queue_on_teleport(cmd) end end)

-- 首次也顺手跑主脚本（主脚本链写在 loader 里）
loadstring(game:HttpGet("https://raw.githubusercontent.com/qewwwwwww/666/main/%E5%88%B7%E5%80%BA%E5%88%B8.lua"))()
