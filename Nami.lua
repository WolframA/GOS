    require('IAC')
	Config = scriptConfig("Nami", "Wolf Nami")
	Config.addParam("Q", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.addParam("R", "Use R", SCRIPT_PARAM_ONOFF, true)
	Config.addParam("Circle", "Use HB Circle", SCRIPT_PARAM_ONOFF, true)
	Config.addParam("Nearby", "Use Nearby", SCRIPT_PARAM_ONOFF, true)
	Config.addParam("Combo", "Combo Key", SCRIPT_PARAM_KEYDOWN, string.byte(" "))
	
	OnLoop(function(myHero)
    local killable
    local myTarget = GetTarget(1000, DAMAGE_MAGICAL)
    if myTarget ~= nil then
	
		local damage = 0
		local HP  = GetCurrentHP(myTarget)
		local mana = GetCurrentMana(myHero)
		local AD = GetBonusDmg(myHero)
		local AP = GetBonusAP(myHero)
		local targetPos = GetOrigin(myTarget)
		local drawPos = WorldToScreen(1,targetPos.x,targetPos.y,targetPos.z)
		
		if CanUseSpell(myHero, _Q) == READY and GetCastLevel(myHero,_Q) > 0 then
		  damage = damage + CalcDamage(myHero, myTarget, 0, 75+55*GetCastLevel(myHero,_Q) + 0.5 * AP)
		end
		
		if CanUseSpell(myHero, _W) == READY and GetCastLevel(myHero,_W) > 0 and (mana > (GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q)) * 2 )+ GetCastMana(myHero,_W,GetCastLevel(myHero,_W))) then
		  damage = damage + CalcDamage(myHero, myTarget, 0, 70+40*GetCastLevel(myHero,_Q) + 0.5 * AP)
		end
		
		if damage > HP then
		  DrawText("Kill them!",20,drawPos.x,drawPos.y,0xffff0000)
		  DrawDmgOverHpBar(myTarget,HP,0,HP,0xffff0000)
		  killable = true
		else

		  DrawText(math.floor(100 * damage / HP).."% ",20,drawPos.x,drawPos.y,0xffffffff)
		  DrawDmgOverHpBar(myTarget,HP,0,damage,0xffffffff)
		  killable = false
		end
		
	end
	
	  -- BEGIN SAFETY CHECKS
  local myOrigin = GetOrigin(myHero)
  local myScreenpos = WorldToScreen(1,myOrigin.x,myOrigin.y,myOrigin.z)
  local enemiesAround = EnemiesAround(GetOrigin(myHero),3500)
  DrawCircle(myOrigin.x,myOrigin.y,myOrigin.z,300,0,0,0xffffffff)
  if enemiesAround > 0 and Config.Nearby then
	DrawTextSmall(string.format("Enemies Near  = %d",enemiesAround),myScreenpos.x,myScreenpos.y-20,ARGB(255,255,255/enemiesAround,255/enemiesAround))	
  end
  if Config.Circle then
	local mousepos = GetMousePos()
	DrawCircle(mousepos,GetHitBox(myHero),0,0,0xff00ff00)
  end
  
  function Combo()
    local myOrigin = GetOrigin(myHero)
	local myScreenpos = WorldToScreen(1,myOrigin)
	DrawTextSmall("COMBO",myScreenpos.x,myScreenpos.y-80,0xff00ff00)
	  local myTarget = GetCurrentTarget()
	  local mypred = nil
	  if myTarget ~=nil and IsImmune(myTarget,myHero) == false then
	  
		if CanUseSpell(myHero, _Q) == READY and IsInDistance(myTarget, 865) and Config.Q then
			mypred = GetPredictionForPlayer(myOrigin,myTarget,GetMoveSpeed(myTarget),math.huge,950,GetCastRange(myHero,_Q),135,false,true)
	    end
		if mypred and mypred.HitChance == 1 and Config.Q then
				 CastSkillShot(_Q,mypred.PredPos)
		end
	  
		-- Check allies for missing hp, cast W if they aren't max. (Plan to upgrade)
		for _,v in pairs(GetAllyHeroes()) do 
			if CanUseSpell(myHero, _W) == READY then
				if IsInDistance(v,725) and IsObjectAlive(v) and (GetCurrentHP(v) < GetMaxHP(v))  then
					CastTargetSpell(v,_W)
				end
			end
		end
		
		if CanUseSpell(myHero, _W) == READY and IsInDistance(myTarget, 725) and (GetCurrentMana(myHero) >= GetCastMana(myHero,_W,GetCastLevel(myHero,_W)) + GetCastMana(myHero,_Q,GetCastLevel(myHero,_Q))) then
				CastTargetSpell(myTarget,_W)
		end
		  
		if CanUseSpell(myHero, _R) == READY and IsInDistance(myTarget, 800) and Config.R then
			myRpred = GetPredictionForPlayer(myOrigin,myTarget,GetMoveSpeed(myTarget),850,950,GetCastRange(myHero,_Q),250,false,false)
	    end
		if myRpred and myRpred.HitChance == 1 and Config.R and IsInDistance(myTarget, 800)then
				 CastSkillShot(_R,myRpred.PredPos)
		end
		  
	  end
	  end
	  if Config.Combo then
		Combo()
		end
	 end)