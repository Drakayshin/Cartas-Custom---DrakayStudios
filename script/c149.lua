--Retorno del Postergado
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	0° Invocar por Ritual
	local e0=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,location=LOCATION_GRAVE|LOCATION_REMOVED,matfilter=s.mfilter})
	e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(s.thcost)
	c:RegisterEffect(e0)
	-- 	1° Evitar Destrucción de uno o más Monstruos Ritual
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
end
	--	*EFECTO 0°
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_MZONE)
end
    --	*EFECTO 1°
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsType(TYPE_RITUAL) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and e:GetHandler():IsAbleToRemove()
		and eg:IsExists(s.repfilter,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return true
	else
		return false
	end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end