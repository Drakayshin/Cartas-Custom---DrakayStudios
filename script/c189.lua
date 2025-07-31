--Mausoleo del Trimilenio
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- 	*Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	-- 	0° Activación
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
    -- 	1° Añadir a la mano 
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    -- 	2° Ordenar las primeras 3 cartas del tope de tu Deck
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.cost)
	e2:SetTarget(s.excavtg)
	e2:SetOperation(s.excavop)
	c:RegisterEffect(e2)
    -- 	3° Robar 3 cartas y regresar 1 carta en tu mano al fondo del Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.drwcost)
	e3:SetTarget(s.drwtg)
	e3:SetOperation(s.drwop)
	c:RegisterEffect(e3)
end
    -- *EFECTO 1°
function s.thfilter(c)
	return c:IsOriginalRace(RACE_DIVINE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
    if not e:IsHasType(EFFECT_TYPE_IGNITION) then return end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,0),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
    -- *EFECTO 2°
function s.costfilter(c)
	return c:IsOriginalRace(RACE_DIVINE) and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
		Duel.ConfirmDecktop(tp,3)
		Duel.SortDecktop(tp,tp,3)
	end
    if not e:IsHasType(EFFECT_TYPE_IGNITION) then return end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,0),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
    -- *EFECTO 3°
function s.cfilter(c)
	return c:IsOriginalRace(RACE_DIVINE) and not c:IsPublic()
end
function s.drwcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==d then
		Duel.ShuffleHand(p)
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,2,2,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
    if not e:IsHasType(EFFECT_TYPE_IGNITION) then return end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        aux.RegisterClientHint(e:GetHandler(),EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,0),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end