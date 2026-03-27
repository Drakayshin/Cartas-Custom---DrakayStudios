--Trance, el Hechiero Divergente
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:AddMustBeSpecialSummonedByCardEffect()
	--  0° Invocar de Modo Especial
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --  1° Desterrar 1 carta en el Campo por selección
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.rmcost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
    --  *EFECTO 0°
function s.spconfilter(c)
	return c:IsRace(RACE_SPELLCASTER|RACE_WARRIOR) and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spconfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,nil,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #sg>0 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		local sc=g:GetFirst()
		if sc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sc)
		else
			Duel.HintSelection(sc)
		end
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
	--  *EFECTO 1°
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttackAnnouncedCount()==0 end
	--	*No puede atacar este turno
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1,true)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end