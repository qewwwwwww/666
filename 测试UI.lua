-- CustomWindUI v2.0 - 基于WindUI的定制版本
-- 包含您的所有需求：玻璃材质、最小化、标签页、多选、图片视频查看等

local a a={cache={}, load=function(b)if not a.cache[b]then a.cache[b]={c=a[b]()}end return a.cache[b].c end}do function a.a()return{
    -- 主色调
    Primary=Color3.fromHex("#0091FF"),
    White=Color3.new(1,1,1),
    Black=Color3.new(0,0,0),
    
    -- 窗口相关
    Background=Color3.fromHex("#101010"),
    BackgroundTransparency=0.1,  -- 玻璃材质透明度
    WindowBackground="Background",
    WindowShadow="Black",
    
    -- 标题栏
    WindowTopbarTitle="Text",
    WindowTopbarAuthor="Text",
    WindowTopbarIcon="Icon",
    WindowTopbarButtonIcon="Icon",
    
    -- 标签页
    TabBackground="Hover",
    TabTitle="Text",
    TabIcon="Icon",
    
    -- 元素
    ElementBackground="Text",
    ElementTitle="Text",
    ElementDesc="Text",
    ElementIcon="Icon",
    
    -- 按钮
    Button=Color3.fromHex("#52525b"),
    ButtonHover=Color3.fromHex("#71717a",
    
    -- 开关
    Toggle=Color3.fromHex("#33C759",
    ToggleBar="White",
    
    -- 多选框
    Checkbox=Color3.fromHex("#0091FF",
    CheckboxIcon="White",
    
    -- 滑块
    Slider=Color3.fromHex("#0091FF",
    SliderThumb="White",
    
    -- 文本
    Text=Color3.fromHex("#FFFFFF",
    Placeholder=Color3.fromHex("#7a7a7a",
    
    -- 图标
    Icon=Color3.fromHex("#a1a1aa",
    
    -- 工具提示
    Tooltip=Color3.fromHex("4C4C4C",
    TooltipText="White",
}end

-- 基础服务
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- 窗口管理器
local WindowManager = {}
WindowManager.Windows = {}
WindowManager.ActiveWindow = nil

-- 主题管理器
local ThemeManager = {
    CurrentTheme = "Dark",
    Themes = {
        Dark = a.load'a',
        Light = {
            Background = Color3.fromHex("#f4f4f5",
            Text = Color3.fromHex("#000000",
            Button = Color3.fromHex("#18181b",
        },
        Glass = {
            Background = Color3.fromHex("#101010",
            BackgroundTransparency = 0.2,
            Text = Color3.fromHex("#FFFFFF",
        }
    }
}

-- 创建主窗口类
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    
    self.Config = {
        Title = config.Title or "WindUI Window",
        Size = config.Size or Vector2.new(400, 500),
        Position = config.Position or UDim2.new(0.5, -200, 0.5, -250),
        MinSize = config.MinSize or Vector2.new(300, 200),
        MaxSize = config.MaxSize or Vector2.new(800, 600),
        ShowTitle = config.ShowTitle ~= false,
        ShowMinimize = config.ShowMinimize ~= false,
        ShowClose = config.ShowClose ~= false,
        Draggable = config.Draggable ~= false,
        Resizable = config.Resizable ~= false,
        CornerRadius = config.CornerRadius or 12,
        Theme = config.Theme or "Dark",
        GlassEffect = config.GlassEffect or true,
        BlurIntensity = config.BlurIntensity or 0.8,
        AutoSavePosition = config.AutoSavePosition or false,
    }
    
    self.UIElements = {}
    self.Tabs = {}
    self.CurrentTab = nil
    self.SelectedOptions = {}
    self.MultiSelectGroups = {}
    
    self:Initialize()
    return self
end

function Window:Initialize()
    -- 创建屏幕GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "WindUI_" .. HttpService:GenerateGUID(false)
    self.ScreenGui.DisplayOrder = 100
    self.ScreenGui.IgnoreGuiInset = true
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = CoreGui
    
    -- 创建主窗口
    self.MainWindow = Instance.new("Frame")
    self.MainWindow.Name = "MainWindow"
    self.MainWindow.Size = UDim2.new(0, self.Config.Size.X, 0, self.Config.Size.Y)
    self.MainWindow.Position = self.Config.Position
    self.MainWindow.BackgroundTransparency = self.Config.GlassEffect and 0.2 or 0
    self.MainWindow.BackgroundColor3 = ThemeManager.Themes[self.Config.Theme].Background
    self.MainWindow.BorderSizePixel = 0
    self.MainWindow.ClipsDescendants = true
    self.MainWindow.Active = true
    self.MainWindow.Draggable = self.Config.Draggable
    self.MainWindow.Parent = self.ScreenGui
    
    -- 圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, self.Config.CornerRadius)
    corner.Parent = self.MainWindow
    
    -- 阴影效果
    if self.Config.GlassEffect then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "DropShadow"
        shadow.Size = UDim2.new(1, 12, 1, 12)
        shadow.Position = UDim2.new(0, -6, 0, -6)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236801"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.7
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.ZIndex = -1
        shadow.Parent = self.MainWindow
    end
    
    -- 标题栏
    if self.Config.ShowTitle then
        self:CreateTitleBar()
    end
    
    -- 内容区域
    self:CreateContentArea()
    
    -- 最小化按钮
    if self.Config.ShowMinimize then
        self:CreateMinimizeButton()
    end
    
    -- 关闭按钮
    if self.Config.ShowClose then
        self:CreateCloseButton()
    end
    
    -- 窗口控制
    self:SetupWindowControls()
    
    table.insert(WindowManager.Windows, self)
    WindowManager.ActiveWindow = self
end

function Window:CreateTitleBar()
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundTransparency = 1
    self.TitleBar.Parent = self.MainWindow
    
    -- 标题文本
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "Title"
    self.TitleText.Size = UDim2.new(1, -60, 1, 0)
    self.TitleText.Position = UDim2.new(0, 10, 0, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Text = self.Config.Title
    self.TitleText.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    self.TitleText.Font = Enum.Font.GothamMedium
    self.TitleText.TextSize = 16
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.Parent = self.TitleBar
    
    self.UIElements.TitleBar = self.TitleBar
    self.UIElements.TitleText = self.TitleText
end

function Window:CreateContentArea()
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Name = "ContentArea"
    self.ContentArea.Size = UDim2.new(1, 0, 1, -30)
    self.ContentArea.Position = UDim2.new(0, 0, 0, 30)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.MainWindow
    
    -- 标签页容器
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 120, 1, 0)
    self.TabContainer.BackgroundColor3 = Color3.fromRGB(230, 230, 245)
    self.TabContainer.BackgroundTransparency = 0.9
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.ContentArea
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, self.Config.CornerRadius)
    tabCorner.Parent = self.TabContainer
    
    -- 标签页列表
    self.TabList = Instance.new("ScrollingFrame")
    self.TabList.Name = "TabList"
    self.TabList.Size = UDim2.new(1, 0, 1, 0)
    self.TabList.BackgroundTransparency = 1
    self.TabList.BorderSizePixel = 0
    self.TabList.ScrollBarThickness = 4
    self.TabList.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 220)
    self.TabList.Parent = self.TabContainer
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = self.TabList
    
    -- 内容页面容器
    self.ContentPages = Instance.new("Frame")
    self.ContentPages.Name = "ContentPages"
    self.ContentPages.Size = UDim2.new(1, -120, 1, 0)
    self.ContentPages.Position = UDim2.new(0, 120, 0, 0)
    self.ContentPages.BackgroundTransparency = 1
    self.ContentPages.ClipsDescendants = true
    self.ContentPages.Parent = self.ContentArea
    
    self.UIElements.ContentArea = self.ContentArea
    self.UIElements.TabContainer = self.TabContainer
    self.UIElements.TabList = self.TabList
    self.UIElements.ContentPages = self.ContentPages
end

function Window:CreateMinimizeButton()
    self.MinimizeButton = Instance.new("TextButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    self.MinimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    self.MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    self.MinimizeButton.BackgroundColor3 = Color3.fromRGB(220, 220, 240)
    self.MinimizeButton.BackgroundTransparency = 0.8
    self.MinimizeButton.AutoButtonColor = false
    self.MinimizeButton.Text = "_"
    self.MinimizeButton.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    self.MinimizeButton.Font = Enum.Font.GothamBold
    self.MinimizeButton.TextSize = 20
    self.MinimizeButton.TextYAlignment = Enum.TextYAlignment.Bottom
    self.MinimizeButton.Parent = self.TitleBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.MinimizeButton
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.UIElements.MinimizeButton = self.MinimizeButton
end

function Window:CreateCloseButton()
    self.CloseButton = Instance.new("TextButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 25, 0, 25)
    self.CloseButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    self.CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    self.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    self.CloseButton.BackgroundTransparency = 0.8
    self.CloseButton.AutoButtonColor = false
    self.CloseButton.Text = "×"
    self.CloseButton.TextColor3 = Color3.new(1, 1, 1)
    self.CloseButton.Font = Enum.Font.GothamBold
    self.CloseButton.TextSize = 20
    self.CloseButton.Parent = self.TitleBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.CloseButton
    
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    self.UIElements.CloseButton = self.CloseButton
end

function Window:SetupWindowControls()
    -- 窗口拖动
    if self.Config.Draggable then
        self:SetupDragging()
    end
    
    -- 窗口大小调整
    if self.Config.Resizable then
        self:SetupResizing()
    end
end

function Window:SetupDragging()
    local dragStart
    local startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = self.MainWindow.Position
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            self.MainWindow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Window:SetupResizing()
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.ZIndex = 2
    resizeHandle.Parent = self.MainWindow
    
    local isResizing = false
    local resizeStart
    local originalMousePos
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = true
            resizeStart = Vector2.new(self.MainWindow.AbsoluteSize.X, self.MainWindow.AbsoluteSize.Y)
            originalMousePos = UserInputService:GetMouseLocation()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseDelta = UserInputService:GetMouseLocation() - originalMousePos
            local newSize = Vector2.new(
                math.max(self.Config.MinSize.X, resizeStart.X + mouseDelta.X),
                math.max(self.Config.MinSize.Y, resizeStart.Y + mouseDelta.Y)
            )
            self.MainWindow.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = false
        end
    end)
end

-- 标签页系统
function Window:AddTab(tabName, tabIcon)
    local tab = {
        Name = tabName,
        Icon = tabIcon,
        Page = nil,
        Button = nil,
        Elements = {}
    }
    
    -- 创建标签按钮
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(0.9, 0, 0, 40)
    tabButton.Position = UDim2.new(0.05, 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
    tabButton.BackgroundTransparency = 0.9
    tabButton.AutoButtonColor = false
    tabButton.Text = tabIcon and tabIcon .. " " .. tabName or tabName
    tabButton.TextColor3 = Color3.fromRGB(80, 80, 100)
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextSize = 14
    tabButton.LayoutOrder = #self.Tabs
    tabButton.Parent = self.TabList
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = tabButton
    
    -- 创建标签页面
    local tabPage = Instance.new("ScrollingFrame")
    tabPage.Name = tabName .. "Page"
    tabPage.Size = UDim2.new(1, 0, 1, 0)
    tabPage.BackgroundTransparency = 1
    tabPage.Visible = false
    tabPage.BorderSizePixel = 0
    tabPage.ScrollBarThickness = 4
    tabPage.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 220)
    tabPage.Parent = self.ContentPages
    
    local pageListLayout = Instance.new("UIListLayout")
    pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageListLayout.Padding = UDim.new(0, 10)
    pageListLayout.Parent = tabPage
    
    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 10)
    pagePadding.PaddingLeft = UDim.new(0, 10)
    pagePadding.PaddingRight = UDim.new(0, 10)
    pagePadding.Parent = tabPage
    
    tab.Button = tabButton
    tab.Page = tabPage
    
    -- 标签切换事件
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    table.insert(self.Tabs, tab)
    
    -- 如果是第一个标签，设为当前
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    return tab
end

function Window:SwitchTab(tab)
    -- 隐藏所有标签页
    for _, t in ipairs(self.Tabs) do
        if t.Page then
            t.Page.Visible = false
        end
        if t.Button then
            t.Button.BackgroundTransparency = 0.9
            t.Button.TextColor3 = Color3.fromRGB(80, 80, 100)
        end
    end
    
    -- 显示选中的标签页
    if tab.Page then
        tab.Page.Visible = true
    end
    if tab.Button then
        tab.Button.BackgroundTransparency = 0.8
        tab.Button.TextColor3 = Color3.fromRGB(50, 100, 255)
    end
    
    self.CurrentTab = tab
end

-- 元素创建函数
function Window:CreateElement(elementType, config, tab)
    tab = tab or self.CurrentTab
    if not tab then return nil end
    
    local element
    
    if elementType == "Toggle" then
        element = self:CreateToggle(config, tab)
    elseif elementType == "Checkbox" then
        element = self:CreateCheckbox(config, tab)
    elseif elementType == "Button" then
        element = self:CreateButton(config, tab)
    elseif elementType == "Slider" then
        element = self:CreateSlider(config, tab)
    elseif elementType == "Input" then
        element = self:CreateInput(config, tab)
    elseif elementType == "Dropdown" then
        element = self:CreateDropdown(config, tab)
    elseif elementType == "Label" then
        element = self:CreateLabel(config, tab)
    elseif elementType == "Divider" then
        element = self:CreateDivider(config, tab)
    elseif elementType == "ImageViewer" then
        element = self:CreateImageViewer(config, tab)
    elseif elementType == "VideoPlayer" then
        element = self:CreateVideoPlayer(config, tab)
    end
    
    if element then
        table.insert(tab.Elements, element)
    end
    
    return element
end

-- 多选系统
function Window:CreateMultiSelectGroup(groupName, options, tab)
    tab = tab or self.CurrentTab
    local group = {
        Name = groupName,
        Options = {},
        Selected = {}
    }
    
    for _, option in ipairs(options) do
        local checkbox = self:CreateCheckbox({
            Title = option.Title,
            Desc = option.Desc,
            Group = groupName,
            Callback = function(isChecked)
                if isChecked then
                    table.insert(group.Selected, option.Value)
                else
                    for i, val in ipairs(group.Selected) do
                        if val == option.Value then
                            table.remove(group.Selected, i)
                            break
                        end
                    end
                end
                
                -- 更新多选框的选中样式
                for _, opt in ipairs(group.Options) do
                    if opt.Value == option.Value then
                        self:UpdateCheckboxSelection(opt.Checkbox, isChecked)
                        break
                    end
                end
            end
        }, tab)
        
        table.insert(group.Options, {
            Title = option.Title,
            Value = option.Value,
            Checkbox = checkbox
        })
    end
    
    self.MultiSelectGroups[groupName] = group
    return group
end

function Window:UpdateCheckboxSelection(checkbox, isSelected)
    if not checkbox then return end
    
    local selectionGlow = checkbox:FindFirstChild("SelectionGlow")
    if selectionGlow then
        selectionGlow.Visible = isSelected
    end
    
    local checkMark = checkbox:FindFirstChild("CheckMark")
    if checkMark then
        checkMark.ImageTransparency = isSelected and 0 or 1
    end
end

-- 创建各种UI元素的具体实现
function Window:CreateToggle(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Toggle"
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
    background.BackgroundTransparency = 0.9
    background.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = background
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Title
    label.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- 开关按钮
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(0, 50, 0, 25)
    toggleFrame.Position = UDim2.new(1, -60, 0.5, -12.5)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    toggleFrame.BackgroundTransparency = 0.8
    toggleFrame.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12.5)
    toggleCorner.Parent = toggleFrame
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 21, 0, 21)
    toggleButton.Position = UDim2.new(0, 2, 0, 2)
    toggleButton.BackgroundColor3 = Color3.fromHex("#33C759")
    toggleButton.BackgroundTransparency = 0.3
    toggleButton.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10.5)
    buttonCorner.Parent = toggleButton
    
    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 2
    clickArea.Parent = toggleFrame
    
    local isEnabled = config.Default or false
    
    local function updateToggle()
        if isEnabled then
            toggleButton:TweenPosition(UDim2.new(1, -23, 0, 2), "Out", "Quad", 0.2)
            toggleButton.BackgroundColor3 = Color3.fromHex("#33C759")
        else
            toggleButton:TweenPosition(UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.2)
            toggleButton.BackgroundColor3 = Color3.fromHex("#e53935")
        end
    end
    
    clickArea.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        updateToggle()
        if config.Callback then
            config.Callback(isEnabled)
        end
    end)
    
    updateToggle()
    
    frame.Parent = tab.Page
    return frame
end

function Window:CreateCheckbox(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Checkbox"
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
    background.BackgroundTransparency = 0.9
    background.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = background
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Title
    label.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    -- 多选框
    local checkBox = Instance.new("Frame")
    checkBox.Name = "CheckBox"
    checkBox.Size = UDim2.new(0, 24, 0, 24)
    checkBox.Position = UDim2.new(1, -34, 0.5, -12)
    checkBox.BackgroundColor3 = Color3.fromRGB(220, 220, 240)
    checkBox.BackgroundTransparency = 0.7
    checkBox.Parent = frame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 6)
    checkCorner.Parent = checkBox
    
    local checkMark = Instance.new("ImageLabel")
    checkMark.Name = "CheckMark"
    checkMark.Size = UDim2.new(0.7, 0, 0.7, 0)
    checkMark.Position = UDim2.new(0.15, 0, 0.15, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Image = "rbxassetid://3926305904"
    checkMark.ImageRectOffset = Vector2.new(564, 284)
    checkMark.ImageRectSize = Vector2.new(36, 36)
    checkMark.ImageTransparency = 1
    checkMark.Parent = checkBox
    
    -- 选中时的玻璃材质框选效果
    local selectionGlow = Instance.new("Frame")
    selectionGlow.Name = "SelectionGlow"
    selectionGlow.Size = UDim2.new(1, 4, 1, 4)
    selectionGlow.Position = UDim2.new(0, -2, 0, -2)
    selectionGlow.BackgroundColor3 = Color3.fromHex("#0091FF")
    selectionGlow.BackgroundTransparency = 0.8
    selectionGlow.Visible = false
    selectionGlow.ZIndex = -1
    selectionGlow.Parent = checkBox
    
    local selectionCorner = Instance.new("UICorner")
    selectionCorner.CornerRadius = UDim.new(0, 8)
    selectionCorner.Parent = selectionGlow
    
    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 2
    clickArea.Parent = frame
    
    local isSelected = config.Default or false
    
    local function updateCheckbox()
        checkMark.ImageTransparency = isSelected and 0 or 1
        selectionGlow.Visible = isSelected
        
        -- 如果是多选组，更新组选择
        if config.Group then
            self.SelectedOptions[config.Title] = isSelected
        end
    end
    
    clickArea.MouseButton1Click:Connect(function()
        isSelected = not isSelected
        updateCheckbox()
        if config.Callback then
            config.Callback(isSelected)
        end
    end)
    
    updateCheckbox()
    
    frame.Parent = tab.Page
    return checkBox
end

function Window:CreateButton(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Button"
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
    background.BackgroundTransparency = 0.9
    background.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = background
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Title
    label.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local actionButton = Instance.new("TextButton")
    actionButton.Name = "ActionButton"
    actionButton.Size = UDim2.new(0, 80, 0, 30)
    actionButton.Position = UDim2.new(1, -90, 0.5, -15)
    actionButton.BackgroundColor3 = Color3.fromHex("#0091FF")
    actionButton.BackgroundTransparency = 0.7
    actionButton.Text = config.ButtonText or "执行"
    actionButton.TextColor3 = Color3.new(1, 1, 1)
    actionButton.Font = Enum.Font.GothamMedium
    actionButton.TextSize = 13
    actionButton.Parent = frame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = actionButton
    
    actionButton.MouseButton1Click:Connect(function()
        if config.Callback then
            config.Callback()
        end
    end)
    
    frame.Parent = tab.Page
    return frame
end

function Window:CreateImageViewer(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Image"
    frame.Size = UDim2.new(1, 0, 0, 200)
    frame.BackgroundTransparency = 1
    
    local imageContainer = Instance.new("Frame")
    imageContainer.Name = "ImageContainer"
    imageContainer.Size = UDim2.new(1, 0, 1, 0)
    imageContainer.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
    imageContainer.BackgroundTransparency = 0.9
    imageContainer.ClipsDescendants = true
    imageContainer.Parent = frame
    
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(0, 8)
    imageCorner.Parent = imageContainer
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "Image"
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = config.ImageUrl
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = imageContainer
    
    -- 控制栏
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(1, 0, 0, 30)
    controls.Position = UDim2.new(0, 0, 1, -30)
    controls.BackgroundColor3 = Color3.new(0, 0, 0)
    controls.BackgroundTransparency = 0.7
    controls.Parent = imageContainer
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeImage"
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.new(1, 1, 1)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 20
    minimizeButton.TextYAlignment = Enum.TextYAlignment.Bottom
    minimizeButton.Parent = controls
    
    local imageTitle = Instance.new("TextLabel")
    imageTitle.Name = "Title"
    imageTitle.Size = UDim2.new(1, -40, 1, 0)
    imageTitle.Position = UDim2.new(0, 10, 0, 0)
    imageTitle.BackgroundTransparency = 1
    imageTitle.Text = config.Title
    imageTitle.TextColor3 = Color3.new(1, 1, 1)
    imageTitle.Font = Enum.Font.GothamMedium
    imageTitle.TextSize = 14
    imageTitle.TextXAlignment = Enum.TextXAlignment.Left
    imageTitle.Parent = controls
    
    local isMinimized = false
    
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            imageContainer:TweenSize(UDim2.new(1, 0, 0, 40), "Out", "Quad", 0.3)
            frame:TweenSize(UDim2.new(1, 0, 0, 40), "Out", "Quad", 0.3)
        else
            imageContainer:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.3)
            frame:TweenSize(UDim2.new(1, 0, 0, 200), "Out", "Quad", 0.3)
        end
    end)
    
    frame.Parent = tab.Page
    return frame
end

function Window:CreateVideoPlayer(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Video"
    frame.Size = UDim2.new(1, 0, 0, 220)
    frame.BackgroundTransparency = 1
    
    local videoContainer = Instance.new("Frame")
    videoContainer.Name = "VideoContainer"
    videoContainer.Size = UDim2.new(1, 0, 1, 0)
    videoContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    videoContainer.BackgroundTransparency = 0.9
    videoContainer.ClipsDescendants = true
    videoContainer.Parent = frame
    
    local videoCorner = Instance.new("UICorner")
    videoCorner.CornerRadius = UDim.new(0, 8)
    videoCorner.Parent = videoContainer
    
    local videoLabel = Instance.new("VideoFrame")
    videoLabel.Name = "VideoPlayer"
    videoLabel.Size = UDim2.new(1, 0, 1, 0)
    videoLabel.BackgroundTransparency = 1
    videoLabel.Looped = true
    videoLabel.Video = config.VideoUrl
    videoLabel.Parent = videoContainer
    
    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(1, 0, 0, 30)
    controls.Position = UDim2.new(0, 0, 1, -30)
    controls.BackgroundColor3 = Color3.new(0, 0, 0)
    controls.BackgroundTransparency = 0.7
    controls.Parent = videoContainer
    
    local playButton = Instance.new("TextButton")
    playButton.Name = "PlayButton"
    playButton.Size = UDim2.new(0, 60, 0, 25)
    playButton.Position = UDim2.new(0, 10, 0.5, -12.5)
    playButton.BackgroundColor3 = Color3.fromHex("#0091FF")
    playButton.BackgroundTransparency = 0.5
    playButton.Text = "播放"
    playButton.TextColor3 = Color3.new(1, 1, 1)
    playButton.Font = Enum.Font.GothamMedium
    playButton.TextSize = 13
    playButton.Parent = controls
    
    local playCorner = Instance.new("UICorner")
    playCorner.CornerRadius = UDim.new(0, 6)
    playCorner.Parent = playButton
    
    local videoTitle = Instance.new("TextLabel")
    videoTitle.Name = "Title"
    videoTitle.Size = UDim2.new(1, -80, 1, 0)
    videoTitle.Position = UDim2.new(0, 80, 0, 0)
    videoTitle.BackgroundTransparency = 1
    videoTitle.Text = config.Title
    videoTitle.TextColor3 = Color3.new(1, 1, 1)
    videoTitle.Font = Enum.Font.GothamMedium
    videoTitle.TextSize = 14
    videoTitle.TextXAlignment = Enum.TextXAlignment.Left
    videoTitle.Parent = controls
    
    playButton.MouseButton1Click:Connect(function()
        if videoLabel.Playing then
            videoLabel.Pause()
            playButton.Text = "播放"
        else
            videoLabel.Play()
            playButton.Text = "暂停"
        end
    end)
    
    frame.Parent = tab.Page
    return frame
end

-- 其他简化版本的创建函数
function Window:CreateLabel(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Label"
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text
    label.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = config.TextSize or 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    frame.Parent = tab.Page
    return frame
end

function Window:CreateDivider(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = "Divider"
    frame.Size = UDim2.new(1, 0, 0, 1)
    frame.BackgroundTransparency = 0
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -20, 1, 0)
    line.Position = UDim2.new(0, 10, 0, 0)
    line.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    line.BackgroundTransparency = 0.7
    line.Parent = frame
    
    frame.Parent = tab.Page
    return frame
end

function Window:CreateInput(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Input"
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
    background.BackgroundTransparency = 0.9
    background.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = background
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Title
    label.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "InputBox"
    textBox.Size = UDim2.new(0, 150, 0, 30)
    textBox.Position = UDim2.new(1, -160, 0.5, -15)
    textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textBox.BackgroundTransparency = 0.9
    textBox.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 13
    textBox.PlaceholderText = config.Placeholder or ""
    textBox.Parent = frame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 6)
    textBoxCorner.Parent = textBox
    
    if config.Callback then
        textBox.FocusLost:Connect(function()
            config.Callback(textBox.Text)
        end)
    end
    
    frame.Parent = tab.Page
    return frame
end

function Window:CreateSlider(config, tab)
    local frame = Instance.new("Frame")
    frame.Name = config.Title .. "Slider"
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
    background.BackgroundTransparency = 0.9
    background.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = background
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 0.5, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Title
    label.TextColor3 = ThemeManager.Themes[self.Config.Theme].Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "Slider"
    sliderFrame.Size = UDim2.new(0.8, 0, 0, 4)
    sliderFrame.Position = UDim2.new(0.1, 0, 0.7, 0)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 220)
    sliderFrame.BackgroundTransparency = 0.7
    sliderFrame.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromHex("#0091FF")
    fill.BackgroundTransparency = 0.3
    fill.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(0.5, -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromHex("#0091FF")
    thumb.BackgroundTransparency = 0.2
    thumb.Parent = sliderFrame
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb
    
    frame.Parent = tab.Page
    return frame
end

-- 窗口控制函数
function Window:ToggleMinimize()
    if not self.IsMinimized then
        self.OriginalSize = Vector2.new(self.MainWindow.AbsoluteSize.X, self.MainWindow.AbsoluteSize.Y)
        self.OriginalPosition = self.MainWindow.Position
        
        self.MainWindow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.3)
        self.MainWindow:TweenPosition(UDim2.new(1, 0, 1, 0), "Out", "Quad", 0.3)
        self.IsMinimized = true
    else
        self.MainWindow:TweenSize(UDim2.new(0, self.OriginalSize.X, 0, self.OriginalSize.Y), "Out", "Quad", 0.3)
        self.MainWindow:TweenPosition(self.OriginalPosition, "Out", "Quad", 0.3)
        self.IsMinimized = false
    end
end

function Window:Close()
    self.ScreenGui:Destroy()
    
    for i, window in ipairs(WindowManager.Windows) do
        if window == self then
            table.remove(WindowManager.Windows, i)
            break
        end
    end
    
    if WindowManager.ActiveWindow == self then
        WindowManager.ActiveWindow = #WindowManager.Windows > 0 and WindowManager.Windows[#WindowManager.Windows] or nil
    end
end

function Window:SetTitle(title)
    self.Config.Title = title
    if self.TitleText then
        self.TitleText.Text = title
    end
end

function Window:SetSize(width, height)
    self.Config.Size = Vector2.new(width, height)
    self.MainWindow.Size = UDim2.new(0, width, 0, height)
end

function Window:SetPosition(position)
    self.MainWindow.Position = position
end

function Window:SetTheme(themeName)
    if ThemeManager.Themes[themeName] then
        self.Config.Theme = themeName
        self:ApplyTheme()
    end
end

function Window:ApplyTheme()
    local theme = ThemeManager.Themes[self.Config.Theme]
    
    if self.MainWindow then
        self.MainWindow.BackgroundColor3 = theme.Background
    end
    
    if self.TitleText then
        self.TitleText.TextColor3 = theme.Text
    end
end

-- 导出API
local CustomWindUI = {
    Window = Window,
    WindowManager = WindowManager,
    ThemeManager = ThemeManager,
    
    new = function(config)
        return Window.new(config)
    end,
    
    getActiveWindow = function()
        return WindowManager.ActiveWindow
    end,
    
    setTheme = function(themeName)
        ThemeManager.CurrentTheme = themeName
        for _, window in ipairs(WindowManager.Windows) do
            window:SetTheme(themeName)
        end
    end
}

-- 全局导出
getgenv().CustomWindUI = CustomWindUI

return CustomWindUI
