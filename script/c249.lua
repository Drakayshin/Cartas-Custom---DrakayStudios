--Persuasión Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Negar Invocación
    local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_SPSUMMON)
    e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.condition)
	e0:SetTarget(s.target)
	e0:SetOperation(s.negarop)
	c:RegisterEffect(e0)
	--  1° Negar la activación o efecto que incluya invocar de Modo Especial
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.condition1)
    e1:SetOperation(s.negarop1)
    c:RegisterEffect(e1)
    --  2° Activar en el turno que es colocada
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.setfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e2)
end   
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ee)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.GetCurrentChain(true)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end
function s.negarop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsChainDisablable(0) then
		local sel=1
		local g=Duel.GetMatchingGroup(Card.IsSpell,tp,0,LOCATION_HAND,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
		if #g>0 then
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
			Duel.NegateEffect(0)
			return
		end
	end
    Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end
    --  *EFECTO 1°
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
    if tp==ep or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and Duel.IsChainDisablable(ev)
end
function s.negarop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsChainDisablable(0) then
		local sel=1
		local g=Duel.GetMatchingGroup(Card.IsSpell,tp,0,LOCATION_HAND,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
		if #g>0 then
			sel=Duel.SelectOption(1-tp,1213,1214)
		else
			sel=Duel.SelectOption(1-tp,1214)+1
		end
		if sel==0 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
			local sg=g:Select(1-tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
			Duel.NegateEffect(0)
			return
		end
	end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
    --  *EFECTO 2°
function s.setfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ee) and c:IsType(TYPE_TUNER) and c:IsLevelAbove(4)
end