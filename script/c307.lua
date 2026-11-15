--Promoción Dragoncella
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Activación y posible busqueda
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	--  Efecto 1: La activación y efectos no pueden ser negados
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.tgcon)
	e1:SetValue(s.efilter)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
    e1a:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1a:SetValue(s.efilter)
    c:RegisterEffect(e1a)
    --  Efecto 2: Invocación por Fusion
    local params={aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),Fusion.OnFieldMat}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(Cost.SelfToGrave)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRAGONMAID}
    --  *EFECTO 0°
function s.thfilter(c)
	return c:IsSetCard(SET_DRAGONMAID) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK|LOCATION_REMOVED,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
    --  *EFECTO 1°
function s.tgcon(e)
	return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,TYPE_FUSION)
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return tc:IsSetCard(SET_DRAGONMAID)
end