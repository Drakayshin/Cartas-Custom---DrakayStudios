--Saurio Campeador
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	0° Añadir efectos a un monstruo "Saurio Guerrero"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCategory(CATEGORY_DESTROY)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER_E|TIMING_DAMAGE_STEP)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e0:SetCondition(function() return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated() end)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
end
s.listed_series={0x3ea,65601601}
	--	*EFECTO 0°
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3ea)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- Inafectado
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3110)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
        -- Indestructible por batalla
		local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e2:SetValue(1)
        e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
        tc:RegisterEffect(e2)
        -- Destrucción
        local e3=Effect.CreateEffect(tc)
		e3:SetDescription(aux.Stringid(id,1))
		e3:SetCategory(CATEGORY_DESTROY)
		e3:SetType(EFFECT_TYPE_QUICK_O)
        e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetRange(LOCATION_MZONE)
        e3:SetCountLimit(1)
		e3:SetTarget(s.destg)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e3)
	end
end
    -- Inafectador por el adversario
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
    -- Destrucción
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_STZONE,1,c) end
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,LOCATION_STZONE,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_STZONE,e:GetHandler())
	Duel.Destroy(sg,REASON_EFFECT)
end
