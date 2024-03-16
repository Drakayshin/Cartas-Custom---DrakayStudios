--Murugan, El Azote Bestial
--Murugan, El Azote Bestial
local s,id=GetID()
function s.initial_effect(c)
	--Invocacion Xyz
	Xyz.AddProcedure(c,nil,5,3,nil,nil,99)
	c:EnableReviveLimit()
	--Al se Invocado por Xyz
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Enviar al Cementerio cartas en la Zona de monstruos o Zona de Magicas Trampa
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.dxmcostgen(2,2,nil))
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
end
s.listed_series={0x3e9}
    --Añadir 1 carta Magica/Trampa "Bestial"
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(0x3e9) and c:IsAbleToHand()
end    
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
    --Enviar al Cementerio cartas en la Zona de monstruos o Zona de Magicas Trampa
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if #sg==0 then return end
	local b1=sg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE)
	local b2=sg:IsExists(Card.IsLocation,1,nil,LOCATION_STZONE)
	local op=Duel.SelectEffect(tp,{b1,1002},{b2,1003})
	local bg=sg:Filter(Card.IsLocation,nil,op==1 and LOCATION_MZONE or LOCATION_STZONE)
	Duel.SendtoGrave(bg,POS_FACEUP,REASON_EFFECT)
	--No usar el proximo turno
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local reset=RESET_SELF_TURN
		if Duel.IsTurnPlayer(tp) then reset=RESET_OPPO_TURN end
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end