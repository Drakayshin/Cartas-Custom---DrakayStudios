--Alf, Escrupuloso Flamante
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  0° Invocar de Modo Especial 1 monstruo Cantante "Flamante" desde tu Deck
    local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    local e0a=e0:Clone()
	e0a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e0a)
	local e0b=e0:Clone()
	e0b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e0b)
    --  1° Efectos añadidos al ser material de Sincronía
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_BE_MATERIAL)
    e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.effcon)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x3ee) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        --  *No puedes Invocar de Modo Especial de Deck Extra, excepto monstruos "Flamante"
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,0))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x3ee) end)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
        aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsSetCard(0x3ee) end)
	end
end
    --  *EFECTO 1°
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    return ((r==REASON_XYZ and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)) 
    or (r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():HasLevel())) and e:GetHandler():GetReasonCard():IsSetCard(0x3ee)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--  *No puede ser afectado por efectos activos de cartas Mágica/de Trampa
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e,te) return te:IsActivated() and te:IsSpellTrapEffect() and te:GetOwner()~=e:GetOwner() end)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    rc:RegisterEffect(e1)
end