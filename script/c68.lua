--Alcurnia Terranigma
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  Efecto 0: Activar desde la mano
    local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(function(e) return not Duel.IsExistingMatchingCard(Card.IsSpecialSummoned,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	c:RegisterEffect(e0)
	--	Efecto 1: Buscar e Invocar de Modo Normal
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_RELEASE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--	Efecto 2: Buscar y robar
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(Cost.SelfBanish) -- "Puedes desterrar esta carta en tu Cementerio"
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x3e7}
	--	*EFECTO 1°
function s.tgfilter(c,tp)
    local lvl=c:GetLevel()
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsReleasableByEffect() and lvl>0
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,lvl)
end
function s.thfilter(c,lvl)
    return c:IsSetCard(0x3e7) and c:IsType(TYPE_MONSTER) and c:GetLevel()~=lvl and c:IsAbleToHand()
end
function s.sumfilter(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonable(true,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        local lvl=tc:GetLevel()
        -- "Sacrifícalo, y si lo haces..."
        if Duel.Release(tc,REASON_EFFECT)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lvl)
            -- "...añade a tu mano 1 monstruo 'Terranigma' con diferente Nivel..."
            if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
                Duel.ConfirmCards(1-tp,g)
                Duel.ShuffleHand(tp)
                -- "...e inmediatamente después, Invoca de Modo Normal 1 monstruo de Oscuridad."
                local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
                if #sg>0 then
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
                    local sc=sg:Select(tp,1,1,nil):GetFirst()
                    if sc then
                        Duel.Summon(tp,sc,true,nil)
                    end
                end
            end
        end
    end
end
	--	*EFECTO 2°
function s.thfilter(c,tp)
    return c:IsSetCard(0x3e7) and c:IsAbleToHand() and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) and Duel.IsPlayerCanDraw(1-tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        if g:GetFirst():IsLocation(LOCATION_HAND) then
            Duel.BreakEffect() -- Opcional pero recomendado para efectos "y si lo haces" que son acciones separadas
            Duel.Draw(1-tp,1,REASON_EFFECT)
        end
    end
end