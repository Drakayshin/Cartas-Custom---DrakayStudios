--Designio de Represalia
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Activación
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Reducir a la mitad del daño
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCountLimit(2)
	e1:SetOperation(s.rdop)
	c:RegisterEffect(e1)
	-- Destierro
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_COIN+CATEGORY_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
	-- Daño por batalla a la mitad
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.ChangeBattleDamage(tp,math.floor(ev/2))
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
	-- Destierro por lanzamiento de moneda
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(612115,0))
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(612115,0))
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc1=e:GetLabelObject()
	local g=Duel.GetTargetCards(e)
	if #g<=1 then return end
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if Duel.CallCoin(tp) then
		if Duel.Remove(tc2,POS_FACEUP,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,tc2:GetBaseAttack(),REASON_EFFECT)
		end
	else
		if Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)>0 then
			Duel.Damage(tp,tc1:GetBaseAttack(),REASON_EFFECT)
		end
	end
end
