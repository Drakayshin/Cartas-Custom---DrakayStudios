--Doble Filo Mágico
--DrakayStudios - Asesoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
    --  e0: Efecto principal (Sacrificar, Invocar y Desterrar)
    local e0=Effect.CreateEffect(c)
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id) -- Límite compartido (1 efecto por turno)
    e0:SetCost(s.cost)
    e0:SetTarget(s.target)
    e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    --  e1a: Efecto en Cementerio (Invocar y Destruir)
    local e1a=Effect.CreateEffect(c)
    e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1a:SetType(EFFECT_TYPE_IGNITION)
    e1a:SetRange(LOCATION_GRAVE)
    e1a:SetCountLimit(1,id) -- Límite compartido con e1
    e1a:SetCost(aux.bfgcost) -- Se destierra a sí misma como costo
    e1a:SetTarget(s.gytg)
    e1a:SetOperation(s.gyop)
    c:RegisterEffect(e1a)
end
    --  *EFECTO 0° Funciones para e1 (Activación desde Campo/Mano)
function s.cfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and c:IsReleasable()
        and Duel.GetMZoneCount(tp,c)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
    -- Verifica diferente nombre y que esté boca arriba si está en el destierro
    return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
    and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    e:SetLabel(1) -- Etiqueta para enlazar el costo con el target
    return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToRemove() end
    if chk==0 then
        if e:GetLabel()==1 then
            e:SetLabel(0)
            return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,e,tp)
        else
            return false
        end
    end
    e:SetLabel(0)
    --  *Ejecución del costo (Sacrificar)
    local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,e,tp)
    local code=rg:GetFirst():GetCode()
    Duel.Release(rg,REASON_COST)
    e:SetLabel(code) -- Se guarda el código del monstruo sacrificado
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local code=e:GetLabel()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp,code)
    --  *Efecto de destierro opcional
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 
        and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
        local tc=Duel.GetFirstTarget()
        --  *Si se seleccionó objetivo al activar, se destierra en resolución
        if tc and tc:IsRelateToEffect(e) then
            Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
        end
    end
end
    -- *EFECTO 1° Funciones para e1a (Efecto en Cementerio)
function s.gyfilter(c,e,tp)
    return c:IsRace(RACE_WARRIOR|RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    --  *Se avisa al motor que puede haber una destrucción en resolución
    local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #dg>0 then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
    end
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        --  *Verifica si el monstruo invocado es el único monstruo controlado
        if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1 then
            local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
            if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
                local sg=dg:Select(tp,1,1,nil)
                Duel.HintSelection(sg)
                Duel.Destroy(sg,REASON_EFFECT)
            end
        end
    end
end