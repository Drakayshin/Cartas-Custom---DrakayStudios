--Convergencia Flauriga
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Negación y destierro
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_CHAINING)
    e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e0:SetCost(Cost.PayLP(1200))
	e0:SetCondition(s.negcon)
	e0:SetTarget(s.negtg)
	e0:SetOperation(s.negop)
    c:RegisterEffect(e0)
    --  1° Activar en el turno que es colocada
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.setfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e1)
end
s.listed_series={0x3ee}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ee)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	return re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then return rc:IsAbleToRemove(tp)
		or (not relation and Duel.IsPlayerCanRemove(tp)) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
    --  *EFECTO 1°
function s.setfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ee) and c:IsType(TYPE_TUNER) and c:IsLevelAbove(4)
end