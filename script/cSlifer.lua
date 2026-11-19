--Conversión Numeron
--DrakayStudios
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)
local s,id=GetID()
function s.initial_effect(c)
	-- Efecto 0: Invocar de Modo Especial 1 Monstruo Xyz del Cementerio y acoplarle esta carta
	-- Stat reduction effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE) -- Change to LOCATION_MZONE if it's a monster effect
	e1:SetTargetRange(0, LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_SZONE) -- Change to LOCATION_MZONE if it's a monster effect
	e2:SetTargetRange(0, LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	-- Destruction check when ATK or DEF becomes 0 due to this effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE) -- Change to LOCATION_MZONE if it's a monster effect
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RANK_UP_MAGIC}
function s.val(e, c)
	return -2000
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.desfilter, tp, 0, LOCATION_MZONE, nil)
	if #g > 0 then
	Duel.Destroy(g, REASON_EFFECT)
	end
end
function s.desfilter(c)
-- Check if opponent's monster has 0 or less ATK or DEF
-- Note: GetAttack() and GetDefense() already factor in continuous modifications like EFFECT_UPDATE_ATTACK (-2000)
	return c:IsFaceup() and (c:GetAttack()<=0 or c:GetDefense()<=0)
end