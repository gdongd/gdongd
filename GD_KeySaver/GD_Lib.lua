_G.GD = _G.GD or {}

function _G.GD.PickupSpellByID(spellID)
-- local name = GetSpellName(slot,"spell")
-- local name = SpellInfo(spellID)
-- PickupSpell(slot,"spell")

    local index = 1
    local gName = GetSpellName(index,"spell")
    local sName = SpellInfo(spellID)
    while gName ~= nil do
        if gName == sName then
            PickupSpell(index,"spell")
            return true
        end
        index = index + 1
        gName = GetSpellName(index,"spell")
    end
    return false
end

function _G.GD.PickupItemByID(itemID)
-- 乌龟服/SuperWoW：按 itemID 捡起物品（替代 PickupItem）
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, _, id = string.find(link, "item:(%d+)")
                id = tonumber( id )
                if id == itemID then
                    PickupContainerItem(bag, slot)
                    return true
                end
            end
        end
    end
    return false
end

function _G.GD.PickupMacroByName(macroName)
    if macroName == nil or macroName == "" then 
        return false
    end
    local index = GetMacroIndexByName(macroName)
    if index ~= 0 then
        PickupMacro(index)
        return true
    end
    return false
end

-- 获取所有超级宏
function GetAllSuperMacros()
    local isSuperMacroLoaded = (type(GetNumSuperMacros) == "function")
    if not isSuperMacroLoaded then
        return false
    end
    local t = {};

    local n = GetNumSuperMacros();
    for i = 1, n do t[i] = {GetOrderedSuperMacroInfo(i)} end
    return t
end

function IsSuperMacros(macroName)
    local isSuperMacroLoaded = (type(GetNumSuperMacros) == "function")
    if not isSuperMacroLoaded then
        return false
    end
    local realName = strtrim(macroName or "")
    if realName == "" then
        return false
    end
    local n = GetNumSuperMacros()
    for i = 1, n do
        local name = GetOrderedSuperMacroInfo(i)
        if name == realName then
            return true
        end
    end
    return false
end

function GetSuperMacroIDByName(macroName)
    local isSuperMacroLoaded = (type(GetNumSuperMacros) == "function")
    if not isSuperMacroLoaded then
        return 0
    end
    local realName = strtrim(macroName or "")
    if realName == "" then
        return 0
    end
    local n = GetNumSuperMacros()
    for i = 1, n do
        local name = GetOrderedSuperMacroInfo(i)
        if name == realName then
            return i
        end
    end
    return 0
end