--Shicard, El Arcano de Fábula
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--  *Invocación por Sicronía opcional
	local synchro_proc0=Synchro.AddProcedure(c,nil,2,99,aux.FilterSummonCode(290),1,1)
	local synchro_proc1=Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,aux.FilterSummonCode(290),1,1)
	synchro_proc0:SetDescription(aux.Stringid(id,0))
	synchro_proc1:SetDescription(aux.Stringid(id,1))
	--  Efecto 0: El nombre de esta carta se convierte en "Yacard, Héroe de la Fábula" en Campo o Cementerio
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    e0:SetValue(290)
    c:RegisterEffect(e0)
    --  Efecto 1: Debe ser Invocado solo por Sincronía
    local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	--	Efecto 2: No puede ser destruido por batalla
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
    c:RegisterEffect(e2)
    --  Efecto 3: Invocar de Modo Especial 1 Monstruo de Sincronía
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
    e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    --  Efecto 3: Efectos de secuencia

end
s.material={290}
s.listed_names={290}
s.synchro_nt_required=1
s.synchro_tuner_required=1
    --  *EFECTO 3° 
function s.exspfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER)  and c:IsLevelBelow(8) and c:IsType(TYPE_SYNCHRO) 
        and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
--  *Efecto 3°
