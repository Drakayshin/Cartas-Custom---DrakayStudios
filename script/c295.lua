--Ermitaño Fragoso de la Fábula
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  Efecto 0: Mostrar en la mano para buscar y barajarse al Deck
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(Cost.SelfReveal)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
    c:RegisterEffect(e0)
    --  Efecto 1:Invocar de Modo Especial 1 monstruo
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.thsptg)
    e1:SetOperation(s.thspop)
    c:RegisterEffect(e1)
end
s.listed_names={290}
    --  *EFECTO 0°
function s.thfilter(c)
	return c:IsCode(290) or (c:ListsCode(290) and c:IsMonster()) and not c:IsCode(id) and c:IsAbleToHand()
	and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
		if c:IsRelateToEffect(e) then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
    --  *EFECTO 1°
function s.thspfilter(c,e,tp,mzone_chk)
	return c:IsLevel(4) and c:IsMonster() and (c:IsAbleToHand() or (mzone_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,mzone_chk):GetFirst()
	aux.ToHandOrElse(sc,tp,
		function()
			return mzone_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end,
		function()
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end,
		aux.Stringid(id,3)
	)
	local c=e:GetHandler()
end