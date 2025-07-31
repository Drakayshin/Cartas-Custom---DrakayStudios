--Anthokyli Périlleux
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
    -- 	0° Inafectada por efectos de monstruos que no sean Péndulo
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetValue(function(e,te) return te:IsMonsterEffect() and not te:GetOwner():IsType(TYPE_PENDULUM) end)
	c:RegisterEffect(e0)
    -- 1° Aumenta 1000 DEF si es Invocado por Péndulo
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.defcon)
	e1:SetOperation(s.defop)
	c:RegisterEffect(e1)
    -- 	2° Puede atacar en Posición de Defensa
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e2)

    -- 	EFECTO DE PENDULO

	-- 3° Negar efecto de selección en el Campo
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
    -- 	*EFECTO 1°
function s.defcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_PENDULUM and c:IsPreviousLocation(LOCATION_HAND)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(c:GetBaseDefense()+1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
	--	*EFECTO 3°
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and c:IsControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(id)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and g and g:IsExists(s.cfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		if Duel.NegateEffect(ev) then
			Duel.BreakEffect()
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end