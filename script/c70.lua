--Takriminos Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Limite de destierro
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e0:SetCode(EFFECT_CANNOT_REMOVE)
    e0:SetRange(LOCATION_MZONE|LOCATION_SZONE)
    e0:SetTargetRange(0,1) -- Afecta al adversario
    e0:SetTarget(function(e,c) return c:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e0)
    --  Efecto 1: Buscar y robo al adversario
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetCost(Cost.SelfDiscard)
    e1:SetTarget(s.thwrtg)
    e1:SetOperation(s.thwrop)
    c:RegisterEffect(e1)
    --  Efecto 2: Colocar y enviar al Cementerio o destruir
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_series={0x3e7}
s.listed_names={id}
    --  *EFECTO 1°
function s.thdrfilter(c)
    return c:IsSetCard(0x3e7) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thwrtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thdrfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1,1)
end
function s.thwrop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thdrfilter,tp, LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,g)
            Duel.Draw(1-tp,1,REASON_EFFECT)
        end
    end
end
    --  *EFECTO 2°
function s.spfilter(c)
    return c:IsSetCard(0x3e7) and c:IsMonster() 
        and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED)) and not c:IsFacedown()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.spfilter(chkc) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)~=0 then
            --  *Opcionalmente enviar al Cementerio o destruir 1 carta en el campo
            if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
                and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.BreakEffect()
                local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
                local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
                if #g>0 then
                    Duel.HintSelection(g)
                    if op==0 then
                        Duel.SendtoGrave(g,REASON_EFFECT)
                    else
                        Duel.Destroy(g,REASON_EFFECT)
                    end
                end
            end
        end
    end
end