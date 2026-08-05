--Gamoth, Telúrico de la Fábula
--DrakayStudios - Asegoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
	--  Efecto 0: Invocar de Modo Especial (Efecto Rápido)
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0)) -- "Invocar de Modo Especial"
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_QUICK_O)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetRange(LOCATION_HAND|LOCATION_GRAVE)
    e0:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e0:SetCountLimit(1,{id,0}) -- Primer Once Per Turn (id)
    e0:SetCondition(s.spcon)
    e0:SetTarget(s.sptg)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)
    --  Efecto 1: Secuencia al ser Invocado en la Battle Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1)) -- "Aplicar efectos en secuencia"
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1}) -- Segundo Once Per Turn (id+1)
    e1:SetCondition(s.seqcon)
    e1:SetTarget(s.seqtg)
    e1:SetOperation(s.seqop)
    c:RegisterEffect(e1)
    local e1a=e1:Clone()
    e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1a)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e1b)
end
s.listed_names={290}
-- =========================================================
-- EFECTO 1: Invocación Especial (Efecto Rápido)
-- =========================================================
-- Filtro para buscar a Yacard, Héroe de la Fábula (ID 290)
function s.yacardfilter(c)
    return c:IsFaceup() and c:IsCode(290)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.yacardfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        --  *Efecto de desterrar cuando deje el campo
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3300) -- Hint del sistema nativo: "Desterrar cuando deje el campo"
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end
-- =========================================================
-- EFECTO 2: Efectos Secuenciales
-- =========================================================
function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end
-- Filtro: Trampa NORMAL que se pueda añadir a la mano o colocar
function s.trapfilter(c)
    -- c:GetType()==TYPE_TRAP es la forma nativa de filtrar Trampas Normales estrictamente (ignora Continuas y Contraefecto)
    return c:GetType()==TYPE_TRAP and (c:IsAbleToHand() or c:IsSSetable())
        and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
-- Función para contar Atributos originales diferentes
function s.get_att_count(tp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    local ct=0
    local atts={ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_WIND,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK,ATTRIBUTE_DIVINE}
    for _,att in ipairs(atts) do
        if g:IsExists(Card.IsOriginalAttribute,1,nil,att) then
            ct=ct+1
        end
    end
    return ct
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
    local ct=s.get_att_count(tp)
    local b2=ct>0
    
    if chk==0 then return b1 or b2 end
    
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
    Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*600)
end

function s.seqop(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
    local res=false
    -- Secuencia 1: Añadir a la mano o Colocar Trampa Normal
    if b1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local g=Duel.SelectMatchingCard(tp,s.trapfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            local op=0
            local can_hand=tc:IsAbleToHand()
            local can_set=tc:IsSSetable()
            
            -- Lógica para preguntarle al jugador si puede hacer ambas cosas
            if can_hand and can_set then
                op=Duel.SelectOption(tp,aux.Stringid(id,1),1153) -- 1190: Añadir a la mano, 1153: Colocar (Hints nativos del sistema)
            elseif can_hand then
                op=0
            else
                op=1
            end
            -- Ejecutar la acción elegida
            if op==0 then
                if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
                    Duel.ConfirmCards(1-tp,tc)
                    res=true
                end
            else
                if Duel.SSet(tp,tc)~=0 then
                    res=true
                end
            end
        end
    end
    
    -- Secuencia 2: Ganar LP
    local ct=s.get_att_count(tp)
    local b2=ct>0
    if b2 then
        if res then Duel.BreakEffect() end
        Duel.Recover(tp,ct*600,REASON_EFFECT)
    end
end