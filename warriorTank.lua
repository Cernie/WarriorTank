WarriorTank = {};
function WarriorTank_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("ADDON_LOADED");
	DEFAULT_CHAT_FRAME:AddMessage("WarriorTank addon loaded. Type /tank for usage.");
	SlashCmdList["WARRIORTANK"] = function()
		local msg = "To use WarriorTank addon, create a macro and type /script WarriorTank_main();"
		DEFAULT_CHAT_FRAME:AddMessage(msg);
	end;
	SLASH_WARRIORTANK1 = "/tank";
end;

function WarriorTank_main()	
	local msNameTalent, msIcon, msTier, msColumn, msCurrRank, msMaxRank = GetTalentInfo(1,18);
	local btNameTalent, btIcon, btTier, btColumn, btCurrRank, btMaxRank = GetTalentInfo(2,17);
	local mainDamage = "Shield Slam";
	if (msCurrRank == 1) then mainDamage = "Mortal Strike";
	elseif (btCurrRank == 1) then mainDamage = "Bloodthirst"; end;
	local abilities = {"Shield Block", "Revenge", "Sunder Armor", "Heroic Strike", mainDamage};
	local ids = {};
	local sunder = KLHTM_Sunder;
	local cast = CastSpellByName;
	local rage = UnitMana("player");
	local sbTexture = "Ability_Defend";
	local revengeTexture = "Ability_Warrior_Revenge";
	local mainCost = 30;
	local impSunderNameTalent, impSunderIcon, impSunderTier, impSunderColumn, impSunderCurrRank, impSunderMaxRank = GetTalentInfo(3,10);
	local sunderRage = 15 - impSunderCurrRank;
	
	if(mainDamage == "Shield Slam") then mainCost = 20; end;
	
	for i = 1, 5, 1
		do
			if(WarriorTank_getSpellId(abilities[i]) ~= nil) then
				ids[i] = WarriorTank_getSpellId(abilities[i]);
			end;
	end;
	
	local sbStart, sbDuration, sbEnabled = GetSpellCooldown(ids[1], BOOKTYPE_SPELL);
	local mainStart, mainDuration, mainEnabled = GetSpellCooldown(ids[5], BOOKTYPE_SPELL);
	local reveStart, revDuration, revEnabled = GetSpellCooldown(ids[2], BOOKTYPE_SPELL);
	local revengeUsable = IsUsableAction(WarriorTank_findActionSlot(revengeTexture));
	
	--if shield block not active and not on cd then shield block
	if (WarriorTank_isBuffTextureActive(sbTexture) == false and sbDuration == 0 and rage >= 10) then cast(abilities[1]);
	--if enough rage for mainDamage and mainDamage not on cd then mainDamage
	elseif (rage >= mainCost and mainDuration == 0) then cast(abilities[5]);
	--if enough rage for revenge and revenge can be cast and random roll less than 7 then revenge
	elseif (rage >= 5 and revengeUsable == 1 and revDuration == 0) then cast(abilities[2]);
	--if enough rage for sunder then sunder
	elseif (rage >= sunderRage) then sunder(); end;
	
	--if rage >= 60 then heroic strike
	if (rage >= 60) then cast(abilities[4]); end;

end;

function WarriorTank_getSpellId(spell)
	local i = 1
	while true do
	   local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
	   if not spellName then
		  do break end
	   end
	   if spellName == spell then
	   return i; end;
	   i = i + 1
	end
end;

function WarriorTank_isBuffTextureActive(texture)
	local i=0;
	local g=GetPlayerBuff;
	local isBuffActive = false;

	while not(g(i) == -1)
	do
		if(strfind(GetPlayerBuffTexture(g(i)), texture)) then isBuffActive = true; end;
		i=i+1
	end;	
	return isBuffActive;
end;

function WarriorTank_findActionSlot(spellTexture)	
	for i = 1, 120, 1
		do
		if(GetActionTexture(i) ~= nil) then 
		if(strfind(GetActionTexture(i), spellTexture)) then return i; end; end;
	end;
	return 0;
end;