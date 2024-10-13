--Raikiri Bestial
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- No crear cadena de cartas
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.acop)
	c:RegisterEffect(e0)
	-- Converción del daño
	local e1=e0:Clone()
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(_,tp) return Duel.GetLP(tp)<Duel.GetLP(1-tp) end)
	e1:SetOperation(s.covp)
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
    -- Converción del daño
function s.covp(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
