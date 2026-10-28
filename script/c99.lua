--Ëvhay, La Veleidad Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  *Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	--  Efecto 0: Solo puede ser Invocado de Modo Especial por el efecto de "Evocación Terranigma"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(function(e,se,sp,st) return se:GetHandler():IsCode(81) end)
	c:RegisterEffect(e0)
	-- 	Efecto 1: Requiere 3 o más Sacrificios (no puede ser colocada)
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,99,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0))
	local e1a=aux.AddNormalSetProcedure(c)
	--	Efecto 1b: La Invocación Normal de esta carta no puede ser negada.
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1b)
	--	Efecto 2: Pagar 400 LP por activación de cartas 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(s.costchk)
	e2:SetOperation(s.costop)
	c:RegisterEffect(e2)
	--	Efecto 3: Inafectada hasta tu proxima End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3a)
	--	Efecto 4: Efectos en secuencia
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(TIMING_BATTLE_PHASE,TIMING_BATTLE_PHASE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)<=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)-1 end)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_names={81}
s.listed_series={0x3e7}
	--	*EFECTO 2°
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*400)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,400)
end
	--	*EFECTO 3°
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.IsTurnPlayer(tp) and 3 or 2
	--Unaffected by other cards' effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3100)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,re) return e:GetHandler()~=re:GetOwner() end)
	e1:SetReset(RESETS_STANDARD_PHASE_END,ct)
	c:RegisterEffect(e1)
end
	--	*EFECTO 4°
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	--	1+: 
	if val>=1 then
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x3e7),tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
	--	5+: Reducir daño recibido a la mitad este turno
	if val>=5 then
		Duel.BreakEffect()
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(1,0)
		e2:SetValue(function(e,re,val,r,rp,rc) return math.floor(val/2) end)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		Duel.RegisterEffect(e2,tp)
	end
	--	10+: "OPCIONAL" Desterrar (boca arriba) hasta 2 cartas del Deck Extra del adversario
	if val>=10 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsFacedown,Card.IsAbleToRemove),tp,0,LOCATION_EXTRA,nil)
		local ct=1
		ct=Duel.AnnounceNumber(tp,1,2,3)
		local rg=g:RandomSelect(tp,ct)
		if #g>0 then Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT) end
	end
	--	15+: Reducir a la mitad los LP de tu adversario
	if val>=15 then
		Duel.BreakEffect()
		Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	end
end