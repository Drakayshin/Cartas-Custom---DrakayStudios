--Raikiri Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- No crear cadena de cartas
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,{id,1})
	e0:SetOperation(s.acop)
	c:RegisterEffect(e0)
	-- Destruir durante la End Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_REPEAT)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1,{id,2})
	e1:SetCondition(s.decon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3e9}
    -- No encadenar
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetOperation(s.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x3e9) and ep==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
    -- Destruir durante la End Phase
function s.decon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x3e9),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.desfilter(c)
	return c:IsFaceup() and c:GetAttackAnnouncedCount()==0 and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.desfilter,Duel.GetTurnPlayer(),LOCATION_MZONE,0,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
end
