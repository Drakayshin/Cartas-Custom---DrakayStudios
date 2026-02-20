--Cabalkiria Flamante
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--	0° Invocar de Modo Especial desde la mano si no controlas monstruos o todos son monstruos "Flamante"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)
    --  1° Invocar por Sincronía o Xyz 1 Monstruo "Flamante"
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END|TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --  2° Efectos añadidos al ser material de Sincronía
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3ee}
    --	*EFECTO 0°
function s.cfilter(c)
	return not c:IsSetCard(0x3ee)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
	and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
    --  *EFECTO 1°
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        return Duel.IsExistingMatchingCard(s.spxfilter,tp,LOCATION_EXTRA,0,1,nil,g) 
        or Duel.IsExistingMatchingCard(s.spsfilter,tp,LOCATION_EXTRA,0,1,nil,g) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spxfilter(c)
	return c:IsXyzSummonable()
end
function s.spsfilter(c)
	return c:IsSynchroSummonable()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	local xg=Duel.GetMatchingGroup(s.spxfilter,tp,LOCATION_EXTRA,0,nil)
	local sg=Duel.GetMatchingGroup(s.spsfilter,tp,LOCATION_EXTRA,0,nil)
	local b1=#xg>0
	local b2=#sg>0 
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,0)},{b2,aux.Stringid(id,1)})
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=xg:Select(tp,1,1,nil)
		if #g>0 then
			Duel.XyzSummon(tp,g:GetFirst())
			--	*No puedes atacar con monstruos este turno, excepto con monstruos "Flamante"
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.attg)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=sg:Select(tp,1,1,nil)
		if #g>0 then
			Duel.SynchroSummon(tp,g:GetFirst())
			--	*No puedes atacar con monstruos este turno, excepto con monstruos "Flamante"
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,2))
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_ATTACK)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetTarget(s.attg)
			e2:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.attg(e,c)
	return not c:IsSetCard(0x3ee)
end
    --  *EFECTO 1°
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return (r==REASON_XYZ and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)) 
    or (r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():HasLevel())
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--  *No puede ser afectado por efectos activos de otros monstruos
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e,te) return te:IsActivated() and te:IsMonsterEffect() and te:GetOwner()~=e:GetHandler()  end)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    rc:RegisterEffect(e1)
end