--Shiro, Mago de la Fábula
--DrakayStudios - Asegoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
	--  Efecto 0: Efecto Rápido en Battle Phase (Sincronía o Xyz)
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0)) -- "Invocar por Sincronía o Xyz"
    e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_QUICK_O)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetRange(LOCATION_MZONE)
    e0:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
    e0:SetCountLimit(1,{id,0})
    e0:SetCondition(s.scxyzcon)
    e0:SetTarget(s.scxyztg)
    e0:SetOperation(s.scxyzop)
    c:RegisterEffect(e0)
    --  Efecto 1: Trigger si es Invocada en la Battle Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1)) -- "Aplicar efectos en secuencia"
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,1})
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
    --  EFECTO 1: Sincronía / Xyz Rápida
function s.scxyzcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end
function s.syncxyzfilter(c,mc)
    --  *Filtra Sincronía o Xyz que puedan usar esta carta (mc) como material
    return c:IsType(TYPE_SYNCHRO|TYPE_XYZ) and (c:IsSynchroSummonable(mc) or c:IsXyzSummonable(mc))
end
function s.scxyztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.syncxyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scxyzop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.syncxyzfilter,tp,LOCATION_EXTRA,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc then
            --  *El motor resuelve correctamente si es Sincronía o Xyz
            if tc:IsType(TYPE_SYNCHRO) then
                Duel.SynchroSummon(tp,tc)
            elseif tc:IsType(TYPE_XYZ) then
                Duel.XyzSummon(tp,tc)
            end
        end
    end
end
-- =========================================================
-- EFECTO 2: Efectos Secuenciales
-- =========================================================
function s.seqcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsBattlePhase()
end
-- Filtro: Agua, Tierra, Fuego o Viento de Nivel 4 o menor
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_WATER|ATTRIBUTE_EARTH|ATTRIBUTE_FIRE|ATTRIBUTE_WIND) 
        and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
-- Función auxiliar para contar Atributos originales diferentes
function s.get_att_count(tp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local ct=0
    -- Lista de los 7 atributos oficiales
    local atts={ATTRIBUTE_EARTH,ATTRIBUTE_WATER,ATTRIBUTE_FIRE,ATTRIBUTE_WIND,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK,ATTRIBUTE_DIVINE}
    for _,att in ipairs(atts) do
        -- Si existe al menos un monstruo con ese atributo original, sumamos 1
        if g:IsExists(Card.IsOriginalAttribute,1,nil,att) then
            ct=ct+1
        end
    end
    return ct
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_REMOVED,0,1,nil,e,tp)
    local ct=s.get_att_count(tp)
    local b2=ct>0 and Duel.IsPlayerCanDraw(tp,ct)
    
    if chk==0 then return b1 or b2 end
    
    -- Se declaran las posibles acciones sin hacerlas obligatorias
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_REMOVED)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_REMOVED,0,1,nil,e,tp)
    
    local res=false
    
    -- Secuencia 1: Invocar de Modo Especial y aplicar redirección
    if b1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_REMOVED,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
            res=true
            -- Efecto de bajar al fondo del Deck cuando deje el campo
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(3900) -- Hint de sistema: "Devolver al fondo del Deck"
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_DECKBOT)
            tc:RegisterEffect(e1,true)
        end
    end
    -- Recalculamos los atributos ANTES de la Secuencia 2.
    -- (Esto es vital por si el monstruo invocado sumó un Atributo nuevo)
    local ct=s.get_att_count(tp)
    local b2=ct>0 and Duel.IsPlayerCanDraw(tp,ct)
    
    -- Secuencia 2: Robar Cartas
    if b2 then
        if res then 
            Duel.BreakEffect() 
        end
        Duel.Draw(tp,ct,REASON_EFFECT)
    end
end