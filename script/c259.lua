--Horizonte del Génesis Onírico
--DrakayStudios - Asesoria por Gemini
local s,id=GetID()
function s.initial_effect(c)
    --  0° Activación: Búsqueda o Invocación Especial
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e0:SetOperation(s.activate)
    c:RegisterEffect(e0)
    --  1° Fusión durante Main o Battle Phase (Efecto Rápido)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_FZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.fuscon)
    e1:SetCost(s.fuscost)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    c:RegisterEffect(e1)
    --  2° Recuperar material cuando la fusión deja el campo
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.retcon)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end
    --  EFECTO 0° Lógica de la activación (e1a para la parte de búsqueda/invocación)
function s.filter(c)
    return c:IsType(TYPE_NORMAL) and c:GetAttack()>=2500 and c:GetDefense()<=2000 and (c:IsAbleToHand() or Duel.GetLocationCount(PLAYER_NONE,LOCATION_MZONE)>0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        local sg=g:Select(tp,1,1,nil):GetFirst()
        if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and sg:IsCanBeSpecialSummoned(e,0,tp,false,false) 
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then -- ID 3: "¿Invocar de modo especial?"
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        else
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end
    --  EFECTO 1° Lógica de Fusión (e1)
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) 
        or (Duel.GetTurnPlayer()~=tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFusionSummonable,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local m=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_MZONE,0,nil)
    local g=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ILLUSION) end,tp,LOCATION_EXTRA,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        local sc=sg:GetFirst()
        if sc then
            --  *Restricción de Extra Deck
            local e2a=Effect.CreateEffect(e:GetHandler())
            e2a:SetType(EFFECT_TYPE_FIELD)
            e2a:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e2a:SetTargetRange(1,0)
            e2a:SetTarget(function(e,c) return c:GetLocation()==LOCATION_EXTRA and not c:IsRace(RACE_ILLUSION) end)
            e2a:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e2a,tp)
            --  *Invocación
            Duel.SpecialSummonRule(tp,sc,SUMMON_TYPE_FUSION)
            --  *Regreso al Extra Deck en la End Phase
            local e2b=Effect.CreateEffect(e:GetHandler())
            e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e2b:SetCode(EVENT_PHASE+PHASE_END)
            e2b:SetCountLimit(1)
            e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUTABLE)
            e2b:SetLabelObject(sc)
            e2b:SetCondition(s.retnextcon)
            e2b:SetOperation(s.retnextop)
            if Duel.GetCurrentPhase()==PHASE_END then
                e2b:SetLabel(Duel.GetTurnCount()+2)
            else
                e2b:SetLabel(Duel.GetTurnCount()+1)
            end
            Duel.RegisterEffect(e2b,tp)
        end
    end
end
function s.retnextcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnCount()==e:GetLabel()
end
function s.retnextop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:IsLocation(LOCATION_MZONE) then
        Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
    end
end
    --  EFECTO 2° Lógica de Recuperación (e2)
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return #eg==1 and tc:IsType(TYPE_FUSION) and tc:IsPreviousControler(tp) and tc:IsReason(REASON_EFFECT)
end
function s.retfilter(c,e,tp,fc)
    return fc:ListsCode(c:GetCode()) and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or c:IsFaceup())
        and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local tc=eg:GetFirst()
    if chkc then return false end
    if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,tc) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,tc)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        else
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        end
    end
end