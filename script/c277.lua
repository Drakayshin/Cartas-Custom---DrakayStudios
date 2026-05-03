--Pterosaurios Périlleux
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    -- 	0° Inafectada por efectos de monstruo que no sean Péndulo
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetValue(function(e,te) return te:IsMonsterEffect() and not te:GetOwner():IsType(TYPE_PENDULUM) end)
	c:RegisterEffect(e0)
    --  1° Invocar de Modo Especial desde la mano o Deck Extra boca arriba
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1a)
    --  1° Robar 1 carta con posible invocación especial si es un monstruo Dinosario, Reptil o Serpiente Marina
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.drath)
	e2:SetOperation(s.draop)
    c:RegisterEffect(e2)
    
    -- 	EFECTO DE PENDULO

    --  3° Invocar de Modo Epecial desde la Zona de Péndulo
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_PZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
    e3:SetCountLimit(1,{id,1})
    e3:SetCondition(s.penspcon)
    e3:SetCost(Cost.PayLP(1000))
	e3:SetTarget(s.pensptg)
	e3:SetOperation(s.penspop)
	c:RegisterEffect(e3)
end
    --  *EFECTO 1°
function s.spfilter(c,e,tp)
	if not (c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_HAND) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
    --  *EFECTO 2°
function s.desfilter(c,tp)
	return c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and Duel.GetMZoneCount(tp,c)>0
end
function s.drath(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,nil,tp) end
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.draop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,0,1,1,nil,tp)
    if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
        local ct=Duel.Draw(tp,1,REASON_EFFECT)
        if ct==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        local tc=Duel.GetOperatedGroup():GetFirst()
        if tc:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.ConfirmCards(1-tp,tc)
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
	end
end
    --  *FECTO 3°
function s.thcfilter(c,tp)
    return c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsPreviousControler(tp) 
    and c:IsOriginalRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT)
end
function s.penspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.thcfilter,1,e:GetHandler(),tp)
end
function s.pensptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.penspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end