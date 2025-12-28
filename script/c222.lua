--Dragón Crepuscular de Ojos Rojos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Solo puede ser Invocardo una vez por turno
    c:SetSPSummonOnce(id)
	--  *Invocación por Xyz y Debe ser Invocado por Xyz
	c:AddMustBeXyzSummoned()
    c:EnableReviveLimit()
	Xyz.AddProcedure(c,s.xyzfilter,nil,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
    --  0°  No puede ser usado como material para Xyz
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetValue(1)
    c:RegisterEffect(e0)
    --  0a° No puede ser destruido por efectos de cartas
    local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetValue(1)
	c:RegisterEffect(e0a)
    --  0b° Inafectado por efectos de Mágicas/Trampas
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0b:SetRange(LOCATION_MZONE)
	e0b:SetCode(EFFECT_IMMUNE_EFFECT)
	e0b:SetValue(function(e,te) return te:IsSpellTrapEffect() end)
	c:RegisterEffect(e0b)
	--  1° Si tu adversario Invoca de Modo Normal o Especial: Reduce su ATK y causar daño a tu adversario
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetCost(Cost.DetachFromSelf(1,1))
    e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1a)
    --  2° Si otro monstruo activa su efecto en el Campo: Negar activación, reduce su ATK y causar daño a tu adversario
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCost(Cost.DetachFromSelf(1,1))
	e2:SetCondition(s.necon)
	e2:SetTarget(s.netg)
	e2:SetOperation(s.neop)
	c:RegisterEffect(e2)
	--	3° Ganar 1 ataque y causar daño de penetración
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e3:SetCost(Cost.DetachFromSelf(1,1,nil))
	e3:SetCountLimit(1,{id,3})
	e3:SetTarget(s.atktg1)
	e3:SetOperation(s.atkop1)
	c:RegisterEffect(e3)
	--	4° Invocar 1 monstruo "Ojos Rojos" en tu Cementerio
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCountLimit(1,{id,4})
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_RED_EYES}
	--  *Filtro de materiales adicionales
function s.xyzfilter(c,xyz,sumtype,tp)
	return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and c:IsRank(7)
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_RED_EYES,lc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD_PHASE_END&~RESET_TOFIELD),0,1)
	return true
end
    --  *EFECTO 1°
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if #eg~=1 then return false end
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsSummonPlayer(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return tc:GetAttack()>0 and e:GetHandler():GetFlagEffect(id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,eg:GetFirst():GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
    --  *EFECTO 2°
function s.necon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and rc~=c and loc==LOCATION_MZONE
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.netg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,eg:GetFirst():GetAttack())
	end
end
function s.neop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
	--	*EFECTO 3°
function s.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:GetEffectCount(EFFECT_EXTRA_ATTACK)==0 
		and c:GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 and e:GetHandler():GetFlagEffect(id)==0
	end
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--	*Ganar 1 ataque adicional contra monstruos este turno, y causar daño de penegración
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3202)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		c:AddPiercing(RESETS_STANDARD_PHASE_END,c)
	end
end
	--	*EFECTO 4°
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsRankAbove(7) and (c:IsRace(RACE_DRAGON) or c:IsSetCard(SET_RED_EYES)) and c:IsFaceup()
	and (Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or not c:IsLocation(LOCATION_EXTRA)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_GRAVE|LOCATION_REMOVED end
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_GRAVE|LOCATION_REMOVED end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.BreakEffect()
		Duel.Overlay(g:GetFirst(),c)
	end
end