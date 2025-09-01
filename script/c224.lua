--Leyenda de Ojos Rojos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Añadir a la mano 1 monstruo "Ojos Rojos" desde tu Deck
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    --  1° Invocar por Fusión usando monstruos incluyendo 1 "Ojos Rojos"
    local params={handler=c,extrafil=s.fmatextra}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(Fusion.SummonEffTG(params))
	e1:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e1)
end
s.listed_series={SET_RED_EYES}
    --  *EFECTO 0°
function s.thfilter(c)
	return c:IsSetCard(SET_RED_EYES) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		local lv=tc:GetOriginalLevel()
		local lp=Duel.GetLP(tp)
		Duel.SetLP(tp,lp-lv*100)
	end
end
    --  *EFECTO 1°
function s.extramatcheck(tp,sg,fc)
	return sg:IsExists(aux.FilterBoolFunction(Card.IsSetCard,SET_RED_EYES,fc,SUMMON_TYPE_FUSION,tp),1,nil)
end
function s.fmatextra(e,tp,mg)
	return nil,s.extramatcheck
end