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
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0)) 
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetRange(LOCATION_MZONE) -- Asumiendo que es un monstruo en el campo. Cámbialo si es Mágica/Trampa.
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
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
	--  *Efecto 4°
-- Filtros de Condiciones
function s.syncfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end

function s.negfilter(c)
    return c:IsFaceup() and not c:IsDisabled()
end

function s.atkfilter(c)
    return c:IsFaceup() and c:GetBaseDefense()>0
end

-- Selección de Objetivos / Opciones
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.negfilter(chkc) end
    
    local b1=Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil)
    
    if chk==0 then return b1 or b2 end
    
    local op=0
    if b1 and b2 then
        -- Si ambas son posibles: 0=Negar, 1=ATK, 2=Ambas
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1))
    else
        op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
    end
    
    e:SetLabel(op)
    
    -- Manejo dinámico del Target (Solo si es la opción 0 [Negar] o la 2 [Ambas])
    if op==0 or op==2 then
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        local ct=Duel.GetMatchingGroupCount(s.syncfilter,tp,LOCATION_MZONE,0,nil)+1
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
        local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
    else
        e:SetProperty(0)
    end
    
    if op==1 or op==2 then
        Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,0,tp,LOCATION_MZONE)
    end
end

-- Resolución del Efecto
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local op=e:GetLabel()
    
    -- Operación: Negar (Opción 0 o 2)
    if op==0 or op==2 then
        local tg=Duel.GetTargetCards(e)
        if tg and #tg>0 then
            for tc in aux.Next(tg) do
                if tc:IsFaceup() and not tc:IsDisabled() and tc:IsRelateToEffect(e) then
                    Duel.NegateRelatedChain(tc,RESET_TURN_SET)
                    
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_SINGLE)
                    e1:SetCode(EFFECT_DISABLE)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                    tc:RegisterEffect(e1)
                    
                    local e1a=e1:Clone()
                    e1a:SetCode(EFFECT_DISABLE_EFFECT)
                    e1a:SetValue(RESET_TURN_SET)
                    tc:RegisterEffect(e1a)
                    
                    if tc:IsType(TYPE_TRAPMONSTER) then
                        local e1b=e1:Clone()
                        e1b:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                        tc:RegisterEffect(e1b)
                    end
                end
            end
        end
    end
    -- Romper la cadena en caso de seleccionar ambas opciones
    if op==2 then
        Duel.BreakEffect()
    end
    -- Operación: Ganar ATK (Opción 1 o 2)
    if op==1 or op==2 then
        local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
        for tc in aux.Next(g) do
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_UPDATE_ATTACK)
            e2:SetValue(tc:GetBaseDefense())
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
            tc:RegisterEffect(e2)
        end
    end
end