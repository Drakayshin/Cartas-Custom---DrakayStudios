--Neo Raptor périlleux
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Protocolo de Péndulo
	Pendulum.AddProcedure(c)
	-- Ganar ATK
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e0:SetCountLimit(1,id)
	e0:SetCondition(s.atkcon)
	e0:SetOperation(s.atkop)
	c:RegisterEffect(e0)
    -- Invocar monstruos
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    -- Colocar en zona de Péndulo
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.pencon)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)

    -- Efecto Péndulo

    -- Limite de Invocación por Péndulo
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
    -- Reducción de ATK/DEF
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
    -- Ganar ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetBaseAttack()+1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
    -- Invocar monstruos
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR|RACE_REPTILE) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND,0,1,2,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
    -- Colocar en Zona de Péndulo
function s.thcfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsRace(RACE_DINOSAUR|RACE_REPTILE) and c:GetReasonPlayer()==1-tp
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.thcfilter,1,e:GetHandler(),tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
    -- Limite de Invocación por Péndulo
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
    -- Reducir ATK/DEF
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-200
end