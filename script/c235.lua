--Fanis, El Mago Flamante
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Inafectada por efectos activos de cartas Mágicas/ de Trampa
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
    e0:SetValue(function(e,te) return te:IsActivated() and te:IsSpellTrapEffect() and te:GetOwner()~=e:GetOwner() end)
    c:RegisterEffect(e0)
    --  1° Invocar de Modo Especial desde la mano y posible alteración de Nivel
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.PayLP(500))
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --  2° Invocar de Modo Especial 1 monstruo "Flamante" desde tu mano o destierro que no sea Cantante
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.shucost)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
end
s.listed_series={0x3ee}
    --  *EFECTO 1°
function s.spconfilter(c)
	return c:IsSetCard(0x3ee) and not c:IsType(TYPE_TUNER) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--  *Alterar el Nivel de esta carta
		if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end
    --  *EFECTO 3
function s.unfilter(c)
	return c:IsRace(RACE_WARRIOR|RACE_BEASTWARRIOR) or (c:IsMonster() and c:IsSetCard(0x3ee)) and c:IsAbleToDeckOrExtraAsCost()
end
function s.shucost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.unfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,aux.dncheck,0) end
	local gp=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TODECK)
	Duel.SendtoDeck(gp,nil,2,REASON_COST)
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x3ee) and not c:IsType(TYPE_TUNER)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_REMOVED,0,nil,e,tp)
	if #tg==0 or ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=math.min(ft,tg:GetClassCount(Card.GetCode))
	local g=aux.SelectUnselectGroup(tg,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			--Send them to the GY during the End Phase
			aux.DelayedOperation(g,PHASE_END,id,e,tp,
				function(dg) Duel.SendtoGrave(dg,REASON_EFFECT) end,
				nil,0,1,aux.Stringid(id,1)
			)
	end
end