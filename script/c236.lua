--Sigrid, Sublevado Flamante 
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	--  0° Añadir a tu mano 1 monstruo "Flamante" desde el Deck
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	local e1a=e0:Clone()
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1a)
    --  1° Efectos añadidos al ser material de Sincronía
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_BE_MATERIAL)
    e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.effcon)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={0x3ee}
    --  *EFECTO 0°
function s.thfilter(c)
	return c:IsSetCard(0x3ee) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        local c=e:GetHandler()
	    --  *Ningún jugador puede Invocar monstruos de Modo Especial desde la mano o Cementerio, excepto monstruos "Flamantes"
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,1)
        e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_HAND|LOCATION_GRAVE) and not c:IsSetCard(0x3ee) end)
        e1:SetReset(RESET_PHASE|PHASE_END)
        Duel.RegisterEffect(e1,tp)
	end
end
    --  *EFECTO 1°
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return (r==REASON_XYZ and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)) or (r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():HasLevel())
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--  *Puede atacar hasta 2 veces por cada Battle Phase
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    rc:RegisterEffect(e1)
	rc:RegisterFlagEffect(0,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end