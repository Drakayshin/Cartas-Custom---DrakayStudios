--Aqlis, Emisario Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	 0° No puede ser Invocado de Modo Especial
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(e0)
	-- 	1° Buscar 1 Mágica/Trampa "Terranigma"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
    --	2° Robar y Buscar 1 monstruo "Terranigma"
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x3e7}
	-- 	*EFECTO 1°
function s.cfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsSetCard(0x3e7)) and (c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED)) and c:IsAbleToDeckAsCost()
end
function s.splimit(e,c)
	return not (c:IsSetCard(0x3e7) and c:IsMonster())
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,3,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg>0 then
		Duel.SendtoDeck(sg,nil,3,REASON_COST)
	end
	-- 	*Solo puedes Invocar de Modo Especial monstruos "Terranigma"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.counterfilter(c)
	return c:IsSetCard(0x3e7) and c:IsMonster()
end
function s.thsetfilter(c)
	return c:IsSetCard(0x3e7) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thsetfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.thsetfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not sc then return end
	aux.ToHandOrElse(sc,tp,function(sc) return sc:IsSSetable() end,function(sc) Duel.SSet(tp,sc) end,aux.Stringid(id,3))
end
    -- 	*EFECTO 2°
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsLocation(LOCATION_GRAVE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(0x3e7) and c:IsMonster() and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg2=g2:Select(tp,1,1,nil)
		Duel.SendtoHand(tg2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg2)
	end
end