--Ryu Zohak Périlleux
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --	*Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	--  *Proceso de Péndulo
    Pendulum.AddProcedure(c,false)
    --  *Invocación por Fusión
    c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.ffilter,4)
	--  *Fusión por contacto
	Fusion.AddContactProc(c,s.contactfil,s.contactop,false,nil,1)
    --	Efecti 0: Invocar solo una vez por turno por Invocación o Fusión o Fusión por contacto
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
    c:RegisterEffect(e0)
    --  Efecto 1: Puede atacar en Posición de Defensa
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e1)
    --  Efecto 2: Colocar esta carta en tu Zona de Péndulo
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.CheckPendulumZones(tp) end end)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	--  Efecto 3: Destruir todos los monstruos que tengan ATK igual o menor al ATK de esta carta
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,3})
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
    --  Efecto 4: Reducir 2000 ATK/DEF a un monstruo en el Campo de tu adversario
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_END_PHASE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(Cost.PayLP(2000))
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
    --  Efecto 5: Negar efecto y cambiar la posición de batalla de est carta
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_POSITION+CATEGORY_NEGATE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,4})
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPosition(POS_ATTACK) and rp==1-tp and Duel.IsChainDisablable(ev) end)
	e5:SetTarget(s.distg)
	e5:SetOperation(s.disop)
    c:RegisterEffect(e5)
    
    --  EFECTO DE PENDULO

    -- 	Efecto 6: Limite de Invocación por Péndulo a Monstruos Péndulo
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_PZONE)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e6:SetTargetRange(1,0)
	e6:SetTarget(function(e,c,sump,sumtype,sumpos,targetp)return not c:IsType(TYPE_PENDULUM) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM end)
	c:RegisterEffect(e6)
	--	Efecto 7: Negar efectos de monstruos en el Campo del adversario
	local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,5))
    e7:SetCategory(CATEGORY_DISABLE)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetRange(LOCATION_PZONE)
    e7:SetCountLimit(1,{id,5})
    e7:SetCost(s.negcost)
    e7:SetTarget(s.negtg)
    e7:SetOperation(s.negop)
	c:RegisterEffect(e7)
	-- 	Efecto 8: Invocar desde la Zona de Péndulo
	local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,6))
    e8:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e8:SetType(EFFECT_TYPE_IGNITION)
    e8:SetRange(LOCATION_PZONE)
    e8:SetCountLimit(1,{id,6})
    e8:SetCondition(s.spcon)
    e8:SetTarget(s.sptg)
    e8:SetOperation(s.spop)
    c:RegisterEffect(e8)
end
    --  *Filtro de materilaes de Fusión
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsType(TYPE_PENDULUM,fc,0,tp) and c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,0,tp),fc,0,tp))
end
function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,0,tp,code) and not c:IsHasEffect(511002961)
end
    --  *Fusión por contacto
function s.matfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsFaceup()
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
    --  *EFECTO 0°
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--  *Limite de Invocación por Fusión o Fusión por contacto de esta carta
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
    --  *EFECTO 2°
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
    --  *EFECTO 3°
function s.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetAttack()) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,c,c:GetAttack())
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.BreakEffect()
		local ct=#Duel.GetOperatedGroup()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(ct*300)
		c:RegisterEffect(e1)
	end
end
    --  *EFECTO 4°
function s.atkfilter(c)
	return c:IsFaceup()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Group.CreateGroup()
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
    for oc in g:Iter() do
        --Reducir ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        oc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-2000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		oc:RegisterEffect(e2)
		if preatk~=0 and oc:GetAttack()==0 then dg:AddCard(oc) end
	end
	if #dg==0 then return end
	Duel.BreakEffect()
	Duel.Destroy(dg,REASON_EFFECT)
end
    --  *EFECTO 5°
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,tp,POS_FACEUP_DEFENSE)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE)~=0 then
		Duel.NegateActivation(ev)
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			--Inafectada por efecto de otras cartas este turno
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3100)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(function(e, te) return te:GetOwner()~=e:GetOwner() end)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
	--	*EFECTO 7°
function s.cfilter(c)
    return c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil)
    e:SetLabel(g:GetFirst():GetAttribute()) -- Almacena el Atributo desterrado
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local attr=e:GetLabel()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    for tc in aux.Next(g) do
        if tc:IsAttribute(attr) then
            --Niega los efectos
            local e2a=Effect.CreateEffect(c)
            e2a:SetType(EFFECT_TYPE_SINGLE)
            e2a:SetCode(EFFECT_DISABLE)
            e2a:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2a)
            local e2b=Effect.CreateEffect(c)
            e2b:SetType(EFFECT_TYPE_SINGLE)
            e2b:SetCode(EFFECT_DISABLE_EFFECT)
            e2b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2b)
        end
    end
end
	--	*EFECTO 8°
function s.confilter(c)
    return c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.desfilter(c)
    return c:IsLocation(LOCATION_PZONE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,c) end
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_PZONE,0,c)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    --Selecciona la carta a destruir en la Zona de Péndulo
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_PZONE,0,1,1,c)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end