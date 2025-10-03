--Cabalkiria del Génesis Flamante
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    --  *Invocación por Sincronía
    c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x3ee),2,2,Synchro.NonTuner(nil),1,99)
	--	0° Debe ser Primero Invocado por Sincronía
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)
    --  0° Tu adversrio no puede Sacrificar esta carta en el Campo
    local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetCode(EFFECT_UNRELEASABLE_SUM)
	e0a:SetValue(s.sumlimit)
	c:RegisterEffect(e0a)
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD)
	e0b:SetCode(EFFECT_CANNOT_RELEASE)
	e0b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0b:SetRange(LOCATION_MZONE)
	e0b:SetTargetRange(0,1)
	e0b:SetTarget(function(e,c) return c==e:GetHandler() end)
	e0b:SetValue(1)
    c:RegisterEffect(e0b)
    --  1° No puede ser desterrada en el Campo
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a:SetTargetRange(1,1)
	e1a:SetTarget(function(e,c,p) return c==e:GetHandler() end)
    c:RegisterEffect(e1a)
    --  2° Negar la activación de una carat y ganar LP igual al ATK original si es un monstruo
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,0})
    e2:SetCost(Cost.PayLP(1000))
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
    --  3° Infligir daño igual al ATK original del monstruo destruido por batalla contra esta carta
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.listed_series={0x3ee}
    -- 	*EFECTO 0°
function s.sumlimit(e,c)
    if not c then return false end
    return not c:IsControler(e:GetHandlerPlayer())
end
    --  *EFECTO 2°
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		if re:GetHandler():IsMonster() then
			Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,re:GetHandler():GetBaseAttack())
		end
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		and re:GetHandler():IsMonster() and re:GetHandler():GetBaseAttack()>0 then
		Duel.BreakEffect()
		Duel.Recover(tp,re:GetHandler():GetBaseAttack(),REASON_EFFECT)
	end
end
    --  *EFECTO 3°
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetBattleTarget()
	local atk=tc:GetBaseAttack()
	if atk<0 then atk=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end