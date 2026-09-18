import "Turbine"
import "Turbine.UI"
import "Turbine.UI.Lotro"
import "Turbine.Gameplay"

local ADDON_NAME = "GatherReminder"
local SETTINGS_KEY = "GatherReminder_Settings"
local LEGACY_SETTINGS_KEY = "GatherReminder"
local MAX_SLOTS = 3

local language = Turbine.Engine.GetLanguage()

local STRINGS = {
    en = {
        title = "Resource detection",
        reminder = "Remember to enable your tracking skills!",
        setup = "Drag up to 3 tracking skills into the slots below.",
        configured = "Choose one tracking skill to activate. Right-click a slot to clear it.",
        later = "Later",
        reset = "Saved tracking skills cleared.",
        slotCleared = "GatherReminder: slot %d cleared.",
        skillOnly = "GatherReminder: please drag a skill, not an item.",
        saved = "GatherReminder: tracking skill saved.",
        commandConflict = "GatherReminder: /%s is already used; alias skipped.",
        loaded = "GatherReminder loaded. Commands: %s",
        noCommand = "GatherReminder loaded, but no slash command could be registered.",
        help = "/gather, /gr, /grem: show/hide | reset: clear all slots | center: recenter | help: help",
    },
    fr = {
        title = "Détection des ressources",
        reminder = "Pense à activer tes détections !",
        setup = "Glisse jusqu'à 3 compétences de détection dans les cases ci-dessous.",
        configured = "Choisis la détection à activer. Clic droit sur une case pour la vider.",
        later = "Plus tard",
        reset = "Compétences de détection enregistrées effacées.",
        slotCleared = "GatherReminder : case %d vidée.",
        skillOnly = "GatherReminder : glisse une compétence, pas un objet.",
        saved = "GatherReminder : compétence de détection enregistrée.",
        commandConflict = "GatherReminder : /%s est déjà utilisée ; alias ignoré.",
        loaded = "GatherReminder chargé. Commandes : %s",
        noCommand = "GatherReminder chargé, mais aucune commande n'a pu être enregistrée.",
        help = "/gather, /gr, /grem : afficher/masquer | reset : vider les 3 cases | center : recentrer | help : aide",
    },
    de = {
        title = "Rohstoffsuche",
        reminder = "Denk daran, deine Suchfertigkeiten zu aktivieren!",
        setup = "Ziehe bis zu 3 Suchfertigkeiten in die Felder unten.",
        configured = "Wähle eine Suchfertigkeit aus. Rechtsklick leert ein Feld.",
        later = "Später",
        reset = "Gespeicherte Suchfertigkeiten wurden gelöscht.",
        slotCleared = "GatherReminder: Feld %d geleert.",
        skillOnly = "GatherReminder: Bitte eine Fertigkeit hineinziehen, keinen Gegenstand.",
        saved = "GatherReminder: Suchfertigkeit gespeichert.",
        commandConflict = "GatherReminder: /%s wird bereits verwendet; Alias übersprungen.",
        loaded = "GatherReminder geladen. Befehle: %s",
        noCommand = "GatherReminder geladen, aber kein Chatbefehl konnte registriert werden.",
        help = "/gather, /gr, /grem: anzeigen/ausblenden | reset: alle Felder leeren | center: zentrieren | help: Hilfe",
    }
}

local locale = "en"
if language == Turbine.Language.French then
    locale = "fr"
elseif language == Turbine.Language.German then
    locale = "de"
end
local L = STRINGS[locale] or STRINGS.en

local function loadRawSettings(key)
    local ok, data = pcall(Turbine.PluginData.Load, Turbine.DataScope.Character, key)
    if not ok then
        return nil, false
    end
    return data, true
end

local function encodeHex(value)
    local out = {}
    for i = 1, string.len(value) do
        out[#out + 1] = string.format("%02X", string.byte(value, i))
    end
    return table.concat(out)
end

local function decodeHex(value)
    if type(value) ~= "string" or string.sub(value, 1, 1) ~= "H" then
        return nil
    end

    local hex = string.sub(value, 2)
    if (string.len(hex) % 2) ~= 0 then
        return nil
    end
    if string.find(hex, "[^0-9A-Fa-f]") ~= nil then
        return nil
    end

    return string.gsub(hex, "(%x%x)", function(pair)
        return string.char(tonumber(pair, 16))
    end)
end

local function decodeNumber(value)
    if type(value) == "number" then
        return value
    end
    if type(value) ~= "string" then
        return nil
    end
    if string.sub(value, 1, 1) == "N" then
        return tonumber(string.sub(value, 2))
    end
    return tonumber(value)
end

local function decodeSettings(raw)
    local decoded = {}
    if type(raw) ~= "table" then
        return decoded
    end

    local safeFormat = raw.format == "GR2"

    decoded.x = decodeNumber(raw.x)
    decoded.y = decodeNumber(raw.y)

    for i = 1, MAX_SLOTS do
        local typeKey = "shortcutType" .. i
        local dataKey = "shortcutData" .. i

        decoded[typeKey] = decodeNumber(raw[typeKey])

        local value = raw[dataKey]
        if safeFormat then
            decoded[dataKey] = decodeHex(value)
        elseif type(value) == "string" then
            decoded[dataKey] = value
        elseif type(value) == "number" then
            decoded[dataKey] = tostring(value)
        end
    end

    decoded.shortcutType = decodeNumber(raw.shortcutType)

    if type(raw.shortcutData) == "string" then
        decoded.shortcutData = raw.shortcutData
    elseif type(raw.shortcutData) == "number" then
        decoded.shortcutData = tostring(raw.shortcutData)
    end

    return decoded
end

local function encodeSettings(settings)
    local encoded = {
        format = "GR2"
    }

    if type(settings.x) == "number" then
        encoded.x = "N" .. tostring(settings.x)
    end
    if type(settings.y) == "number" then
        encoded.y = "N" .. tostring(settings.y)
    end

    for i = 1, MAX_SLOTS do
        local typeKey = "shortcutType" .. i
        local dataKey = "shortcutData" .. i
        local shortcutType = settings[typeKey]
        local shortcutData = settings[dataKey]

        if type(shortcutType) == "number"
        and type(shortcutData) == "string"
        and shortcutData ~= "" then
            encoded[typeKey] = "N" .. tostring(shortcutType)
            encoded[dataKey] = "H" .. encodeHex(shortcutData)
        end
    end

    return encoded
end

local rawSettings, newLoadOk = loadRawSettings(SETTINGS_KEY)
local settingsLoadOk = newLoadOk
local migrationNeeded = false

if type(rawSettings) ~= "table" or next(rawSettings) == nil then
    local legacySettings, legacyLoadOk = loadRawSettings(LEGACY_SETTINGS_KEY)

    if legacyLoadOk then
        settingsLoadOk = true
    end

    if type(legacySettings) == "table" and next(legacySettings) ~= nil then
        rawSettings = legacySettings
        migrationNeeded = true
    elseif type(rawSettings) ~= "table" then
        rawSettings = {}
    end
end

local settings = decodeSettings(rawSettings)

if type(settings.x) ~= "number" then settings.x = nil end
if type(settings.y) ~= "number" then settings.y = nil end

if type(settings.shortcutType1) ~= "number"
and type(settings.shortcutType) == "number"
and type(settings.shortcutData) == "string"
and settings.shortcutData ~= "" then
    settings.shortcutType1 = settings.shortcutType
    settings.shortcutData1 = settings.shortcutData
    migrationNeeded = true
end

settings.shortcutType = nil
settings.shortcutData = nil

for i = 1, MAX_SLOTS do
    local typeKey = "shortcutType" .. i
    local dataKey = "shortcutData" .. i

    if type(settings[typeKey]) ~= "number" then
        settings[typeKey] = nil
    end

    if type(settings[dataKey]) == "number" then
        settings[dataKey] = tostring(settings[dataKey])
        migrationNeeded = true
    end

    if type(settings[dataKey]) ~= "string" or settings[dataKey] == "" then
        settings[dataKey] = nil
        settings[typeKey] = nil
    end
end

local function save()
    if not settingsLoadOk then
        return false
    end

    local payload = encodeSettings(settings)
    local ok = pcall(
        Turbine.PluginData.Save,
        Turbine.DataScope.Character,
        SETTINGS_KEY,
        payload
    )

    return ok
end

if migrationNeeded then
    save()
end

local win = Turbine.UI.Lotro.Window()
win:SetSize(390, 225)
win:SetText(L.title)
win:SetVisible(false)
win:SetZOrder(100)

local function clampPosition(x, y)
    local displayW = Turbine.UI.Display:GetWidth()
    local displayH = Turbine.UI.Display:GetHeight()
    local maxX = math.max(0, displayW - win:GetWidth())
    local maxY = math.max(0, displayH - win:GetHeight())
    x = math.max(0, math.min(tonumber(x) or 0, maxX))
    y = math.max(0, math.min(tonumber(y) or 0, maxY))
    return math.floor(x), math.floor(y)
end

local function center()
    local displayW = Turbine.UI.Display:GetWidth()
    local displayH = Turbine.UI.Display:GetHeight()
    local x = math.floor((displayW - win:GetWidth()) / 2)
    local y = math.floor((displayH - win:GetHeight()) / 3)
    x, y = clampPosition(x, y)
    win:SetPosition(x, y)
    settings.x, settings.y = x, y
    save()
end

if settings.x and settings.y then
    local x, y = clampPosition(settings.x, settings.y)
    win:SetPosition(x, y)
else
    center()
end

local dragging = false
local dragMouseX, dragMouseY = 0, 0
local dragWinX, dragWinY = 0, 0

win.MouseDown = function(sender, args)
    if args.Button == Turbine.UI.MouseButton.Left then
        dragging = true
        dragMouseX, dragMouseY = Turbine.UI.Display:GetMousePosition()
        dragWinX, dragWinY = win:GetPosition()
    end
end

win.MouseMove = function(sender, args)
    if dragging then
        local mx, my = Turbine.UI.Display:GetMousePosition()
        local x = dragWinX + (mx - dragMouseX)
        local y = dragWinY + (my - dragMouseY)
        x, y = clampPosition(x, y)
        win:SetPosition(x, y)
    end
end

win.MouseUp = function(sender, args)
    if dragging and args.Button == Turbine.UI.MouseButton.Left then
        dragging = false
        local x, y = win:GetPosition()
        settings.x, settings.y = x, y
        save()
    end
end

local header = Turbine.UI.Label()
header:SetParent(win)
header:SetPosition(20, 40)
header:SetSize(350, 24)
header:SetFont(Turbine.UI.Lotro.Font.TrajanPro16)
header:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
header:SetForeColor(Turbine.UI.Color(1, 0.82, 0.25))
header:SetMultiline(false)
header:SetMouseVisible(false)
header:SetText(L.reminder)

local info = Turbine.UI.Label()
info:SetParent(win)
info:SetPosition(20, 65)
info:SetSize(350, 48)
info:SetFont(Turbine.UI.Lotro.Font.Verdana14)
info:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
info:SetForeColor(Turbine.UI.Color(0.92, 0.92, 0.92))
info:SetMultiline(true)
info:SetMouseVisible(false)

local laterButton = Turbine.UI.Lotro.Button()
laterButton:SetParent(win)
laterButton:SetSize(100, 24)
laterButton:SetPosition(145, 192)
laterButton:SetText(L.later)

local quickslots = {}
local statusLabels = {}
local validShortcutType = {}
local validShortcutData = {}

local slotX = { 97, 175, 253 }

local function typeKey(i) return "shortcutType" .. i end
local function dataKey(i) return "shortcutData" .. i end

local function hasConfiguredSkill(i)
    return type(settings[typeKey(i)]) == "number"
       and type(settings[dataKey(i)]) == "string"
       and settings[dataKey(i)] ~= ""
end

local function configuredCount()
    local n = 0
    for i = 1, MAX_SLOTS do
        if hasConfiguredSkill(i) then n = n + 1 end
    end
    return n
end

local function refreshText()
    if configuredCount() > 0 then
        info:SetText(L.configured)
    else
        info:SetText(L.setup)
    end
end

local hideTimer = Turbine.UI.Control()
local hideAt = nil
hideTimer:SetWantsUpdates(false)

local function cancelHideTimer()
    hideAt = nil
    hideTimer:SetWantsUpdates(false)
end

hideTimer.Update = function(sender, args)
    if hideAt and Turbine.Engine.GetGameTime() >= hideAt then
        hideAt = nil
        hideTimer:SetWantsUpdates(false)
        win:SetVisible(false)
    end
end

local function resetRound()
    cancelHideTimer()
    for i = 1, MAX_SLOTS do
        if statusLabels[i] then
            statusLabels[i]:SetText("")
        end
    end
end

local function setEmptyShortcut(i)
    pcall(function()
        quickslots[i]:SetShortcut(Turbine.UI.Lotro.Shortcut())
    end)
end

local function restoreSavedShortcut(i)
    if not hasConfiguredSkill(i) then
        setEmptyShortcut(i)
        return true
    end
    local ok = pcall(function()
        quickslots[i]:SetShortcut(
            Turbine.UI.Lotro.Shortcut(
                settings[typeKey(i)],
                settings[dataKey(i)]
            )
        )
    end)
    return ok
end

local function clearSlot(i, writeMessage)
    cancelHideTimer()
    settings[typeKey(i)] = nil
    settings[dataKey(i)] = nil
    validShortcutType[i] = nil
    validShortcutData[i] = nil
    if statusLabels[i] then statusLabels[i]:SetText("") end
    setEmptyShortcut(i)
    save()
    refreshText()
    if writeMessage then
        Turbine.Shell.WriteLine(string.format(L.slotCleared, i))
    end
end

for i = 1, MAX_SLOTS do
    local slotIndex = i

    validShortcutType[slotIndex] = settings[typeKey(slotIndex)]
    validShortcutData[slotIndex] = settings[dataKey(slotIndex)]
    local q = Turbine.UI.Lotro.Quickslot()
    quickslots[slotIndex] = q
    q:SetParent(win)
    q:SetSize(40, 40)
    q:SetPosition(slotX[slotIndex], 122)
    q:SetAllowDrop(true)
    q:SetUseOnRightClick(false)

    local status = Turbine.UI.Label()
    statusLabels[slotIndex] = status
    status:SetParent(win)
    status:SetPosition(slotX[slotIndex], 162)
    status:SetSize(40, 18)
    status:SetFont(Turbine.UI.Lotro.Font.Verdana12)
    status:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter)
    status:SetForeColor(Turbine.UI.Color(0.45, 1, 0.45))
    status:SetMouseVisible(false)
    status:SetText("")

    q.DragDrop = function(sender, args)
        cancelHideTimer()

        local sc = sender:GetShortcut()
        if sc == nil then
            restoreSavedShortcut(slotIndex)
            return
        end

        local t = sc:GetType()
        local d = sc:GetData()

        if t == Turbine.UI.Lotro.ShortcutType.Skill and type(d) == "string" and d ~= "" then
            settings[typeKey(slotIndex)] = t
            settings[dataKey(slotIndex)] = d
            validShortcutType[slotIndex] = t
            validShortcutData[slotIndex] = d
            statusLabels[slotIndex]:SetText("")
            save()
            refreshText()
            Turbine.Shell.WriteLine(L.saved)
        else
            settings[typeKey(slotIndex)] = validShortcutType[slotIndex]
            settings[dataKey(slotIndex)] = validShortcutData[slotIndex]
            restoreSavedShortcut(slotIndex)
            refreshText()
            Turbine.Shell.WriteLine(L.skillOnly)
        end
    end

    q.MouseClick = function(sender, args)
        if args.Button == Turbine.UI.MouseButton.Right then
            if hasConfiguredSkill(slotIndex) then
                clearSlot(slotIndex, true)
            end
            return
        end

        if args.Button ~= Turbine.UI.MouseButton.Left then return end
        if not hasConfiguredSkill(slotIndex) then return end

        cancelHideTimer()
        statusLabels[slotIndex]:SetText("OK")

        hideAt = Turbine.Engine.GetGameTime() + 0.25
        hideTimer:SetWantsUpdates(true)
    end
end

laterButton.Click = function()
    cancelHideTimer()
    win:SetVisible(false)
end

local function restoreAll()
    for i = 1, MAX_SLOTS do
        restoreSavedShortcut(i)
    end
end

local function show()
    resetRound()
    restoreAll()
    refreshText()

    local oldX, oldY = win:GetPosition()
    local x, y = clampPosition(oldX, oldY)
    if x ~= oldX or y ~= oldY then
        win:SetPosition(x, y)
        settings.x, settings.y = x, y
        save()
    end

    win:SetVisible(true)
    win:Activate()
end

local function clearSkills()
    cancelHideTimer()
    for i = 1, MAX_SLOTS do
        settings[typeKey(i)] = nil
        settings[dataKey(i)] = nil
        validShortcutType[i] = nil
        validShortcutData[i] = nil
        setEmptyShortcut(i)
        statusLabels[i]:SetText("")
    end
    save()
    refreshText()
    win:SetVisible(true)
    Turbine.Shell.WriteLine(L.reset)
end

local function addCallback(object, event, callback)
    if object == nil then return nil end

    if object[event] == nil then
        object[event] = callback
    elseif type(object[event]) == "table" then
        table.insert(object[event], callback)
    else
        object[event] = { object[event], callback }
    end

    return callback
end

local function removeCallback(object, event, callback)
    if object == nil or callback == nil then return end

    if object[event] == callback then
        object[event] = nil
    elseif type(object[event]) == "table" then
        for i = table.getn(object[event]), 1, -1 do
            if object[event][i] == callback then
                table.remove(object[event], i)
                break
            end
        end
    end
end

local cancelResurrectionReminder

local command = Turbine.ShellCommand()
command.Execute = function(sender, name, args)
    local arg = string.lower((args or ""):match("^%s*(.-)%s*$"))

    cancelResurrectionReminder()

    if arg == "" then
        if win:IsVisible() then
            cancelHideTimer()
            win:SetVisible(false)
        else
            show()
        end
    elseif arg == "reset" then
        clearSkills()
    elseif arg == "center" or arg == "centre" or arg == "zentrieren" then
        cancelHideTimer()
        center()
        win:SetVisible(true)
    elseif arg == "help" or arg == "aide" or arg == "hilfe" then
        Turbine.Shell.WriteLine(L.help)
    else
        Turbine.Shell.WriteLine(L.help)
    end
end

command.GetHelp = function() return L.help end
command.GetShortHelp = function() return L.title end

local player = Turbine.Gameplay.LocalPlayer.GetInstance()
local wasDefeated = false
local deathReminderEligible = false
local resurrectionPending = false

local resurrectionTimer = Turbine.UI.Control()
local resurrectionAt = nil
resurrectionTimer:SetWantsUpdates(false)

local function isGrouped()
    if player == nil then return false end

    local ok, party = pcall(function()
        return player:GetParty()
    end)

    return ok and party ~= nil
end

local function isInCombat()
    if player == nil then return false end

    local ok, value = pcall(function()
        return player:IsInCombat()
    end)

    return ok and value == true
end

cancelResurrectionReminder = function()
    resurrectionPending = false
    resurrectionAt = nil
    resurrectionTimer:SetWantsUpdates(false)
end

local function tryShowAfterResurrection()
    if not resurrectionPending then return end

    if configuredCount() <= 0 then
        cancelResurrectionReminder()
        return
    end

    if isGrouped() then
        cancelResurrectionReminder()
        return
    end

    if isInCombat() then
        resurrectionAt = nil
        resurrectionTimer:SetWantsUpdates(false)
        return
    end

    cancelResurrectionReminder()
    show()
end

local function scheduleResurrectionReminder(delay)
    resurrectionPending = true
    resurrectionAt = Turbine.Engine.GetGameTime() + (delay or 0.75)
    resurrectionTimer:SetWantsUpdates(true)
end

resurrectionTimer.Update = function(sender, args)
    if resurrectionAt ~= nil and Turbine.Engine.GetGameTime() >= resurrectionAt then
        resurrectionAt = nil
        resurrectionTimer:SetWantsUpdates(false)
        tryShowAfterResurrection()
    end
end

local function getMorale()
    if player == nil then return nil end

    local ok, value = pcall(function()
        return player:GetMorale()
    end)

    if ok and type(value) == "number" then
        return value
    end

    return nil
end

local moraleChangedCallback = function(sender, args)
    local morale = getMorale()
    if morale == nil then return end

    if morale <= 0 then
        if not wasDefeated then
            wasDefeated = true
            deathReminderEligible = not isGrouped()
            cancelResurrectionReminder()
            cancelHideTimer()
            win:SetVisible(false)
        end
        return
    end

    if wasDefeated then
        wasDefeated = false

        if deathReminderEligible then
            deathReminderEligible = false

            if configuredCount() > 0 then
                scheduleResurrectionReminder(0.75)
            end
        else
            deathReminderEligible = false
        end
    end
end

local combatChangedCallback = function(sender, args)
    if resurrectionPending and not isInCombat() then
        scheduleResurrectionReminder(0.35)
    end
end

if player ~= nil then
    local currentMorale = getMorale()
    if currentMorale ~= nil and currentMorale <= 0 then
        wasDefeated = true
        deathReminderEligible = not isGrouped()
    end

    addCallback(player, "MoraleChanged", moraleChangedCallback)
    addCallback(player, "InCombatChanged", combatChangedCallback)
end

local registeredAliases = {}

local function registerAlias(name)
    local alreadyUsed = false
    local okCheck, result = pcall(Turbine.Shell.IsCommand, name)
    if okCheck and result then
        alreadyUsed = true
    end

    if alreadyUsed then
        Turbine.Shell.WriteLine(string.format(L.commandConflict, name))
        return false
    end

    local ok, count = pcall(Turbine.Shell.AddCommand, name, command)
    if ok and type(count) == "number" and count > 0 then
        table.insert(registeredAliases, name)
        return true
    end

    Turbine.Shell.WriteLine(string.format(L.commandConflict, name))
    return false
end

registerAlias("gather")
registerAlias("gr")
registerAlias("grem")

local function unload()
    cancelHideTimer()
    cancelResurrectionReminder()

    if player ~= nil then
        removeCallback(player, "MoraleChanged", moraleChangedCallback)
        removeCallback(player, "InCombatChanged", combatChangedCallback)
    end

    save()
    pcall(Turbine.Shell.RemoveCommand, command)
    win:SetVisible(false)
end

if plugin ~= nil then
    plugin.Unload = unload
elseif Plugins ~= nil and Plugins[ADDON_NAME] ~= nil then
    Plugins[ADDON_NAME].Unload = unload
end

restoreAll()
resetRound()
refreshText()

if wasDefeated then
    win:SetVisible(false)
else
    win:SetVisible(true)
end

if #registeredAliases > 0 then
    local commandNames = {}
    for i = 1, #registeredAliases do
        commandNames[i] = "/" .. registeredAliases[i]
    end
    Turbine.Shell.WriteLine(string.format(L.loaded, table.concat(commandNames, ", ")))
else
    Turbine.Shell.WriteLine(L.noCommand)
end
