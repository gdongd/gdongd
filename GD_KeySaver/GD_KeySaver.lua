-- ==============================================
-- GDKS 乌龟服 1.12 最终版（零语法错误）
-- ==============================================
_G.GDKS_ConfigDB = _G.GDKS_ConfigDB or {}

_G.GDKS_ActionBarDB = _G.GDKS_ActionBarDB or {}


_G.GDKS_BindingsDB = _G.GDKS_BindingsDB or {}
_G.GDKS_MacrosDB = _G.GDKS_MacrosDB or {}
_G.GDKS_MacrosDB["PublicMacros"] = _G.GDKS_MacrosDB["PublicMacros"] or {}
_G.GDKS_MacrosDB["CharacterMacros"] = _G.GDKS_MacrosDB["CharacterMacros"] or {}
_G.GDKS_MacrosDB["SuperMacros"] = _G.GDKS_MacrosDB["SuperMacros"] or {}

local defaultConfig = {
    framePoint = "CENTER", frameX = 0, frameY = 0,
}
for k, v in pairs(defaultConfig) do
    if _G.GDKS_ConfigDB[k] == nil then
        _G.GDKS_ConfigDB[k] = v
    end
end

-- ==============================================
-- 保存按键
-- ==============================================
local function saveAllKeyBindings(profileName)
    local realName = strtrim(profileName or "")
    if realName == "" then
        print("|cffff0000快捷键配置名称不能为空！|r")
        return false
    end
    _G.GDKS_BindingsDB = _G.GDKS_BindingsDB or {}
    _G.GDKS_BindingsDB[realName] = {}
    local actionCount = 0
    local keyCount = 0 
    for i = 1, GetNumBindings() do
        local cmd, k1, k2 = GetBinding(i)
        if cmd and cmd ~= "" and (k1 or k2) then
            k1 = k1 and tostring(k1) or ""
            k2 = k2 and tostring(k2) or ""
            if k1 ~= "" then
                keyCount = keyCount +1
            end
            if k2 ~= "" then
                keyCount = keyCount +1
            end
            table.insert(_G.GDKS_BindingsDB[realName], {
                cmd = cmd, key1 = k1, key2 = k2
            })
            actionCount = actionCount + 1
        end
    end

    if actionCount == 0 then
        print("|cffffdd00⚠️ 快捷键配置保存完成： |r" .. realName .. "（未检测到自定义按键绑定）")
    else
        print("|cff00ff00✅ 快捷键配置保存完成： |r" .. realName .. "（共保存" ..keyCount.. " 个快捷键， " .. actionCount ..  " 个按钮。）")
    end
    return true
end

-- ==============================================
-- 加载按键
-- ==============================================
local function loadAllKeyBindings(profileName)
    local realName = strtrim(profileName or "")
    if realName == "" then
        print("|cffff0000快捷键配置名称不能为空！|r")
        return false
    end

    if not _G.GDKS_BindingsDB[realName]  then
        print("|cffff0000快捷键配置：" ..realName.. "不存在！|r")
        return false
    end

    for i = 1, GetNumBindings() do
        local key1,key2 = GetBinding(i)
        if key1 ~= nil and key1 ~= "" then
            SetBinding(key1, "")
        end
        if key2 ~= nil and key2 ~= "" then
            SetBinding(key2, "")
        end
    end

    local actionCount = 0
    local keyCount = 0
    _G.GDKS_BindingsDB[realName] = _G.GDKS_BindingsDB[realName] or {}
    local bindings = _G.GDKS_BindingsDB[realName]
    for _, data in ipairs(bindings) do
        local cmd = data.cmd
        local key1 = data.key1 or ""
        local key2 = data.key2 or ""
        if cmd and cmd ~= "" then
            if key1 ~= "" then
                SetBinding(key1, cmd)
                keyCount = keyCount + 1
            end
            if key2 ~= "" then
                SetBinding(key2, cmd)
                keyCount = keyCount + 1
            end
            actionCount = actionCount + 1
        end
    end

    SaveBindings(GetCurrentBindingSet())
    if actionCount == 0 then
        print("|cffffdd00⚠️ 快捷键配置加载完成： |r" .. realName .. "（0个有效按键）")
    else
        print("|cff00ff00✅ 快捷键配置加载完成： |r" .. realName .. "（共加载 "..keyCount.." 个按快捷键， ".. actionCount .. " 个按钮。）" )
    end
    return true
end

-- ==============================================
-- 保存公用宏
-- ==============================================
local function savePMacros(profileName)
    local realName = strtrim(profileName or "")
    if realName == "" then
        print("|cffff0000配置名称不能为空！|r")
        return false
    end
    _G.GDKS_MacrosDB = _G.GDKS_MacrosDB or {}
    _G.GDKS_MacrosDB["PublicMacros"] = _G.GDKS_MacrosDB["PublicMacros"] or {}
    _G.GDKS_MacrosDB["PublicMacros"][realName] = {}
    local db = _G.GDKS_MacrosDB["PublicMacros"][realName] or {}
    local macrosNum = (GetNumMacros())
    for i = 1, macrosNum do
        local name, texture, body = GetMacroInfo(i)
        db[i] = {
            name = name,
            texture = texture,
            body = body  -- 补充保存宏内容
        }
    end
    print("|cff00ff00✅ 公用宏保存完成： |r" .. realName .. "（共保存 " .. macrosNum .. " 个公用宏）")
    return true
end 

-- ==============================================
-- 加载公用宏
-- ==============================================
local function loadPMacros(profileName)
    local realName = strtrim(profileName or "")
    if realName == "" then
        print("|cffff0000配置名称不能为空！|r")
        return false
    end

    -- 初始化数据库（防止空报错）
    _G.GDKS_MacrosDB = _G.GDKS_MacrosDB or {}
    _G.GDKS_MacrosDB["PublicMacros"] = _G.GDKS_MacrosDB["PublicMacros"] or {}
    
    -- 读取配置
    local db = _G.GDKS_MacrosDB["PublicMacros"][realName]
    if not db or next(db) == nil then
        print("|cff00ff00✅ 公用宏配置： |r" .. realName .. "（不存在或为空）")
        return false
    end

    -- ==============================================
    -- 修复 1：正确获取【公用宏数量】，只删公用宏，不删角色宏
    -- ==============================================
    local globalMacros, charMacros = GetNumMacros()
    -- 从后往前删，防止索引错乱（标准安全写法）
    for i = globalMacros, 1, -1 do
        DeleteMacro(i)
    end

    -- ==============================================
    -- 修复 2：从 1 开始创建公用宏
    -- ==============================================
    local count = 0
    for _, data in pairs(db) do
        local name = data.name or ""
        local texture = string.match(data.texture, [[([^\]+)$]]) or ""
        local body = data.body or ""
        CreateMacro( name, texture, body, true)
        count = count + 1
    end

    print("|cff00ff00✅ 公用宏加载完成： |r" .. realName .. "（共加载 " .. count .. " 个公用宏）")
    return true    
end

-- ==============================================
-- 保存角色宏
-- ==============================================
local function saveCMacros(profileName)
    local realName = strtrim(profileName or "")
    if realName == "" then
        print("|cffff0000配置名称不能为空！|r")
        return false
    end
    _G.GDKS_MacrosDB = _G.GDKS_MacrosDB or {}
    _G.GDKS_MacrosDB["CharacterMacros"] = _G.GDKS_MacrosDB["CharacterMacros"] or {}
    _G.GDKS_MacrosDB["CharacterMacros"][profileName] = {}
    local db = _G.GDKS_MacrosDB["CharacterMacros"][profileName] or {}
    local _, macrosNum = GetNumMacros()
    for i = 1, macrosNum do
        local name, texture, body = GetMacroInfo(i+18)
        db[ i+18 ] = {
            name = name,
            texture = texture,
            body = body  -- 补充保存宏内容
        }
    end
    print("|cff00ff00✅ 角色宏保存完成： |r" .. realName .. "（共保存 " .. macrosNum .. " 个角色宏）")
    return true
end 

-- ==============================================
-- 加载角色宏
-- ==============================================
local function loadCMacros(profileName)
    local realName = strtrim(profileName or "")
    if realName == "" then
        print("|cffff0000配置名称不能为空！|r")
        return false
    end
    _G.GDKS_MacrosDB = _G.GDKS_MacrosDB or {}
    _G.GDKS_MacrosDB["CharacterMacros"] = _G.GDKS_MacrosDB["CharacterMacros"] or {}
    local db = _G.GDKS_MacrosDB["CharacterMacros"][realName]
    if db == nil then
        print("|cff00ff00✅ 角色宏配置： |r" .. realName .. "（不存在）")
        return false
    end
    local _, macrosNum = GetNumMacros()
    for i = macrosNum + 18, 19, -1 do
        DeleteMacro( i )
    end
    local count = 0
    for _, data in pairs(db) do
        local name = data.name or ""
        local texture = string.match(data.texture, [[([^\]+)$]]) or ""
        local body = data.body or ""
        CreateMacro( name, texture, body, _, 1)
        count = count +1
    end
    print("|cff00ff00✅ 角色宏加载完成： |r" .. realName .. "（共加载 " .. count .. " 个角色宏）")
    return true    
end

-- ==============================================
-- 保存超级宏
-- ==============================================
local function saveSMacros(profileName)
    local isSuperMacroLoaded = (type(GetNumSuperMacros) == "function")
    if not isSuperMacroLoaded then
        return false
    end
    local realName = strtrim(profileName or "")
    if realName == "" then
        return false
    end
    local macrosNum = GetNumSuperMacros()
    _G.GDKS_MacrosDB["SuperMacros"] = _G.GDKS_MacrosDB["SuperMacros"] or {}
    _G.GDKS_MacrosDB["SuperMacros"][realName] = {}
    local db = _G.GDKS_MacrosDB["SuperMacros"][realName]
    for i = 1, macrosNum do
        local name, texture, body = GetOrderedSuperMacroInfo(i)
        db[i] = {
            name = name,
            texture = texture,
            body = body,
        }
    end
    print("|cff00ff00✅ 超级宏保存完成： |r" .. realName .. "（共保存 " .. macrosNum .. " 个超级宏）")
    return true    
end

-- ==============================================
-- 加载超级宏
-- ==============================================
local function loadSMacros(profileName)
    local isSuperMacroLoaded = (type(GetNumSuperMacros) == "function")
    if not isSuperMacroLoaded then
        return false
    end
    local realName = strtrim(profileName or "")
    if realName == "" then
        return false
    end
    local macrosNum = GetNumSuperMacros()
    local db = _G.GDKS_MacrosDB["SuperMacros"][realName]
    if db == nil then
        print("|cff00ff00✅ 超级宏配置： |r" .. realName .. "（不存在）")
        return false
    end
    for i = macrosNum , 1, -1 do
        DeleteSuperMacro(i)
    end
    local count = 0 
    for _, data in pairs(db) do
        local name = data.name or ""
        local texture = string.match(data.texture, [[([^\]+)$]]) or ""
        local body = data.body or ""
        CreateSuperMacro( name, data.texture, body )
        count = count +1
    end    
    print("|cff00ff00✅ 超级宏加载完成： |r" .. realName .. "（共加载 " .. count .. " 个超级宏）")
    return true    
end

-- ==============================================
-- 保存动作条
-- ==============================================
local function saveActionBarConfig(profileName)
    local realName = strtrim(profileName or "")
    if realName == "" then
        print("|cffff0000配置名称不能为空！|r")
        return false
    end
    _G.GDKS_ActionBarDB = _G.GDKS_ActionBarDB or {}
    _G.GDKS_ActionBarDB[realName] = {};
    _G.GDKS_ActionBarDB[realName]["Spells"] = {};
    _G.GDKS_ActionBarDB[realName]["Items"] = {};
    _G.GDKS_ActionBarDB[realName]["Macros"] = {};
    _G.GDKS_ActionBarDB[realName]["SuperMacros"] = {};
    _G.GDKS_ActionBarDB[realName]["Others"] = {};
    local barCount = 0
    for slot = 1, 144 do
        if HasAction(slot) then
            local actionText, actionType, actionId
            actionText, actionType, actionId = GetActionText(slot)
            if actionType ~= nil or actionText ~= nil or actionId ~= nil then
                if actionType == "SPELL" then
                    _G.GDKS_ActionBarDB[realName]["Spells"][slot] = {
                        text = actionText,
                        id = actionId,
                    }
                    barCount = barCount + 1
                elseif actionType == "ITEM" then
                    _G.GDKS_ActionBarDB[realName]["Items"][slot] = {
                        text = actionText,
                        id = actionId,
                    }
                    barCount = barCount + 1
                elseif actionType == "MACRO" then
                    _G.GDKS_ActionBarDB[realName]["Macros"][slot] = {
                        text = actionText,
                        id = actionId,
                    }
                    barCount = barCount + 1
                else
                    local id = GD.GetSuperMacroIDByName(actionText)
                    if id > 0 then 
                        _G.GDKS_ActionBarDB[realName]["SuperMacros"][slot] = {
                            text = actionText,
                            id = id
                        }
                        barCount = barCount + 1                        
                    else
                        _G.GDKS_ActionBarDB[realName]["Others"][slot] = {
                            text = actionText,
                            type = actionType,
                            id = actionId,
                        }
                        barCount = barCount + 1                    
                    end
                end
            end
        end
    end
    print("|cff00ff00✅ 动作条配置保存完成： |r" .. realName .. "（共保存 " .. barCount .. " 个动作）")
    return true
end

-- ==============================================
-- 加载动作条
-- ==============================================
local function loadActionBarConfig(profileName)
    local realName = strtrim(profileName or "" )
    if realName == "" then
        print("|cffff0000动作条配置名称不能为空！|r")
        return false
    end
    if _G.GDKS_ActionBarDB[realName] == nil then
        print("|cffff0000动作条配置：" ..realName.. "不存在！|r")
        return false
    end
    _G.GDKS_ActionBarDB[realName] = _G.GDKS_ActionBarDB[realName] or {}
    local db = _G.GDKS_ActionBarDB[realName]
    local function placeSlot(type, id, name, slot, pCount)
        slot = tonumber(slot)
        id = tonumber(id)
        if not type and not id and not name and not slot then return pCount end
        ClearCursor()
        if type == "SPELL" then
            GD.PickupSpellByID(id)
            PlaceAction(slot)
            return pCount
        elseif type == "ITEM" then
            GD.PickupItemByID(id)
            PlaceAction(slot)
        elseif type == "MACRO" then
            GD.PickupMacroByName(name)
            PlaceAction(slot)
        elseif type == "SUPERMACRO" then
            --PickupMacro( 0, name )
            SetActionSuperMacro(slot, name)
        else
            print("未识别的动作条 " ..slot.." 号按钮，备份的名称是： " ..name)
        end
        ClearCursor()
        pCount = pCount + 1
        return pCount
    end
    
    local lCount = 0
    for slot, data in pairs(db.Spells or {}) do lCount = placeSlot( "SPELL", data.id, nil , slot, lCount ) end
    for slot, data in pairs(db.Items or {}) do lCount = placeSlot( "ITEM", data.id, nil , slot, lCount ) end
    for slot, data in pairs(db.Macros or {}) do lCount = placeSlot( "MACRO", data.id, data.text, slot, lCount ) end
    for slot, data in pairs(db.SuperMacros or {}) do lCount = placeSlot( "SUPERMACRO", data.id, data.text, slot, lCount ) end    
    for slot, data in pairs(db.Others or {}) do lCount = placeSlot( "OTHERS", nil , data.text, slot, lCount ) end
    print("|cff00ff00✅ 动作条按钮加载完成: |r" .."共加载"..lCount.."个按钮" )
    return true
end


-- ==============================================
-- 面板
-- ==============================================
local gdksFrame = CreateFrame("Frame", "GDKS_MainFrame", UIParent)
gdksFrame:SetWidth(520) -- 宽度加大，放下勾选框
gdksFrame:SetHeight(220) -- 高度加大，放下勾选框
gdksFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left=11, right=12, top=12, bottom=11 }
})
gdksFrame:SetMovable(true)
gdksFrame:EnableMouse(true)
gdksFrame:RegisterForDrag("LeftButton")
gdksFrame:Hide()

gdksFrame:ClearAllPoints()
gdksFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

gdksFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
gdksFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

local title = gdksFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
title:SetPoint("TOP", 0, -15)
title:SetText("Daggergd（POWER of Blood Ring）动作条配置管理")

local label = gdksFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
label:SetPoint("TOPLEFT", 20, -45)
label:SetText("配置名称：")

local editbox = CreateFrame("EditBox", nil, gdksFrame, "InputBoxTemplate")
editbox:SetWidth(200)
editbox:SetHeight(20)
editbox:SetPoint("TOPLEFT", 100, -45)
editbox:SetAutoFocus(false)

-- ==============================================
-- 新增：勾选框（两行排版 · 整洁版）
-- ==============================================
-- 第一行：动作条 + 快捷键
local cbActionBar = CreateFrame("CheckButton", nil, gdksFrame, "UICheckButtonTemplate")
cbActionBar:SetPoint("TOPLEFT", 20, -145)
cbActionBar.text = cbActionBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
cbActionBar.text:SetPoint("LEFT", cbActionBar, "RIGHT", 5, 0)
cbActionBar.text:SetText("管理动作条")
cbActionBar:SetChecked(true)

local cbBindings = CreateFrame("CheckButton", nil, gdksFrame, "UICheckButtonTemplate")
cbBindings:SetPoint("TOPLEFT", cbActionBar, "TOPRIGHT", 100, 0)
cbBindings.text = cbBindings:CreateFontString(nil, "ARTWORK", "GameFontNormal")
cbBindings.text:SetPoint("LEFT", cbBindings, "RIGHT", 5, 0)
cbBindings.text:SetText("管理快捷键")
cbBindings:SetChecked(false)

-- 第二行：公用宏 + 角色宏 + 超级宏
local cbPMacros = CreateFrame("CheckButton", nil, gdksFrame, "UICheckButtonTemplate")
cbPMacros:SetPoint("TOPLEFT", 20, -175)
cbPMacros.text = cbPMacros:CreateFontString(nil, "ARTWORK", "GameFontNormal")
cbPMacros.text:SetPoint("LEFT", cbPMacros, "RIGHT", 5, 0)
cbPMacros.text:SetText("管理公用宏")
cbPMacros:SetChecked(false)

local cbCMacros = CreateFrame("CheckButton", nil, gdksFrame, "UICheckButtonTemplate")
cbCMacros:SetPoint("TOPLEFT", cbPMacros, "TOPRIGHT", 100, 0)
cbCMacros.text = cbCMacros:CreateFontString(nil, "ARTWORK", "GameFontNormal")
cbCMacros.text:SetPoint("LEFT", cbCMacros, "RIGHT", 5, 0)
cbCMacros.text:SetText("管理角色宏")
cbCMacros:SetChecked(false)

local cbSMacros = CreateFrame("CheckButton", nil, gdksFrame, "UICheckButtonTemplate")
cbSMacros:SetPoint("TOPLEFT", cbCMacros, "TOPRIGHT", 100, 0)
cbSMacros.text = cbSMacros:CreateFontString(nil, "ARTWORK", "GameFontNormal")
cbSMacros.text:SetPoint("LEFT", cbSMacros, "RIGHT", 5, 0)
cbSMacros.text:SetText("管理超级宏")
cbSMacros:SetChecked(false)

-- ==============================================
-- 按钮区域
-- ==============================================
-- ==============================================
-- 保存按钮
-- ==============================================
local btnSave = CreateFrame("Button", nil, gdksFrame, "UIPanelButtonTemplate")
btnSave:SetWidth(120)
btnSave:SetHeight(22)
btnSave:SetPoint("TOPLEFT", 20, -80)
btnSave:SetText("保存配置")

btnSave:SetScript("OnClick", function()
    editbox:ClearFocus()
    local name = strtrim(editbox:GetText() or "")
    if name == "" then
        print("|cffff0000配置名称不能为空！|r")
        return
    end

    local checkAB = cbActionBar:GetChecked()
    local checkPM = cbPMacros:GetChecked()
    local checkCM = cbCMacros:GetChecked()
    local checkSM = cbSMacros:GetChecked()
    local checkKB = cbBindings:GetChecked()

    if not checkAB and not checkPM and not checkCM and not checkSM and not checkKB then
        print("|cffff0000请至少勾选一个：动作条 / 宏 / 快捷键|r")
        return
    end

    if checkPM then
        savePMacros(name)
    end
    if checkCM then
        saveCMacros(name)
    end
    if checkSM then
        saveSMacros(name)
    end
    if checkKB then
        saveAllKeyBindings(name)
    end
    if checkAB then
        saveActionBarConfig(name)
    end
end)



-- ==============================================
-- 加载按钮
-- ==============================================
local btnLoad = CreateFrame("Button", nil, gdksFrame, "UIPanelButtonTemplate")
btnLoad:SetWidth(120)
btnLoad:SetHeight(22)
btnLoad:SetPoint("LEFT", btnSave, "RIGHT", 20, 0)
btnLoad:SetText("读取配置")

btnLoad:SetScript("OnClick", function()
    editbox:ClearFocus()
    local name = strtrim(editbox:GetText() or "")
    if name == "" then
        print("|cffff0000配置名称不能为空！|r")
        return
    end
    
    local checkAB = cbActionBar:GetChecked()
    local checkPM = cbPMacros:GetChecked()
    local checkCM = cbCMacros:GetChecked()
    local checkSM = cbSMacros:GetChecked()
    local checkKB = cbBindings:GetChecked()

    if not checkAB and not checkPM and not checkCM and not checkSM and not checkKB then
        print("|cffff0000请至少勾选一个：动作条 / 宏 / 快捷键|r")
        return
    end

    -- 调用你原有函数（我已兼容勾选）
    
    if checkPM then
        loadPMacros(name)
    end
    if checkCM then
        loadCMacros(name)
    end
    if checkSM then
        loadSMacros(name)
    end    
    if checkAB then
        loadActionBarConfig(name)
    end
    if checkKB then
        loadAllKeyBindings(name)
    end
end)



-- ==============================================
-- 删除按钮
-- ==============================================
local btnDelete = CreateFrame("Button", nil, gdksFrame, "UIPanelButtonTemplate")
btnDelete:SetWidth(120)
btnDelete:SetHeight(22)
btnDelete:SetPoint("TOP", btnSave, "BOTTOM" , 0, -20)
btnDelete:SetText("删除配置")

btnDelete:SetScript("OnClick", function()
    editbox:ClearFocus()
    local name = strtrim(editbox:GetText() or "")
    if name == "" then 
        print("|cffff0000配置名称不能为空！|r")
        return 
    end
    
    local checkAB = cbActionBar:GetChecked()
    local checkPM = cbPMacros:GetChecked()
    local checkCM = cbCMacros:GetChecked()
    local checkSM = cbSMacros:GetChecked()
    local checkKB = cbBindings:GetChecked()

    if not checkAB and not checkPM and not checkCM and not checkSM and not checkKB then
        print("|cffff0000请至少勾选一个：动作条 / 宏 / 快捷键|r")
        return
    end

    if checkPM then
        local db = _G.GDKS_MacrosDB["PublicMacros"] or {}
        if db[name] then
            db[name] = nil
            print("|cffff4444已删除公用宏配置： |r"..name)
        else
            print("|cffff4444公用宏配置： |r"..name.." 不存在")
        end
    end
    if checkCM then
        local db = _G.GDKS_MacrosDB["CharacterMacros"] or {}
        if db[name] then
            db[name] = nil
            print("|cffff4444已删除角色宏配置： |r"..name)
        else
            print("|cffff4444角色宏配置： |r"..name.." 不存在")
        end
    end
    if checkSM then
        local db = _G.GDKS_MacrosDB["SuperMacros"] or {}
        if db[name] then
            db[name] = nil
            print("|cffff4444已删除超级宏配置： |r"..name)
        else
            print("|cffff4444超级宏配置： |r"..name.." 不存在")
        end
    end
    if checkAB then
        local db = _G.GDKS_ActionBarDB or {}
        if db[name] then
            db[name] = nil
            print("|cffff4444已删除动作条配置： |r"..name)
        else
            print("|cffff0000动作条配置： |r"..name.." 不存在")
        end
    end
    if checkKB then
        local db = _G.GDKS_BindingsDB or {}
        if db[name] then
            db[name] = nil
            print("|cffff4444已删除快捷键配置： |r"..name)
        else
            print("|cffff0000快捷键配置： |r"..name.." 不存在")
        end
    end    
end)



-- ==============================================
-- List 按钮
-- ==============================================
local btnList = CreateFrame("Button", nil, gdksFrame, "UIPanelButtonTemplate")
btnList:SetWidth(120)
btnList:SetHeight(22)
btnList:SetPoint("LEFT", btnDelete, "RIGHT", 20, 0)
btnList:SetText("列出所有配置")

btnList:SetScript("OnClick", function()
    local checkAB = cbActionBar:GetChecked()
    local checkPM = cbPMacros:GetChecked()
    local checkCM = cbCMacros:GetChecked()
    local checkSM = cbSMacros:GetChecked()
    local checkKB = cbBindings:GetChecked()

    if not checkAB and not checkPM and not checkCM and not checkSM and not checkKB then
        print("|cffff0000请至少勾选一个：动作条 / 宏 / 快捷键|r")
        return
    end

    if checkPM then
        print("|cffffff00=== 公用宏配置列表 ===")
        _G.GDKS_MacrosDB["PublicMacros"] = _G.GDKS_MacrosDB["PublicMacros"] or {}
        local db  = _G.GDKS_MacrosDB["PublicMacros"] or {}
        if next(db) == nil  then
            print("|cffff4444 暂无配置|r")
        else
            for k in pairs(db) do print("  - "..k) end
        end
    end
    if checkCM then
        print("|cffffff00=== 角色宏配置列表 ===")
        local db = _G.GDKS_MacrosDB["CharacterMacros"] or {}
        if next(db) == nil  then
            print("|cffff4444 暂无配置|r")
        else
            for k in pairs(db) do print("  - "..k) end
        end
    end
    if checkSM then
        print("|cffffff00=== 超级宏配置列表 ===")
        local db = _G.GDKS_MacrosDB["SuperMacros"] or {}
        if next(db) == nil  then
            print("|cffff4444 暂无配置|r")
        else
            for k in pairs(db) do print("  - "..k) end
        end
    end
    if checkAB then
        print("|cffffff00=== 动作条配置列表 ===")
        local db = _G.GDKS_ActionBarDB or {}
        if next(db) == nil  then
            print("|cffff4444 暂无配置|r")
        else
            for k in pairs(db) do print("  - "..k) end
        end
    end
    if checkKB then
        print("|cffffff00=== 快捷键配置列表 ===")
        local db = _G.GDKS_BindingsDB or {}
        if next(db) == nil  then
            print("|cffff4444 暂无配置|r")
        else
            for k in pairs(db) do print("  - "..k) end
        end
    end
end)

local btnClose = CreateFrame("Button", nil, gdksFrame, "UIPanelCloseButton")
btnClose:SetPoint("TOPRIGHT", -8, -8)
btnClose:SetScript("OnClick", function() gdksFrame:Hide() end)

-- ==============================================
-- 开关面板
-- ==============================================
function GDKS_ToggleFrame()
    if gdksFrame:IsVisible() then
        gdksFrame:Hide()
    else
        gdksFrame:Show()
        editbox:SetFocus()
    end
end

-- ==============================================
-- LDB 小地图图标
-- ==============================================

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local DBI = LibStub("LibDBIcon-1.0", true)
    if not LDB or not DBI then 
        print("|cffff0000GDKS 加载失败：缺少LDB/LibDBIcon库|r")
        return 
    end

    local dataobj = LDB:NewDataObject("GDKS", {
        type = "launcher",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        OnClick = function( _, button)
            GDKS_ToggleFrame()
        end,
        OnTooltipShow = function(tooltip)
            tooltip:SetText("GDKS 配置管理器")
        end,
    })

    DBI:Register("GDKS", dataobj, { hide = false, minimapPos = 200 })
    DBI:Show("GDKS")
end)


-- ==============================================
-- 命令
-- ==============================================
SLASH_GDKS1 = "/gdks"
SlashCmdList["GDKS"] = function()
    GDKS_ToggleFrame()
end

print("|cff00ff00GDKS 插件已加载 | 无语法错误版|r")