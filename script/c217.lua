--Eónlepydae Périlleux 
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    --  1° Inafectado por efectos de monstruos con ATK original de 2900 o menos
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.immval)
	c:RegisterEffect(e0)
	--  1° Evitar activación de efectos de monstruos y reducir de ATK a 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    --  2° Destruir y causar daño
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)

    --  EFECTO DE PENDULO

    -- 	3° Limite de Invocación por Péndulo a Dinosaruio, Reptil o Serpiente Marina
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)return not c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM end)
    c:RegisterEffect(e3)
    --  4° Ganar ATK igual al Nivel x100
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(function(e,c) return c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and c:HasLevel() end)
	e4:SetValue(function(e,c) return c:GetLevel()*100 end)
    c:RegisterEffect(e4)
    --  5° Invocar de Modo Epecial desde la Zona de Péndulo
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_PZONE)
    e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e5:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
    --  *EFECTO 0°
function s.immval(e,te)
    return te:IsMonsterEffect() and te:GetOwner()~=e:GetHandler()
    and te:GetOwner():GetBaseAttack()<=2900 and te:GetOwner():GetBaseAttack()>=0
end
    --  *EFECTO 1
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.atkfilter(c)
	return c:IsFaceup()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		--  *Cambiar el ATK a 0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--  *No pueden activar sus efectos
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(3302)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
    --  *EFECTO 2°
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,false,nil,nil) end
	local sg=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,nil)
	Duel.Release(sg,REASON_COST)
	e:SetLabelObject(sg:GetFirst())
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpellTrap),tp,0,LOCATION_ONFIELD,1,nil) end
	local tc=e:GetLabelObject()
	local dam=tc:GetBaseAttack()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSpellTrap),tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetTargetCard(g:GetFirst())
	Duel.SetTargetPlayer(tc:GetOwner())
	Duel.SetTargetParam(dam/2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tc:GetOwner(),dam/2)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end	
    -- 	*EFECTO 5°
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.cfilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_WATER)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=Duel.GetFirstTarget()
		if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
        --  *Reducir ATK a la mitad
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(tc:GetAttack()/2)
        tc:RegisterEffect(e2)
        --  *Destruir 1 monstruo que no sea de AGUA y causar daño igual a su ATK
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        if #g>0 then
            local atk=math.min(g:GetFirst():GetAttack())
            if atk<0 then atk=0 end
            Duel.HintSelection(g)
            if Duel.Destroy(g:GetFirst(),REASON_EFFECT)>0 then
                Duel.Damage(1-tp,atk,REASON_EFFECT)
            end
        end
	end
end