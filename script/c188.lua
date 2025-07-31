--Soldado del Brillo Negro - Soldado Flamante
--DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
	-- 	*Invocación por Sincronía
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_WARRIOR),1,99)
    -- 	0° Inafectada por otras cartas hasta el final de tu proximo turno
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	e0:SetOperation(s.imop)
	c:RegisterEffect(e0)
    -- 	1° Daño de Perforación
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
    -- 	2° Gana 1500 ATK/DEF durante la Battle Phase solamente
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function() return Duel.IsBattlePhase() end)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
    local e2a=e2:Clone()
	e2a:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2a)
    -- 	3° Ganar LP igual al ATK original del monstruo destruido por batalla contra esta carta
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
    -- 4° Infligir daño igual al ATK original del monstruo destruido por batalla contra esta carta
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.listed_series={0x10cf}
	--	*EFECTO 0°
function s.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--	*Unaffected by other cards' effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3100)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,Duel.IsTurnPlayer(tp) and 2 or 1)
	c:RegisterEffect(e1)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
    --	*EFECTO 3°
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=e:GetHandler():GetBattleTarget():GetBaseAttack()
	if chk==0 then return dam>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dam)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
    -- 	*EFECTO 4°
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