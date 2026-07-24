-- TX Bond 自启 Loader（外链版）
local url = "https://gist.githubusercontent.com/你的用户名/你的GistID/raw/你的文件名/tx_bond.lua" -- ← 替换成你的真实URL

-- 立即执行一次主脚本
pcall(function()
    loadstring(game:HttpGet(url))()
end)

-- 注册传送后自动执行（全注入器适配）
local function registerAutoExecute()
    local success = false
    pcall(function()
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport("loadstring(game:HttpGet('" .. url .. "'))()")
            success = true
        end
    end)
    pcall(function()
        if queue_on_teleport then
            queue_on_teleport("loadstring(game:HttpGet('" .. url .. "'))()")
            success = true
        end
    end)
    pcall(function()
        if KRNL and KRNL.queue_on_teleport then
            KRNL.queue_on_teleport("loadstring(game:HttpGet('" .. url .. "'))()")
            success = true
        end
    end)
    pcall(function()
        if fluxus and fluxus.queue_on_teleport then
            fluxus.queue_on_teleport("loadstring(game:HttpGet('" .. url .. "'))()")
            success = true
        end
    end)
    if not success then
        warn("⚠️ 未检测到支持的注入器，但仍会尝试运行主脚本")
    end
end

registerAutoExecute()

print("✅ TX Bond 自启加载器已初始化！现在你可以随意传送服务器，脚本会自动跟随。")
