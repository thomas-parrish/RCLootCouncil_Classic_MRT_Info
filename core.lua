print("|cffB00020[RCLC MRT]|r " .. "RCLC MRT Initializing..");

local function buildAltsTable()
  local alts = {}
  for i=1,#VMRT.Attendance.alts do
    local altName, mainName = VMRT.Attendance.alts[i][1],VMRT.Attendance.alts[i][2]
    alts[ altName ] = mainName
  end
  return alts
end

local attendanceTable, count = {},0;

local function buildAttendanceTable()
  if not VMRT then
    print("|cffB00020RCLC MRT]|r " .. "MRT Addon Not Found!");
  end
  local attendance = VMRT.Attendance;
  if not attendance then
    print("|cffB00020RCLC MRT]|r " .. "MRT Attendance Not Found!");
  end

  local alts = buildAltsTable();

  for _, attendanceData in pairs(VMRT.Attendance.data) do
    count = count + 1
    for key, val in pairs(attendanceData) do
      (function ()
        if (type(key) == "string") then
            return;
        end

        local name = val:sub(2)
        if name then
          local mainName = alts[ name ]
          if mainName then
            name = mainName
          end
         
          if not attendanceTable[name] then
            attendanceTable[name] = 0
          end
          attendanceTable[name] = attendanceTable[name] + 1
        end
      end)();
    end
  end
end

buildAttendanceTable();

local function hex2rgb(hex)
  hex = hex:gsub("#","")
  return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
end

local attendanceColors = {
  low = "cc0000",
  medium = "e4e400",
  high = "5fe65d",
  exceptional = "2ee6e6"
}

hooksecurefunc(RCLootCouncil:GetActiveModule("votingframe"), "UpdateMoreInfo", function(_, row, data)
  local module = RCLootCouncil:GetActiveModule("votingframe");
  local tip = module.frame.moreInfo;

  local name
  if data and row then
		name  = data[row].name
	else -- Try to extract the name from the selected row
		name = module.frame.st:GetSelection() and module.frame.st:GetRow(module.frame.st:GetSelection()).name or nil
	end

  if not name then return end;
  tip:AddLine(" ") -- spacer

  local realmName = "%-" .. GetRealmName();
  name = string.gsub(name, realmName, "");


  local attendancePercentage = attendanceTable[name]/count*100;
  local formattedAttendancePercentage = format("%.1f%%", attendancePercentage);
  local r, g, b

  if (attendancePercentage <= 25) then
    r,g,b = hex2rgb(attendanceColors["low"]);
  elseif (attendancePercentage <= 50 ) then
    r,g,b = hex2rgb(attendanceColors["medium"]);
  elseif (attendancePercentage <= 85 ) then
    r,g,b = hex2rgb(attendanceColors["high"]);
  else
    r,g,b = hex2rgb(attendanceColors["exceptional"]);
  end

  tip:AddDoubleLine("Attendance: ", formattedAttendancePercentage, 1,1,1,r,g,b)
  tip:AddLine(" ") -- spacer
  tip:AddDoubleLine("More MRT Info Goes Here");
  RCLootCouncil:GetActiveModule("votingframe").frame.moreInfo:Show()
end);
