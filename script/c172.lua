--Kitzune Empíreo
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- Invocar por Sincronía
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,99,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,1)
	-- Limite de Invocación
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetRange(LOCATION_GRAVE,LOCATION_REMOVED)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- No recibes daño de batalla de esta carta
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Ataque directo
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
    -- Ningún monstruo es destruido por batalla contra esta carta
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indestg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
    --Daño igual al ATK/DEF mas alto
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.listed_series={0x3eb}
	-- Debe ser Invocada de forma especifica
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x3eb)
end
    -- Ningún monstruo es destruido por batalla
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
    --Daño igual al ATK/DEF mas alto
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	local dam=math.max(bc:GetTextAttack(),bc:GetTextDefense())
	if chk==0 then return dam>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.max(bc:GetTextAttack(),bc:GetTextDefense())
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end