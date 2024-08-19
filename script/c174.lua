--Dragón Clúster Ciberoscuro
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Invocación por Xyz
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),4,3,nil,nil,5)
	c:EnableReviveLimit()
    -- Condición de Invocación
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
    -- Equipar 1 Dragon de cualquier Cementerio a esta carta
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)
    aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),s.equipop,e2)
    local e2=e1:Clone()
    e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),s.equipop,e3)
    local e3=e1:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),s.equipop,e4)
    -- Ataque directo
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
    e4:SetCondition(s.indcon)
	c:RegisterEffect(e4)
	-- Cambio de ATK por Ataque directo
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
    -- Penetración
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_PIERCE)
    e6:SetCondition(s.indcon)
	c:RegisterEffect(e6)
    -- Daño por efecto
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	e7:SetCondition(s.indcon)
	e7:SetTarget(s.damtg)
	e7:SetOperation(s.damop)
	c:RegisterEffect(e7)
end
s.listed_series={SET_CYBER,SET_CYBERDARK}
    -- Condición de Invocación
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st&SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ and not se)
end
    -- Equipar 1 Dragon de cualquier Cementerio a esta carta
function s.filter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,tp) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	if not c:EquipByEffectAndLimitRegister(e,tp,tc) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(atk)
	tc:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetValue(s.repval)
	tc:RegisterEffect(e3)
end
function s.repval(e,re,r,rp)
	return (r&REASON_BATTLE)~=0
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and s.filter(tc,tp) then
		s.equipop(c,e,tp,tc)
	end
end
    -- Cambio de ATK por Ataque directo
function s.indcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,3,nil,0x4093)
end
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
    -- Causar daño
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