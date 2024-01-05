--Piedra Mágica del Oricalcos
--Piedra Mágica del Oricalcos
local s,id=GetID()
function s.initial_effect(c)
    -- Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	--Buscar "El Sello de Oricalcos" o 1 carta que lo mencione
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	--Cambio de daño
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.oricalcon)
	e1:SetValue(s.rev)
	c:RegisterEffect(e1)
    --Negar ataque
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(aux.AND(s.condition,s.oricalcon))
	e3:SetCost(s.cost)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={48179391}
function s.thfilter(c)
	return (c:IsCode(48179391) or c:ListsCode(48179391)) and not c:IsCode(id) and c:IsAbleToHand()
end
	--Buscar "El Sello de Oricalcos" o 1 carta que lo mencione
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	 --No respuesta de monstruos del adversario
	 if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp or not e:IsActiveType(TYPE_MONSTER) end)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.oricalcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391),e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
    --Cambio de daño
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end
    --Negar ataque
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return tp~=Duel.GetTurnPlayer()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
    e:SetLabel(1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if e:GetLabel()==0 or not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.NegateAttack()
	Duel.SetChainLimit(function(e,ep,tp) return ep==tp or not e:IsActiveType(TYPE_MONSTER) end)
end