--Neo Anquilosaurio Périlleux
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    -- 	0° Atacar por segunda vez e intercambiar el ATK y DEF original de esta carta
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e0:SetCode(EVENT_BATTLE_DESTROYING)
    e0:SetCountLimit(1)
	e0:SetCondition(s.atkcon)
	e0:SetTarget(s.atktg)
	e0:SetOperation(s.atkop)
	c:RegisterEffect(e0)
    --  1° Volver inafectada por efectos actde monstruos, excepto Monstruos Péndulo
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.indcon)
	e1:SetOperation(s.indop)
    c:RegisterEffect(e1)
    
    -- 	EFECTO DE PENDULO

	--	2 Reducir el daño por batalla a 0 por turno
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and not e:GetHandler():HasFlagEffect(id) end)
	e2:SetOperation(s.nodamop)
	c:RegisterEffect(e2)
	--	3° Negar efecto activado y resuelto en el Campo del adversario
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
    --  *EFECTO 0°
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler() and aux.bdocon(e,tp,eg,ep,ev,re,r,rp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsRelateToBattle() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToBattle() and c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	--  *Hacer un segundo ataque esta Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3201)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
    c:RegisterEffect(e1)
    --  *Intercambiar el ATK y DEF de esta carta por este turno
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	e2:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
	c:RegisterEffect(e2)
end
    --  *EFECTO 1°
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_PENDULUM
end
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--	*No puede ser afectada por efectos de monstruos, excepto Monstruos Péndulo
		local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
        e1:SetRange(LOCATION_MZONE)
		e1:SetValue(function(e,te) return te:IsMonsterEffect() and not te:GetOwner():IsType(TYPE_PENDULUM) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
	--	*EFECTO 2°
function s.nodamop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SelectEffectYesNo(tp,c) then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		Duel.Hint(HINT_CARD,0,id)
		Duel.ChangeBattleDamage(tp,0)
	end
end
	--	*EFECTO 3°
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.IsChainDisablable(ev) and not Duel.HasFlagEffect(tp,id)
	and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3)) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.NegateEffect(ev) then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
	end
end