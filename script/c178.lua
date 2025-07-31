--Dragón Clúster Ciberoscuro
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	*Invocación por Xyz
	Xyz.AddProcedure(c,s.mfilter,6,3,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats,s.xyzop)
	c:EnableReviveLimit()
	-- 	0° Evitar Destrucción
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_DESTROY_REPLACE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTarget(s.reptg)
	c:RegisterEffect(e0)
    -- 	1° Equipar 1 Dragon o Máquina de cualquier Cementerio a esta carta
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(Cyberdark.EquipTarget(aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON|RACE_MACHINE),true,true))
	e1:SetOperation(Cyberdark.EquipOperation(aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON|RACE_MACHINE),s.equipop,true))
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e1)
    -- 	2° Ataque directo
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetCondition(s.indcon)
	c:RegisterEffect(e2)
	-- 	3° Cambio de ATK por Ataque directo
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
    -- 	4° Penetración
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
    e4:SetCondition(s.indcon)
	c:RegisterEffect(e4)
    -- 	5° Daño por efecto
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(s.indcon)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_CYBER,SET_CYBERDARK}
	-- 	*Filtro de materiales
function s.mfilter(c,xyz,sumtype,tp)
	return c:IsRace(RACE_MACHINE,xyz,sumtype,tp)
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:GetRank()==5 and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:IsRace(RACE_MACHINE,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
	-- 	*EFECTO 0°
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)>0
end
    -- 	*EFECTO 1°
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsRace(RACE_DRAGON+RACE_MACHINE)
end
function s.equipop(c,e,tp,tc)
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,nil,true) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(atk)
	tc:RegisterEffect(e2)
end
	-- 	*Condición general (Materiales especificos)
function s.indcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,2,nil,0x4093)
end
    -- 	*EFECTO 3°
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()==nil and e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
		and Duel.IsExistingMatchingCard(aux.NOT(Card.IsHasEffect),tp,0,LOCATION_MZONE,1,nil,EFFECT_IGNORE_BATTLE_TARGET)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local effs={c:GetCardEffect(EFFECT_DIRECT_ATTACK)}
	local eg=Group.CreateGroup()
	for _,eff in ipairs(effs) do
		eg:AddCard(eff:GetOwner())
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local ec = #eg==1 and eg:GetFirst() or eg:Select(tp,1,1,nil):GetFirst()
	if c==ec then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c:GetAttack()/2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end
-- 	*EFECTO 5°
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end