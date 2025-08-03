--Esotérico Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Negar efectos de monstruos encadenados antes de esta carta y barajarlos al Deck de tu adversario
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e0:SetCode(EVENT_CHAINING)
	e0:SetCondition(s.condition)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    --  1° Desterrar 1 monstruo "Terranigma" hasta el final de este turno
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.rmtg2)
	e1:SetOperation(s.rmop2)
	c:RegisterEffect(e1)
    --  2° Activar desde la mano si controlas un monstruo "Terranigma" de nivel 7 o mayor
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e2)
end
s.listed_series={0x3e7}
    --  *EFECTO 0°
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x3e7),tp,LOCATION_MZONE,0,1,nil) then return false end
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and te:IsMonsterEffect() and Duel.IsChainNegatable(i) then
			return true
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and te:IsMonsterEffect() and Duel.IsChainNegatable(i) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsOnField() and tc:IsRelateToEffect(te) and not tc:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(tp,tc) then
				dg:AddCard(tc)
			end
		end
	end
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and te:IsMonsterEffect() and Duel.NegateActivation(i) then
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) and not tc:IsHasEffect(EFFECT_CANNOT_TO_DECK) and Duel.IsPlayerCanSendtoDeck(tp,tc) then
				tc:CancelToGrave()
				dg:AddCard(tc)
			end
		end
	end
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
    --  *EFECTO 1°
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCountLimit(1)
			e1:SetOperation(s.retop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
    --  *EFECTO 2°
function s.actfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e7) and c:IsMonster() and c:IsLevelAbove(7)
end