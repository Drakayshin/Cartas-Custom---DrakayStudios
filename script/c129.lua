--Defensor de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	-- Debe ser Invocada de forma especifica
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
    -- No hay daño por batalla
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(s.rdcon)
	e1:SetOperation(s.rdop)
	c:RegisterEffect(e1)
    -- No puede ser desterrada
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
	c:RegisterEffect(e3)
    -- ATK Mejorado
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_ATTACK_FINAL)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.cona)
	e4:SetValue(s.adval)
	c:RegisterEffect(e4)
    -- Cambio de objetivo de batalla
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.cbcon)
	e5:SetOperation(s.cbop)
	c:RegisterEffect(e5)
end
s.listed_names={120,48179391}
-- Debe ser Invocada de forma especifica
function s.splimit(e,se,sp,st)
	return se:GetHandler():ListsCode(48179391)
end
    -- No hay daño por batalla
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()~=nil and tp==ep
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end
    -- No puede ser desterrada
function s.rmlimit(e,c,p)
	return e:GetHandler()==c
end
    -- Ataque Mejorado
function s.cona(e)
	return e:GetHandler():IsAttackPos()
end
function s.adval(e,c)
	local ph=Duel.GetCurrentPhase()
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if ph==PHASE_DAMAGE_CAL or PHASE_DAMAGE or Duel.IsDamageCalculated() and c:IsRelateToBattle() then
		if a==c and d and d:IsAttackPos() then return d:GetAttack()+300 end
		if a==c and d and d:IsDefensePos() then return d:GetDefense()+300 end
		if d==c then return a:GetAttack()+300 end
		if a~=c and d~=c then return 0 end
	end
	if not ph==PHASE_DAMAGE_CAL or not PHASE_DAMAGE or not Duel.IsDamageCalculated() then return 0 end
end
    -- Defensa Mejorada
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos() and Duel.GetTurnPlayer()~=tp
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ChangeAttackTarget(c)
	local b=Duel.GetAttacker()
	local def=b:GetAttack()+300
	e:SetLabel(def)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1:SetValue(def)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e1)
end