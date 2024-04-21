--Defensor de Oricalcos
--Defensor de Oricalcos
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--Debe ser Invocada de forma especifica
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
    --No hay daño por batalla
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetCondition(s.rdcon)
	e2:SetOperation(s.rdop)
	c:RegisterEffect(e2)
    --No puede ser desterrada
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(s.rmlimit)
	c:RegisterEffect(e4)
    --ATK Mejorado
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SET_ATTACK_FINAL)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.cona)
	e5:SetValue(s.adval)
	c:RegisterEffect(e5)
    --Cambio de objetivo de batalla
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_ATTACK_ANNOUNCE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.cbcon)
	e6:SetOperation(s.cbop)
	c:RegisterEffect(e6)
end
s.listed_names={120,48179391}
--Debe ser Invocada de forma especifica
function s.splimit(e,se,sp,st)
	return se:GetHandler():ListsCode(48179391)
end
    --No hay daño por batalla
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttackTarget()~=nil and tp==ep
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end
    --No puede ser desterrada
function s.rmlimit(e,c,p)
	return e:GetHandler()==c
end
    --Ataque Mejorado
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
    --Defensa Mejorada
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