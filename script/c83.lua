--Demarcación Octaviana
--Drakay
local s,id=GetID()
function s.initial_effect(c)
	--  0° Activación
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--  1° Monstruos "Terranigma" que controles no puede ser destruidos por efectos de cartas de tu adversario
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(0x3e7) end)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--  2° Monstruos "Terranigma" que controles no puede ser seleccionados por efectos de cartas de tu adversario
	local e1a=e1:Clone()
	e1a:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1a:SetValue(aux.tgoval)
    c:RegisterEffect(e1a)
    -- 2° Destruir 1 carta en el Campo, pero saltar tu siguiente Fase de Robo
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(511000186,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--	4° Activar desde la mano si tu adversario controla una carta
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)>1 end)
	c:RegisterEffect(e3)
end
s.listed_series={0x3e7}
    --  *EFECTO 2°
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetTargetRange(1,0)
		if Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_DRAW) then
			e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN)
		end
		Duel.RegisterEffect(e1,tp)
	end
end