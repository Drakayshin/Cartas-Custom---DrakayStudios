--Piedra Mágica de Oricalcos
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- *Solo 1 Boca arriba en tu campo
    c:SetUniqueOnField(1,0,id)
	-- 	0° Buscar "El Sello de Oricalcos" o 1 carta que lo mencione desde tu Deck
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)
	-- 	1° Prevenir respuesta a la activacion de tus Spell/Traps
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.oricalcon)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
	-- 	2° Cambio de daño por efecto
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_REVERSE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.oricalcon)
	e2:SetValue(s.rev)
	c:RegisterEffect(e2)
    -- 	3° Negar un ataque declarado por tu adversario
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(aux.AND(s.condition,s.oricalcon))
	e3:SetCost(s.cost)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={48179391}
function s.thfilter(c)
	return (c:IsCode(48179391) or c:ListsCode(48179391)) and not c:IsCode(id) and c:IsAbleToHand()
end
	--	*EFECTO 0°
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
	--	*Condición general de los siguientes efectos
function s.oricalcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,48179391,125,130),e:GetHandlerPlayer(),LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
end
	--	*EFECTO 1°
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsSpellTrapEffect() and re:GetOwnerPlayer()==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,ep,tp)
	return ep==tp or not e:IsMonsterEffect()
end
	--	*EFECTO 2°
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end
	--	*EFECTO 3°
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