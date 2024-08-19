--Custodia del Infra-Soberano
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Negar Activacion
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetCountLimit(1,{id,1})
	e0:SetCondition(s.negcon)
	e0:SetTarget(s.negtg)
	e0:SetOperation(s.negop)
	c:RegisterEffect(e0)
	-- Traslado de destruccion
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,2})
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
    -- Puedes activar desde la mano
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
s.listed_names={132}
s.listed_series={0x3e9}
	-- Negar
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e9)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.vsfilter(c)
	return c:IsCode(132)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and Duel.IsExistingMatchingCard(s.vsfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and re:GetHandler():IsDestructable() 
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		ec:CancelToGrave()
		Duel.SendtoDeck(ec,1,1,REASON_EFFECT)
	end
end
    -- Evitar destruccion
function s.repfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x3e9) and c:IsControler(tp) and not c:IsReason(REASON_REPLACE)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
    -- Activar desde la mano
function s.handcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,132),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end