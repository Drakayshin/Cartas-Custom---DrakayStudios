--オルターガイスト・プロトコル
--Altergeist Protocol
local s,id=GetID()
function s.initial_effect(c)
	--  0° Activación
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(aux.StatChangeDamageStepCondition)
    c:RegisterEffect(e0)
    --  1° Destruir esta carta si recibes daño por batalla
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(s.dscon)
	e1:SetTarget(s.dstg)
	e1:SetOperation(s.dsop)
	c:RegisterEffect(e1)
    --  2° Evitar la negación de la activación o los efectos de cartas "Empíreo"
    local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_DISABLE)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetTargetRange(LOCATION_ONFIELD,0)
	e2a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2a:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3eb))
	c:RegisterEffect(e2a)
    local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2b:SetRange(LOCATION_SZONE)
	e2b:SetValue(s.effectfilter)
	c:RegisterEffect(e2b)
	local e2c=e2b:Clone()
	e2c:SetCode(EFFECT_CANNOT_DISEFFECT)
	c:RegisterEffect(e2c)
	--  3° Negación y destruir
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3a:SetType(EFFECT_TYPE_ACTIVATE)
	e3a:SetCode(EVENT_CHAINING)
	e3a:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3a:SetCountLimit(1,{id,1})
	e3a:SetCondition(s.discon)
	e3a:SetCost(s.discost)
	e3a:SetTarget(s.distg)
	e3a:SetOperation(s.disop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetType(EFFECT_TYPE_QUICK_O)
	e3b:SetRange(LOCATION_SZONE)
    c:RegisterEffect(e3b)
    --  4° Activar desde la mano con tu adversario tiene 3 o mas cartas en su Campo
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e4:SetCountLimit(1,{id,2})
	e4:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)>2 end)
	c:RegisterEffect(e4)
end
s.listed_series={0x3eb}
	--	*Efecto 1°
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_BATTLE==REASON_BATTLE and ep==tp and Duel.GetBattleDamage(tp)<=1000
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,LOCATION_SZONE)
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
    --  *Efecto 2°
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
    return p==tp and te:GetHandler():IsSetCard(0x3eb) and loc&LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED~=0
end
    --  *Efecto 3°
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3eb) and c:IsAbleToRemoveAsCost()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and (re:IsMonsterEffect() or re:IsActiveType(TYPE_SPELL+TYPE_TRAP)) and Duel.IsChainNegatable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end