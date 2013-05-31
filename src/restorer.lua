﻿-- Author: for.sneg@gmail.com

-- ATTENSION! Asynchronus work!

Restorer = { 
	_db = nil, -- reference to save table for current char
    _isErrorCatching = false,
    _isError = false,
    errorCallback = nil,
    successCallback = nil,
    callbackObj = nil
}

function Restorer:openRecord(name)
	self._db = Addon.db.global[name]
    Addon:RegisterEvent("CHAT_MSG_SAY", function() self:_on_CHAT_MSG_SAY() end)
    Addon:RegisterEvent("CHAT_MSG_SYSTEM", function() self:_on_CHAT_MSG_SYSTEM() end)
end

-- Return nil if db empty
function Restorer:getRestoreRecordsNames()
    local records = nil

	for k,v in pairs(Addon.db.global) do
        local _, build, _, _ = GetBuildInfo()

        if v.mainInfo and v.mainInfo.engineVersion == DUMP_ENGINE_VERSION and v.mainInfo.clientbuild == build then
            records = records or {}
            table.insert(records, k)
        end
    end

    if records then
        table.sort(records)
    end

    return records
end

local function _isValidInteger(value, low, high)
    return type(value) == "number" and (low == nil or value > low) and (high == nil or value < high)
end

local function _isValidString(value, count)
    return type(value) == "string" and (count == nil or #value > count)
end

function Restorer:_SendChatMessage(text)
    if not self.cmdError then
        SendChatMessage(text, "SAY")
    end
end

function Restorer:_on_CHAT_MSG_SAY()
    local msg = arg1
    local sender = arg2
    
    if self._isErrorCatching then
        local myname = UnitName("player")
        if sender == myname and string.match(msg, "^%..+") then
            self._isError = true
            self.errorCallback(self.callbackObj, "Errors occures while execute GM commands.")
        end

    end
end

function Restorer:_on_CHAT_MSG_SYSTEM()
    local msg = string.lower(arg1)

    if self._isErrorCatching then
  
        if     string.find(msg, "incorrect", 0, true)
            or string.find(msg, "there is no such", 0, true)
            or string.find(msg, "not found", 0, true)
            or string.find(msg, "invalid", 0, true)
            or string.find(msg, "syntax", 0, true)
        then
            self._isError = true
            self.errorCallback(self.callbackObj, "Errors occures while execute GM commands.")
        end

    end
end

function Restorer:_enableErrorCatching()
    self._isError = false
    self._isErrorCatching = true
end

function Restorer:_disableErrorCatching()
    self._isErrorCatching = false
end

function Restorer:_prepare(callbackObj, successCallback, errorCallback)
    self.successCallback = successCallback
    self.errorCallback = errorCallback
    self.callbackObj = callbackObj
    self:_enableErrorCatching()
end


-- =================
-- Main info
-- =================

function Restorer:getMainInfoInfo()
    if not self._db then
        return false, "Initializing error!"
    end

    -- VALIDATE

    -- Validates on record loading:
    -- -- self._db.mainInfo
    -- -- self._db.mainInfo.engineVersion
    -- -- self._db.mainInfo.clientbuild

    local db = self._db.mainInfo

    local validate = {
        ["Realmlist"] = _isValidString(db.realmlist, 4),
        ["Class"] = _isValidString(db.class, 4),
        ["Level"] = _isValidInteger(db.level, 0, 71), -- For 2.4.3
        ["Race"] = _isValidString(db.race, 4),
        ["HonorableKills"] = _isValidInteger(db.honorableKills, -1),
        ["Honor"] = _isValidInteger(db.honor, -1),
        ["Arena"] = _isValidInteger(db.arenapoints, -1),
        ["Money"] = _isValidInteger(db.money, -1)
    }

    for k,v in pairs(validate) do
        if not v then
            return false, k
        end
    end

    -- PREPARE WARNINGS
  
    local _, myclass = UnitClass("player")
    local _,myrace = UnitRace("player")

    local warnings = {
        ["isClassMismatch"] = db.class ~= myclass,
        ["isRaceMismatch"] = db.race ~= myrace,
    }

    return true, db.class.." "..db.name.." "..tostring(db.level).." lvl", warnings
end

-- RESTORE

function Restorer:restoreMainInfo(callbackObj, successCallback, errorCallback)
    self:_prepare(callbackObj, successCallback, errorCallback)

    local db = self._db.mainInfo

    self:_SendChatMessage(".level "..db.level)
    self:_SendChatMessage(".debug setvalue 1517 "..db.honorableKills)
    self:_SendChatMessage(".mod honor "..db.honor)
    self:_SendChatMessage(".mod arena "..db.arenapoints)
    self:_SendChatMessage(".mod money "..db.money)
    
    -- TODO: Timer + disable
    if not self._isError then
        self.successCallback(self.callbackObj)
        -- self:_disableErrorCatching()
    end
end