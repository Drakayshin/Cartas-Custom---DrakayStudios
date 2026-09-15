--Rite of Conversion
--DrakayStudios - Evento 12/09/2026 - Hernán Fernández
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: añadir carta a la mano
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_RELEASE)
    e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,{id,0})
    e0:SetTarget(s.thtg)
    e0:SetOperation(s.thop)
    c:RegisterEffect(e0)
end
s.listed_series={0x3e7}
    --  *EFECTO 0°
function s.thfilter(c,tp)
    local b1 = c:IsAbleToHand()
    local b2 = c:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true,true) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    return c:IsSpell() and (b1 or b2)
end
function s.relfilter(c)
    return c:IsType(TYPE_EFFECT) and c:IsReleasableByEffect()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local rg=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #rg>0 and Duel.Release(rg,REASON_EFFECT)>0 then
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) then
            local b1 = tc:IsAbleToHand()
            local b2 = tc:IsType(TYPE_CONTINUOUS) and c:GetActivateEffect():IsActivatable(tp,true,true) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            -- Si es Mágica Continua y el jugador decide activarla
            if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
                Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
                local te=tc:GetActivateEffect()
                local cost=te:GetCost()
                if cost then cost(te,tp,eg,ep,ev,re,r,rp,1) end
            -- De lo contrario, se añade a la mano
            elseif b1 then
                Duel.SendtoHand(tc,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tc)
            end
        end
    end
end