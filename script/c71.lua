--Cikalant Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Reducción de ATK/DEF
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_UPDATE_ATTACK)
    e0:SetRange(LOCATION_MZONE) -- Cambia a LOCATION_SZONE si esta carta es una Mágica/Trampa
    e0:SetTargetRange(0,LOCATION_MZONE)
    e0:SetValue(s.val)
    c:RegisterEffect(e0)
    local e0a=e0:Clone()
    e0a:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e0a)
    --  Efecto 1: Desterrar desde la mano para buscar e Invocar de Modo Normal
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,0})
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    --  Efecto 2: Invocación Especial al ser Invocado de Modo Normal
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1}) -- Hard Once Per Turn separado para el segundo efecto
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_series={0x3e7}
s.listed_names={id}
function s.cfilter(c)
    -- Verifica que esté boca arriba y sea la carta específica
    return c:IsFaceup() and c:IsCode(id)
end
function s.val(e,c)
    local tp=e:GetHandlerPlayer()
    local count=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
    return count * -500
end
    --  *EFECTO 1°
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.thfilter(c)
    return c:IsSetCard(0x3e7) and c:IsType(TYPE_MONSTER) and c:GetLevel()<=4 and c:IsAbleToHand()
end
function s.sumfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonable(true,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
            -- "...puedes Invocar de Modo Normal 1 monstruo de Oscuridad."
        if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local sc=sg:Select(tp,1,1,nil):GetFirst()
            if sc then
                Duel.Summon(tp,sc,true,nil)
            end
        end
    end
end
    --  *EFECTO 2°
function s.spfilter(c,e,tp)
    return c:IsCode(id) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
    ft=math.min(ft,2)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,ft,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- "...y si lo haces, por el resto de este turno, no puedes Invocar monstruos de Modo Especial, excepto monstruos 'Terranigma'."
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetDescription(aux.Stringid(id,3)) -- Índice para el mensaje de restricción en EDOPRO
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(e,c) return not c:IsSetCard(0x3e7) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end