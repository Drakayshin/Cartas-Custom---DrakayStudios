--Veloraptor Périlleux
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
    -- 	0° Inafectada por efectos de monstruo que no sean Péndulo
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetValue(function(e,te) return te:IsMonsterEffect() and not te:GetOwner():IsType(TYPE_PENDULUM) end)
	c:RegisterEffect(e0)
    -- 	1° Gana la mitad del ataque del monstruo destruido por batalla contra esta carta
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(aux.bdocon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)

	-- 	EFECTO DE PENDULO
	
	-- 	2° Añadir a la mano 2 monstruos Péndulo
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
	--	*EFECTO 1°
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local bc=c:GetBattleTarget()
		local atk=math.max(bc:GetBaseAttack(),bc:GetBaseDefense())/2		
		--	*Incrementar ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
	--	*EFECTO 2°
function s.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DINOSAUR|RACE_REPTILE|RACE_SEASERPENT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,2,2,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end